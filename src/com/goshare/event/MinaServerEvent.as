package com.goshare.event
{
	import flash.events.Event;
	
	
	/**
	 * Mina服务器事件
	 *  
	 * @author coco
	 * 
	 */	
	public class MinaServerEvent extends Event
	{
		
		/**
		 * 连接Mina服务器成功的时候派发 
		 */		
		public static const CONNECT:String = "minaServerConnect";
		
		/**
		 * 与Mina服务器断开连接的时候派发 
		 */		
		public static const DISCONNECT:String = "minaServerDisconnect";
		
		/**
		 * 与Mina服务器连接错误的时候派发
		 */		
		public static const ERROR:String = "minaServerError";
		
		/**
		 * 收到Mina服务器数据的时候派发 
		 */		
		public static const DATA:String = "minaServerData";
		
		
		public function MinaServerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		/**
		 * 消息数据
		 */		
		public var message:String;
		
		/**
		 * 消息说明 
		 */		
		public var descript:String;
		
	}
}