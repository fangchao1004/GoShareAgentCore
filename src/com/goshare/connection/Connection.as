package com.goshare.connection
{
	import com.goshare.data.ClientMessageType;
	import com.goshare.data.Message;
	import com.goshare.event.ConnectionEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.net.LocalConnection;
	import flash.utils.Timer;
	
	
	[Event(name="connect", type="com.goshare.event.ConnectionEvent")]
	
	[Event(name="disconnect", type="com.goshare.event.ConnectionEvent")]
	
	[Event(name="receiveMessage", type="com.goshare.event.ConnectionEvent")]
	
	[Event(name="logMessage", type="com.goshare.event.ConnectionEvent")]
	
	[ExcludeClass]
	public class Connection extends EventDispatcher
	{
		public function Connection(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		protected var sendConnectionName:String;
		protected var receiveConnectionName:String;
		protected var sendConnection:LocalConnection;
		protected var receiveConnection:LocalConnection;
		protected var hearbeatIsResponed:Boolean = false;
		
		private var receiveConnectionOK:Boolean = false;
		private var checkTimer:Timer;
		private var sendingMessage:Message;
		private var sendingMessages:Vector.<Message> = new Vector.<Message>();
		
		/**
		 * 心跳间隔时间 
		 */		
		public var heartbeatInterval:Number = 10000;
		
		private var _connected:Boolean = false;
		
		/**
		 * 是否连接成功 
		 */
		public function get connected():Boolean
		{
			return _connected;
		}
		
		/**
		 * @private
		 */
		public function set connected(value:Boolean):void
		{
			if (_connected == value) return;
			_connected = value;
			
			var ce:ConnectionEvent;
			if (_connected)
			{
				log("已连接");
				ce = new ConnectionEvent(ConnectionEvent.CONNECT);
			}
			else
			{
				log("已断开");
				ce = new ConnectionEvent(ConnectionEvent.DISCONNECT);
			}
			dispatchEvent(ce);
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		public function initConnection():void
		{
			sendConnection = new LocalConnection();
			sendConnection.addEventListener(StatusEvent.STATUS, sendConnection_statusHandler);
			
			initReceiveConnection();
			
			// 默认启动心跳机制
			startHearbeat();
			
			// 30s检查一次服务情况
			checkTimer = new Timer(30000);
			checkTimer.addEventListener(TimerEvent.TIMER, checkTimer_timerHandler);
			checkTimer.start();
		}
		
		private function initReceiveConnection():void
		{
			try
			{
				receiveConnection = new LocalConnection();
				receiveConnection.connect(receiveConnectionName);
				receiveConnection.client = this;
				receiveConnection.allowDomain("*");
				receiveConnectionOK = true;
				log("启动服务成功");
			} 
			catch(error:Error) 
			{
				receiveConnectionOK = false;
				log("启动服务失败," + error.message);
			}
		}
		
		private function checkTimer_timerHandler(e:TimerEvent):void
		{
			if (!receiveConnectionOK)
			{
				log("服务异常,开始重启");
				initReceiveConnection();
			}
		}
		
		public function dispose():void
		{
			try
			{
				if (receiveConnection)
					receiveConnection.close();
				
				log("关闭服务成功");
			} 
			catch(error:Error) 
			{
				log("关闭服务失败," + error.message);
			}
			
			receiveConnectionOK = false;
			
			stopHearbeat();
			
			checkTimer.removeEventListener(TimerEvent.TIMER, checkTimer_timerHandler);
			checkTimer.stop();
			checkTimer = null;
		}
		
		/**
		 * 发消息
		 * @param messageType ClientMessageType
		 * @param messageContent
		 */		
		public function sendMessage(messageType:String, messageContent:* = ""):void
		{
			var message:Message = new Message();
			message.messageType = messageType;
			message.messageContent = messageContent;
			sendingMessages.push(message);
			
			loopSendMessage();
		}
		
		private function loopSendMessage():void
		{
			// 消息正在发送中 返回
			if (sendingMessage)
				return;
			
			// 消息队列没有需要发送的消息 返回
			if (sendingMessages.length == 0)
				return;
			
			// 发送头一个消息
			sendingMessage = sendingMessages.shift();
			
			// 发送消息
			sendConnection.send(sendConnectionName, "receiveMessage",
				sendingMessage.messageType, sendingMessage.messageContent);
			
			if(sendingMessage.messageType != ClientMessageType.CONNECTION_HEARBEAT &&
				sendingMessage.messageType != ClientMessageType.CONNECTION_HEARBEAT_RESPONSE)
				log("发送消息: " + JSON.stringify(sendingMessage));
		}
		
		/**
		 * 收到消息
		 */		
		public function receiveMessage(messageType:String, messageContent:*):void
		{
			var message:Message = new Message();
			message.messageType = messageType;
			message.messageContent = messageContent;
			
			if (message.messageType == ClientMessageType.CONNECTION_HEARBEAT_RESPONSE)
			{
				// 接收到心跳消息响应 才能判断为连接成功
				receiveHeartbeatResponseMessage(message);
			}
			else if (message.messageType == ClientMessageType.CONNECTION_HEARBEAT)
			{
				sendMessage(ClientMessageType.CONNECTION_HEARBEAT_RESPONSE, "");
			}
			else
			{
				log("接收消息: " + JSON.stringify(message));
				var ce:ConnectionEvent = new ConnectionEvent(ConnectionEvent.RECEIVE_MESSAGE);
				ce.message = message;
				dispatchEvent(ce);
			}
		}
		
		protected function sendConnection_statusHandler(event:StatusEvent):void
		{
			switch (event.level) 
			{  
				case "error": 
				{
					// 如果发送的 非心跳包 且 非心跳响应包 失败，给出日志输出
					if(sendingMessage.messageType != ClientMessageType.CONNECTION_HEARBEAT &&
						sendingMessage.messageType != ClientMessageType.CONNECTION_HEARBEAT_RESPONSE)
						log("发送消息: 失败");
					break;  
				}
				default :
				{
					break;
				}
			}
			
			sendingMessage = null;
			loopSendMessage();
		}	
		
		
		//--------------------------------------------------------------------------
		//
		//  心跳逻辑代码
		//
		//--------------------------------------------------------------------------
		
		private var _heartbeatTimer:Timer;
		
		private function get heartbeatTimer():Timer
		{
			if (!_heartbeatTimer)
			{
				_heartbeatTimer = new Timer(heartbeatInterval);
				_heartbeatTimer.addEventListener(TimerEvent.TIMER, heartbeatTimer_TimerHandler);
			}
			
			return _heartbeatTimer;
		}
		
		/**
		 * 开始心跳
		 */		
		protected function startHearbeat():void
		{
			if (!heartbeatTimer.running)
			{
				//				log("心跳启动");
				heartbeatTimer.start();
				heartbeatTimer_TimerHandler(null);
			}
		}
		
		/**
		 * 停止心跳 
		 */		
		protected function stopHearbeat():void
		{
			if (_heartbeatTimer && _heartbeatTimer.running)
			{
				//				log("心跳停止");
				_heartbeatTimer.stop();
				_heartbeatTimer.reset();
			}
		}
		
		private function heartbeatTimer_TimerHandler(event:TimerEvent):void
		{
			// 心跳没有被响应 判定为断开
			if (!hearbeatIsResponed)
				connected = false;
			
			hearbeatIsResponed = false;
			sendMessage(ClientMessageType.CONNECTION_HEARBEAT, "");
		}
		
		/**
		 * 接收到心跳响应消息 
		 * @param message
		 */		
		private function receiveHeartbeatResponseMessage(message:Message):void
		{
			hearbeatIsResponed = true;
			connected = true;
		}
		
		
		//--------------------------------------------------------------------------------------------
		//
		//  日志
		//
		//--------------------------------------------------------------------------------------------
		
		/**
		 * 输出日志
		 * @param args
		 */		
		protected function log(...args):void
		{
			var arg:Array = args as Array;
			if (arg.length > 0)
			{
				arg[0] = "[LocalConnection通信服务] " + arg[0];
				var ce:ConnectionEvent = new ConnectionEvent(ConnectionEvent.LOG_MESSAGE);
				ce.descript = args.join(" ");
				dispatchEvent(ce);
			}
		}
		
		
	}
}