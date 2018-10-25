package com.goshare.connection
{
	import com.goshare.data.ClientMessageType;
	
	/**
	 *
	 * 终端连接
	 * 
	 * 用于跟代理端通信
	 *  
	 * @author coco 
	 * 
	 */	
	public class C1Connection extends Connection
	{
		public function C1Connection()
		{
			super();
			
			if (instance || !inRightWay)
				throw new Error("Please use C1Connection.getInstance()");
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Get Instance
		//
		//--------------------------------------------------------------------------
		
		private static var inRightWay:Boolean = false;
		private static var instance:C1Connection;
		
		public static function getInstance():C1Connection
		{
			inRightWay = true;
			
			if (!instance)
				instance = new C1Connection();
			
			return instance;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 初始化 
		 *  
		 * @param username 用户名
		 * @param password 密码
		 * @param version  版本号
		 * @param clienttype 客户端类型
		 * 
		 */		
		public function init(username:String, password:String, version:String, clienttype:String):void
		{
			sendConnectionName = "_com.tangdi.agentConnection";
			receiveConnectionName = "_com.tangdi.robotConnection";
			initConnection();
			
			// 初始化默认发送登录信息
			sendMessage(ClientMessageType.ROBOT_LOGIN, {username:username,
				password:password, 
				version:version,
				clienttype: clienttype});
		}
		
	}
}