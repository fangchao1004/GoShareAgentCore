package com.goshare.connection
{
	import flash.net.LocalConnection;
	
	
	/**
	 *
	 * 代理连接
	 * 
	 * 用于跟终端端通信
	 *  
	 * @author coco
	 * 
	 */	
	public class C2Connection extends Connection
	{
		
		private var receiveConnection:LocalConnection;
		
		public function C2Connection()
		{
			super();
			
			if (instance || !inRightWay)
				throw new Error("Please use C2Connection.getInstance()");
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Get Instance
		//
		//--------------------------------------------------------------------------
		
		private static var inRightWay:Boolean = false;
		private static var instance:C2Connection;
		
		public static function getInstance():C2Connection
		{
			inRightWay = true;
			
			if (!instance)
				instance = new C2Connection();
			
			return instance;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		public function init():void
		{
			sendConnectionName = "_com.tangdi.robotConnection";
			receiveConnectionName = "_com.tangdi.agentConnection";
			initConnection();
		}
		
	}
}