package com.goshare.event
{
	import com.goshare.data.Entrust;
	import com.goshare.data.Message;
	import com.goshare.data.Status;
	
	import flash.events.Event;
	
	public class AgentManagerEvent extends Event
	{
		
		/**
		 * 客户端登录成功的时候派发
		 */		
		public static const CLIENT_LOGIN:String = "clientLogin";
		/**
		 * 客户端登录失败的时候派发
		 */		
		public static const CLIENT_LOGIN_FAIL:String = "clientLoginFail";
		
		/**
		 * 客户端退出登录的时候派发 
		 */		
		public static const CLIENT_LOGOUT:String = "clientLogout";
		
		/**
		 * 收到客户端消息的时候派发 
		 */		
		public static const CLIENT_MESSAGE:String = "clientMessage";
		
		/**
		 * 客户端状态发生变化的时候派发 
		 */		
		public static const CLIENT_STATUS:String = "clientStatus";
		
		/**
		 * 客户端委托发生变化的时候派发 
		 */		
		public static const CLIENT_ENTRUST:String = "clientEntrust";
		
		/**
		 * 心跳异常的时候派发 
		 */		
		public static const HEAR_BEAT_ERROR:String = "hearBeatError";
		
		/**
		 * 有系统错误的时候派发 
		 */		
		public static const SYSTEM_ERROR:String = "systemError";
		
		/**
		 * 有系统通知的时候派发 
		 */		
		public static const SYSTEM_NOTICE:String = "systemNotice";
		
		/**
		 * 有日志消息的时候派发 
		 */		
		public static const LOG_MESSAGE:String = "logMessage";
		
		
		/**
		 *有推荐问的情况 （半人工）
		 */
		public static const RECOMMEND_QS : String= "recommendQs";
		
		/**
		 * FMS连接异常断开事件
		 */
		public static const FMS_DISCONNECT_UNNORMALEVENT : String= "fmsDisconnectUnNormalEvent";
		
		/**
		 * FMS连接正常断开事件
		 */
		public static const FMS_DISCONNECT_NORMAL_EVENT : String= "fmsDisconnectNormalEvent";
		
		/**
		 * FMS正常建立连接事件
		 */
		public static const FMS_CONNECT_EVENT : String= "fmsConnectEvent";
		
		/**
		 * FMS连接已恢复事件
		 */
		public static const FMS_RECONNECT_EVENT : String= "fmsReconnectEvent";
		
		public function AgentManagerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public var status:Status;
		public var entrust:Entrust;
		public var message:Message;
		public var descript:String;
		public var obj:Object;
		
	}
}