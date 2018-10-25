package com.goshare.data
{
	
	/**
	 * 委托的数据 
	 * @author coco
	 */	
	public class EntrustType
	{
		public static const ENTRUST_REQUESTED:String = "entrustRequested"; // 委托请求
		public static const ENTRUST_ACCEPTED:String = "entrustAccepted"; // 接收委托
		public static const ENTRUST_STOP_REQUESTED:String = "entrustStopRequested"; // 停止委托请求
		public static const ENTRUST_STOPED:String = "entrustStoped"; // 委托停止
		public static const ENTRUST_STOP_REQUESTED_REJECTED:String = "entrustStopRequestedRejected"; // 停止委托请求被拒绝
		public static const ENTRUST_BEEN_ACCEPTED_BY_OHTERS:String = "entrustBeenAcceptedByOthers"; // 该委托已被其他用户接受
	}
}