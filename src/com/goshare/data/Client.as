package com.goshare.data
{
	
	/**
	 * 客户端数据 
	 * @author coco
	 * 
	 */	
	public class Client
	{
		
		public var id:String; // 客户端id 
		public var version:String; // 客户端版本号
		public var online:Boolean = false; // 客户端是否在线
		public var classInfo:String; // 客户端班级号
		public var name:String; // 客户端命名
	}
}