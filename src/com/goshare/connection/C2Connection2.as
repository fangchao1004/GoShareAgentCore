package com.goshare.connection
{
	import com.goshare.data.Message;
	import com.goshare.data.MessageType;
	import com.goshare.event.ConnectionEvent;
	import com.goshare.service.SocketDataProcesser;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.events.TimerEvent;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	[Event(name="connect", type="com.goshare.event.ConnectionEvent")]
	
	[Event(name="disconnect", type="com.goshare.event.ConnectionEvent")]
	
	[Event(name="receiveMessage", type="com.goshare.event.ConnectionEvent")]
	
	[Event(name="logMessage", type="com.goshare.event.ConnectionEvent")]
	
	/**
	 * @author coco
	 */	
	public class C2Connection2 extends SocketDataProcesser
	{
		public function C2Connection2(target:IEventDispatcher=null)
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
		private static var instance:C2Connection2;
		
		public static function getInstance():C2Connection2
		{
			inRightWay = true;
			
			if (!instance)
				instance = new C2Connection2();
			
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
		
		private var c1Socket:ServerSocket;
		private var c1PolicySocket:ServerSocket;
		private var c2Socket:Socket;
		private var checkTimer:Timer;
		
		public function init():void
		{
			initC1PolicySocket();
			initC1Socket();
			
			// 30s检查一次服务情况
			checkTimer = new Timer(30000);
			checkTimer.addEventListener(TimerEvent.TIMER, checkTimer_timerHandler);
			checkTimer.start();
		}
		
		public function dispose():void
		{
			checkTimer.removeEventListener(TimerEvent.TIMER, checkTimer_timerHandler);
			checkTimer.stop();
			checkTimer = null;
			
			disposeC2Socket();
			disposeC1Socket();
			disposeC1PolicySocket();
		}
		
		protected function checkTimer_timerHandler(event:TimerEvent):void
		{
			if (!c1PolicySocket || !c1PolicySocket.listening)
			{
				log("策略服务异常,开始重启");
				initC1PolicySocket();
			}
			
			if (!c1Socket || !c1Socket.listening)
			{
				log("服务异常,开始重启");
				initC1Socket();
			}
		}
		
		private function initC1PolicySocket():void
		{
			try
			{
				// 开启策略服务
				c1PolicySocket = new ServerSocket();
				c1PolicySocket.addEventListener(ServerSocketConnectEvent.CONNECT, c1PolicySocket_connectHandler);
				c1PolicySocket.bind(12015);
				c1PolicySocket.listen();
				log("启动策略服务成功");
			} 
			catch(error:Error) 
			{
				log("启动策略服务失败," + error.message);
			}
		}
		
		private function disposeC1PolicySocket():void
		{
			if (c1PolicySocket)
			{
				try
				{
					c1PolicySocket.removeEventListener(ServerSocketConnectEvent.CONNECT, c1PolicySocket_connectHandler);
					c1PolicySocket.close();
					c1PolicySocket = null;
					log("关闭策略服务成功");
				} 
				catch(error:Error) 
				{
					log("关闭策略服务失败," + error.message);
				}
			}
		}
		
		private function initC1Socket():void
		{
			try
			{
				c1Socket = new ServerSocket();
				c1Socket.addEventListener(ServerSocketConnectEvent.CONNECT, c1Socket_connectHandler);
				c1Socket.addEventListener(Event.CLOSE, c1Socket_closeHandler);
				c1Socket.bind(12016);
				c1Socket.listen();
				log("启动服务成功");
			} 
			catch(error:Error) 
			{
				log("启动服务失败," + error.message);
			}
		}
		
		private function disposeC1Socket():void
		{
			if (c1Socket)
			{
				try
				{
					c1Socket.removeEventListener(ServerSocketConnectEvent.CONNECT, c1Socket_connectHandler);
					c1Socket.removeEventListener(Event.CLOSE, c1Socket_closeHandler);
					c1Socket.close();
					c1Socket = null;
					log("关闭服务成功");
				} 
				catch(error:Error) 
				{
					log("关闭服务失败," + error.message);
				}
			}
		}
		
		private function initC2Socket():void
		{
			c2Socket.addEventListener(Event.CLOSE, c2Socket_closeHandler);
			c2Socket.addEventListener(ProgressEvent.SOCKET_DATA, c2Socket_dataHandler);
			c2Socket.addEventListener(IOErrorEvent.IO_ERROR, c2Socket_ioErrorHandler);
			c2Socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, c2Socket_securityErrorHandler);
			
			var ce:ConnectionEvent = new ConnectionEvent(ConnectionEvent.CONNECT);
			dispatchEvent(ce);
			log("已连接");
		}
		
		private function disposeC2Socket():void
		{
			if (c2Socket)
			{
				try
				{
					c2Socket.removeEventListener(Event.CLOSE, c2Socket_closeHandler);
					c2Socket.removeEventListener(ProgressEvent.SOCKET_DATA, c2Socket_dataHandler);
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
				
				var ce:ConnectionEvent = new ConnectionEvent(ConnectionEvent.DISCONNECT);
				dispatchEvent(ce);
				log("已断开");
			}
		}
		
		protected function c1Socket_connectHandler(event:ServerSocketConnectEvent):void
		{
			disposeC2Socket();
			c2Socket = event.socket;
			initC2Socket();
		}
		
		protected function c2Socket_dataHandler(event:ProgressEvent):void
		{
			while (c2Socket.bytesAvailable)
			{
				c2Socket.readBytes(bufferBytes, bufferBytes.length);
			}
			processSocketPacket();
		}
		
		protected function c1Socket_closeHandler(event:Event):void
		{
			disposeC1Socket();
		}
		
		protected function c2Socket_closeHandler(event:Event):void
		{
			disposeC2Socket();
		}
		
		protected function c2Socket_securityErrorHandler(event:SecurityErrorEvent):void
		{
			log("安全错误," + event.text);
		}
		
		protected function c2Socket_ioErrorHandler(event:IOErrorEvent):void
		{
			log("IO错误," + event.text);
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
		private var filterCount:int=0; // 坐标发送信息计数器 (日志频繁打印过滤用)
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
				
				if(message.messageType != "TEST_MAP_POS_LINK"){
					log("接收消息: " + messageString);
				}else{
					filterCount++;
					if(filterCount >= 30){
						log("接收消息: " + messageString);
						filterCount=0;
					}
				}
			} 
			catch(error:Error)
			{
				log("接收消息: 解析消息包失败," + messageString);
				ce = new ConnectionEvent(ConnectionEvent.LOG_MESSAGE);
				ce.descript = error.message;
			}
			
			dispatchEvent(ce);
		}
		
		private function send(message:Message):void
		{
			if (!c2Socket || !c2Socket.connected)
			{
				log("服务断开, 无法发送消息");
				return;
			}

			var messageJsonString:String = JSON.stringify(message);
			if (message.messageType != MessageType.HEARTBEAT)
				log("发送消息: " + messageJsonString);
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
		
		
		//--------------------------------------------------------------------------
		//
		//  请求策略文件
		//
		//--------------------------------------------------------------------------
		
		private var policyFile:String =
			'<cross-domain-policy>' +
			'<site-control permitted-cross-domain-policies="master-only"/>' +
			'<allow-access-from domain="*" to-ports="12016"/>' +
			'</cross-domain-policy> ';
		
		private var policySocket:Socket;
		
		protected function c1PolicySocket_connectHandler(event:ServerSocketConnectEvent):void
		{
			log("收到策略请求");
			policySocket = event.socket;
			policySocket.addEventListener(ProgressEvent.SOCKET_DATA, policySocket_dataHandler);
		}
		
		protected function policySocket_dataHandler(event:ProgressEvent):void
		{
			var data:String;
			while (policySocket.bytesAvailable)
			{
				data= policySocket.readUTFBytes(policySocket.bytesAvailable);
			}
			
			if (data == "<policy-file-request/>")
			{
				log("回发策略数据")
				policySocket.writeUTFBytes(policyFile);
				policySocket.flush();
				policySocket.close();
			}
		}
		
	}
}