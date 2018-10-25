package com.goshare.event
{
	import com.goshare.data.Message;
	
	import flash.events.Event;
	
	public class ConnectionEvent extends Event
	{
		
		/**
		 * 连接成功的时候派发 
		 */		
		public static const CONNECT:String = "connect";
		/**
		 * 断开连接的时候派发 
		 */		
		public static const DISCONNECT:String = "disconnect";
		/**
		 * 收到消息的时候派发 
		 */		
		public static const RECEIVE_MESSAGE:String = "receiveMessage";
		/**
		 * 有日志消息的时候派发 
		 */		
		public static const LOG_MESSAGE:String = "logMessage";
		
		public function ConnectionEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public var message:Message;
		
		public var descript:String;
		
	}
}