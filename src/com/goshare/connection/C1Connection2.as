package com.goshare.connection
{
	import com.goshare.data.Message;
	import com.goshare.data.MessageType;
	import com.goshare.event.AgentServiceEvent;
	import com.goshare.event.ConnectionEvent;
	import com.goshare.service.SocketDataProcesser;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.system.Security;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	[Event(name="connect", type="com.goshare.event.ConnectionEvent")]
	
	[Event(name="disconnect", type="com.goshare.event.ConnectionEvent")]
	
	[Event(name="receiveMessage", type="com.goshare.event.ConnectionEvent")]
	
	[Event(name="logMessage", type="com.goshare.event.ConnectionEvent")]
	
	/**
	 * @author coco
	 */	
	public class C1Connection2 extends SocketDataProcesser
	{
		public function C1Connection2(target:IEventDispatcher=null)
		{
			super(target);
			
			if (instance || !inRightWay)
				throw new Error("Please use C1Connection2.getInstance()");
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Get Instance
		//
		//--------------------------------------------------------------------------
		
		private static var inRightWay:Boolean = false;
		private static var instance:C1Connection2;
		
		public static function getInstance():C1Connection2
		{
			inRightWay = true;
			
			if (!instance)
				instance = new C1Connection2();
			
			return instance;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		public function get connected():Boolean
		{
			return c2Socket && c2Socket.connected;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		private var serverHost:String;
		private var c2Socket:Socket;
		private var checkTimer:Timer;
		
		public function init(username:String, 
							 password:String, 
							 version:String, 
							 clienttype:String, 
							 host:String = "localhost"):void
		{
			// 30s检查一次连接情况
			checkTimer = new Timer(30000);
			checkTimer.addEventListener(TimerEvent.TIMER, checkTimer_timerHandler);
			checkTimer.start();
			
			serverHost = host;
			
			tryLogin();
		}
		
		public function dispose():void
		{
			checkTimer.removeEventListener(TimerEvent.TIMER, checkTimer_timerHandler);
			checkTimer.stop();
			checkTimer = null;
			
			disposeC2Socket();
		}
		
		private function tryLogin():void
		{
			if (!connected)
			{
				initC2Socket();
				log("开始加载策略文件...");
				Security.loadPolicyFile("xmlsocket://" + serverHost + ":12015" );
				log("开始连接C1端服务...");
				c2Socket.connect(serverHost, 12016);
			}
		}
		
		private function checkTimer_timerHandler(e:TimerEvent):void
		{
			if (!connected)
			{
				log("检测到C1端已断开...尝试重新连接");
				tryLogin();
			}
		}
		
		private function initC2Socket():void
		{
			if (!c2Socket)
			{
				c2Socket = new Socket();
				c2Socket.addEventListener(Event.CLOSE, c2Socket_closeHandler);
				c2Socket.addEventListener(ProgressEvent.SOCKET_DATA, c2Socket_dataHandler);
				c2Socket.addEventListener(Event.CONNECT, c2Socket_connectHandler);
				c2Socket.addEventListener(IOErrorEvent.IO_ERROR, c2Socket_ioErrorHandler);
				c2Socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, c2Socket_securityErrorHandler);
			}
		}
		
		private function disposeC2Socket():void
		{
			if (c2Socket)
			{
				try
				{
					c2Socket.removeEventListener(Event.CLOSE, c2Socket_closeHandler);
					c2Socket.removeEventListener(ProgressEvent.SOCKET_DATA, c2Socket_dataHandler);
					c2Socket.removeEventListener(Event.CONNECT, c2Socket_connectHandler);
					c2Socket.removeEventListener(IOErrorEvent.IO_ERROR, c2Socket_ioErrorHandler);
					c2Socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, c2Socket_securityErrorHandler);
					c2Socket.close();
					c2Socket = null;
					//					log("释放C2Socket成功");
				} 
				catch(error:Error) 
				{
					//					log("释放C2Socket失败" + error.message);
				}
			}
		}
		
		protected function c2Socket_connectHandler(event:Event):void
		{
			log("C1端已连接");
			var ce:ConnectionEvent = new ConnectionEvent(ConnectionEvent.CONNECT);
			dispatchEvent(ce);
		}
		
		protected function c2Socket_dataHandler(event:ProgressEvent):void
		{
			while (c2Socket.bytesAvailable)
			{
				c2Socket.readBytes(bufferBytes, bufferBytes.length);
			}
			processSocketPacket();
		}
		
		protected function c2Socket_closeHandler(event:Event):void
		{
			// 释放socket
			disposeC2Socket();
			
			log("C1端已断开");
			var ce:ConnectionEvent = new ConnectionEvent(ConnectionEvent.DISCONNECT);
			dispatchEvent(ce);
		}
		
		protected function c2Socket_securityErrorHandler(event:SecurityErrorEvent):void
		{
			// 释放socket
			disposeC2Socket();
			log("安全错误" + event.text);
		}
		
		protected function c2Socket_ioErrorHandler(event:IOErrorEvent):void
		{
			// 释放socket
			disposeC2Socket();
			log("IO错误 " + event.text);
		}
		
		//--------------------------------------------------------------------------
		//
		//  日志输出
		//
		//--------------------------------------------------------------------------
		
		private function log(...args):void
		{
			var arg:Array = args as Array;
			if (arg.length > 0)
			{
				arg[0] = "[Socket通信服务] " + arg[0];
				var ce:ConnectionEvent = new ConnectionEvent(ConnectionEvent.LOG_MESSAGE);
				ce.descript = args.join(" ");
				dispatchEvent(ce);
			}
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Socket消息包处理部分
		//
		//--------------------------------------------------------------------------
		
		override protected function receiveMessage(messageString:String):void
		{
			var ce:ConnectionEvent;
			try
			{
				// 将json字符串 转换为消息
				//	Message
				//		messaegType
				//		messageContent
				var messageObject:Object = JSON.parse(messageString);
				var message:Message = new Message();
				message.messageType = messageObject.messageType;
				message.messageContent = messageObject.messageContent;
				message.messageTarget = messageObject.messageTarget;
				message.messageSource = messageObject.messageSource;

				ce = new ConnectionEvent(ConnectionEvent.RECEIVE_MESSAGE);
				ce.message = message;
				ce.descript = "接收消息";
				
				log("接收到C1端消息: " + messageString);
			} 
			catch(error:Error)
			{
				log("解析消息包失败 " + message);
				ce = new ConnectionEvent(ConnectionEvent.LOG_MESSAGE);
				ce.descript = error.message;
			}
			
			dispatchEvent(ce);
		}
		
		private function send(message:Message):void
		{
			if (!c2Socket || !c2Socket.connected)
			{
				log("C1端未连接，无法发送消息");
				return;
			}
			
			var messageJsonString:String = JSON.stringify(message);
			if (message.messageType != MessageType.HEARTBEAT)
				log("给C1端发送消息：" + messageJsonString);
			var messageBytes:ByteArray = new ByteArray();
			messageBytes.writeUTFBytes(messageJsonString);
			
			var packetLength:int = messageBytes.length;
			var packetLengthString:String = packetLength.toString();
			while (packetLengthString.length < 8)
			{
				packetLengthString = "0" + packetLengthString;
			}
			c2Socket.writeUTFBytes(packetLengthString);
			c2Socket.writeBytes(messageBytes);
			c2Socket.flush();
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
			send(message);
		}
		
	}
}