package com.goshare.service
{
	import com.goshare.event.MinaServerEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	
	[Event(name="minaServerConnect", type="com.goshare.event.MinaServerEvent")]
	
	[Event(name="minaServerDisconnect", type="com.goshare.event.MinaServerEvent")]
	
	[Event(name="minaServerError", type="com.goshare.event.MinaServerEvent")]
	
	[Event(name="minaServerData", type="com.goshare.event.MinaServerEvent")]
	
	
	/**
	 *
	 * Mina服务器 服务类
	 *  
	 * @author coco
	 */	
	public class MinaServerService extends EventDispatcher
	{
		public function MinaServerService(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Get Instance
		//
		//--------------------------------------------------------------------------
		
		private static var instance:MinaServerService;
		
		public static function getInstance():MinaServerService
		{
			if (!instance)
				instance = new MinaServerService();
			
			return instance;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		private var serverSocket:Socket;
		
		/**
		 * Mina服务器连接状态
		 * @return 
		 */		
		public function get connected():Boolean
		{
			return serverSocket && serverSocket.connected;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 连接Mina服务器
		 *  
		 * @param host 服务器地址
		 * @param port 服务器端口
		 * 
		 */		
		public function connect(host:String, port:int):void
		{
			clearSocket(serverSocket); 
			serverSocket = new Socket();
			addSocketHandler(serverSocket);
			serverSocket.connect(host, port);
		}
		
		/**
		 *	断开与Mina服务器的连接 
		 */		
		public function disconnect():void
		{
			if (serverSocket && serverSocket.connected)
				serverSocket.close();
		}
		
		/**
		 * 
		 * 给Mina服务器发送消息
		 *  
		 * @param message json string
		 * 
		 */		
		public function send(message:String):void
		{
			if (!serverSocket || !serverSocket.connected)
			{
				var mse:MinaServerEvent = new MinaServerEvent(MinaServerEvent.ERROR);
				mse.descript = "发送失败，Mina服务器未连接";
				return;
			}
			
			var messageBytes:ByteArray = new ByteArray();
			messageBytes.writeUTFBytes(message);
			
			var packetLength:int = messageBytes.length;
			var packetLengthString:String = packetLength.toString();
			while (packetLengthString.length < 8)
			{
				packetLengthString = "0" + packetLengthString;
			}
			serverSocket.writeUTFBytes(packetLengthString);
			serverSocket.writeBytes(messageBytes);
			serverSocket.flush();
		}
		
		/**
		 *
		 * 添加socket事件
		 *  
		 * @param socket
		 * 
		 */		
		private function addSocketHandler(socket:Socket):void
		{
			if (socket)
			{
				socket.addEventListener(Event.CONNECT, serverSocket_connectHnalder);
				socket.addEventListener(Event.CLOSE, serverSocket_closeHandler);
				socket.addEventListener(IOErrorEvent.IO_ERROR, serverSocket_ioErrorHandler);
				socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, serverSocket_securityErrorHandler);
				socket.addEventListener(ProgressEvent.SOCKET_DATA, serverSocket_dataHandler);
			}
		}
		
		/**
		 * 
		 * 移除Socket
		 *  
		 * @param socket
		 * 
		 */		
		private function clearSocket(socket:Socket):void
		{
			if (socket)
			{
				socket.removeEventListener(Event.CONNECT, serverSocket_connectHnalder);
				socket.removeEventListener(Event.CLOSE, serverSocket_closeHandler);
				socket.removeEventListener(IOErrorEvent.IO_ERROR, serverSocket_ioErrorHandler);
				socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, serverSocket_securityErrorHandler);
				socket.removeEventListener(ProgressEvent.SOCKET_DATA, serverSocket_dataHandler);
				
				if (socket.connected)
					socket.close();
				
				socket = null;
			}
		}
		
		protected function serverSocket_connectHnalder(event:Event):void
		{
			var mse:MinaServerEvent = new MinaServerEvent(MinaServerEvent.CONNECT);
			mse.descript = "连接成功";
			dispatchEvent(mse);
		}
		
		protected function serverSocket_closeHandler(event:Event):void
		{
			var mse:MinaServerEvent = new MinaServerEvent(MinaServerEvent.DISCONNECT);
			mse.descript = "断开连接";
			dispatchEvent(mse);
		}
		
		protected function serverSocket_ioErrorHandler(event:IOErrorEvent):void
		{
			var mse:MinaServerEvent = new MinaServerEvent(MinaServerEvent.ERROR);
			mse.descript = event.text;
			dispatchEvent(mse);
		}
		
		protected function serverSocket_securityErrorHandler(event:SecurityErrorEvent):void
		{
			var mse:MinaServerEvent = new MinaServerEvent(MinaServerEvent.ERROR);
			mse.descript = event.text;
			dispatchEvent(mse);
		}
		
		protected function serverSocket_dataHandler(event:ProgressEvent):void
		{
			while (serverSocket.bytesAvailable)
			{
				serverSocket.readBytes(bufferBytes, bufferBytes.length);
			}
			processSocketPacket();
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Socket消息包处理部分
		//
		//--------------------------------------------------------------------------
		
		private var bufferBytes:ByteArray = new ByteArray();   // 缓冲区字节
		private var packetBytesLength:int = 0;  			   // 包字节长度
		private var packetBytes:ByteArray; 		               // 包字节
		private var processing:Boolean = false;				   // 包处理中
		
		private function processSocketPacket():void
		{
			if (processing) return;
			processing = true;
			
			// 读包头 当前包头等于0 且 缓存中的可读字节数大于包头的字节数才去读
			if (packetBytesLength == 0 && bufferBytes.bytesAvailable >= 8)
			{
				packetBytesLength = int(bufferBytes.readUTFBytes(8));
				packetBytes = new ByteArray();
			}
			
			// 读包内容 只有内容大于包长度的时候才会去读
			if (packetBytesLength > 0 && bufferBytes.bytesAvailable >= packetBytesLength)
			{
				bufferBytes.readBytes(packetBytes, 0, packetBytesLength);
				processPacket(packetBytes);
				
				// 将剩下的字节读取到新的字节组中
				var newBufferBytes:ByteArray = new ByteArray();
				bufferBytes.readBytes(newBufferBytes);
				bufferBytes.clear();
				newBufferBytes.readBytes(bufferBytes);
				newBufferBytes.clear();
				packetBytesLength = 0;
				processing = false;
				
				// 一个包处理完毕 继续处理下一个
				if (bufferBytes.bytesAvailable > 0)
					processSocketPacket();
			}
			else
			{
				processing = false;
			}
		}
		
		private function processPacket(packetData:ByteArray):void
		{
			// 将包的字节流转换成包的json字符串
			var message:String = packetData.readUTFBytes(packetData.bytesAvailable);
			var mse:MinaServerEvent = new MinaServerEvent(MinaServerEvent.DATA);
			mse.descript = "数据处理成功";
			mse.message = message;
			dispatchEvent(mse);
		}
		
	}
}