package com.goshare.data
{
	
	/**
	 *
	 * 服务器通信协议包
	 *  
	 * @author coco
	 * 
	 */	
	public class Message
	{
		/**
		 * 消息类型 
		 * 
		 * @see com.tangdi.data.MessageType
		 */		
		public var messageType:String;
		
		/**
		 * 消息内容 
		 */		
		public var messageContent:*;
		
		/**
		 * 消息要发送的目标
		 */		
		public var messageTarget:String;
		
		/**
		 * 消息来源 
		 */		
		public var messageSource:String;
		
		/**
		 * 消息请求流水号
		 */		
		public var flowNo:String = (new Date()).getTime() + "" + int(Math.random() * 1000);
		
	}
}