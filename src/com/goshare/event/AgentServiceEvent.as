package com.goshare.event
{
	import com.goshare.data.Message;
	
	import flash.events.Event;
	
	public class AgentServiceEvent extends Event
	{
		
		/**
		 * 连接Mina服务器成功的时候派发 
		 */		
		public static const MINA_CONNECT:String = "minaServerConnect";
		
		/**
		 * 与Mina服务器正常断开连接的时候派发 
		 */		
		public static const MINA_DISCONNECT:String = "minaServerDisconnect";
		
		/**
		 * 与Mina服务器连接错误的时候派发
		 */		
		public static const MINA_ERROR:String = "minaServerError";
		
		/**
		 * 与Mina服务器收不到心跳响应的时候派发 
		 */		
		public static const MINA_HEARBEAT_ERROR:String = "minaServerHearBeatError";
		
		/**
		 * 收到Mina服务器数据的时候派发 
		 */		
		public static const MINA_MESSAGE:String = "minaServerMessage";
		
		
		/**
		 * 连接FMS服务器成功的时候派发 
		 */		
		public static const FMS_CONNECT:String = "fmsServerConnect";
		
		/**
		 * 与FMS服务器断开连接的时候派发 
		 */		
		public static const FMS_DISCONNECT:String = "fmsServerDisconnect";
		
		/**
		 * 与FMS服务器连接错误的时候派发
		 */		
		public static const FMS_ERROR:String = "fmsServerError";
		
		/**
		 * 收到FMS服务器数据的时候派发 
		 */		
		public static const FMS_MESSAGE:String = "fmsServerMessage";
		
		/**
		 * 有日志的时候派发 
		 */		
		public static const LOG_MESSAGE:String = "logMessage";
		
		/**
		 * FMS服务器重连成功
		 */		
		public static const FMS_SERVER_RECONNECT_SUCCESS:String = "fmsserverReconnectSuccess";
		
		public function AgentServiceEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		/**
		 * 消息说明 
		 */		
		public var descript:String;
		
		/**
		 * 消息数据 
		 */		
		public var message:Message;
	}
}