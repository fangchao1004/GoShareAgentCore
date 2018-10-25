package com.goshare.data
{
	
	/**
	 * 委托的数据 
	 * @author coco
	 */	
	public class Entrust
	{
		public var type:String; // 委托类型
		public var serialNo:String; // 流水号
		public var principle:String; // 委托者
		public var termId:String; // 委托的终端ID
		public var descript:String; // 委托说明
		public var termList:Array; // 委托的终端列表
		public var mandatary:String; // 已经接受委托的代理人
	}
}