package com.goshare.data
{
	public class MessageType	
	{
		/**
		 * 通知空闲坐席
		 */
		public static const S001:String = "S001";
		/**
		 * 坐席繁忙
		 */
		public static const S002:String = "S002";
		/**
		 * 请求已被接听
		 */
		public static const S003:String = "S003";
		/**
		 * 消息转发
		 */
		public static const S004:String = "S001";
		/**
		 * 连接超时
		 */
		public static const S005:String = "S022";
		/**
		 * 成员类型错误
		 */
		public static const S006:String = "S023";
		/**
		 * 未知消息类型
		 */
		public static const S007:String = "S024";
		/**
		 * 通知挂断
		 */
		public static const S008:String = "S008";
		/**
		 * 此房间不存在
		 */
		public static const S009:String = "S009";
		/**
		 * 此房间已满
		 */
		public static const S010:String = "S010";
		/**
		 * 登录失败
		 */
		public static const S011:String = "S020";
		/**
		 * 请求协助超时
		 */
		public static const S012:String = "S012";
		/**
		 * 重复登陆
		 */
		public static const S013:String = "S013";
		/**
		 * 非正常断开
		 */
		public static const S014:String = "S014";
		/**
		 * 请求已被其他座席接听
		 */
		public static const S015:String = "S015";
		/**
		 * 缺少必要字段
		 */
		public static const S016:String = "S002";
		/**
		 * 终端（终端）不存在
		 */
		public static const S017:String = "S025";
		/**
		 * 长时间无消息传输（不包括心跳信息）
		 */
		public static const S018:String = "S018";
		/**
		 * 系统异常
		 */
		public static const S019:String = "S026";
		/**
		 * 终端在其他地方发起请求 
		 */		
		public static const S020:String = "S021";
		/**
		 * 心跳包无效（在连接C001 Z001包之前发送是无效的） 
		 */		
		public static const S021:String = "S027";
		/**
		 * 系统公告指令 
		 */		
		public static const S022:String = "S122";
		
		/**
		 * 终端状态包指令 
		 */		
		public static const S023:String = "S102";
		
		/**
		 * 坐席状态包指令 
		 */		
		public static const S024:String = "S201";
		
		/**
		 * 申请委托指令 
		 */		
		public static const S025:String = "S125";
		
		/**
		 * 终止委托指令 
		 */		
		public static const S026:String = "S126";
		
		/**
		 * 申请终止委托 
		 */		
		public static const S027:String = "S127";
		
		/**
		 * 接受委托 
		 */		
		public static const S028:String = "S128";
		
		/**
		 * 拒绝终止委托 
		 */		
		public static const S030:String = "S030";
		
		/**
		 * 该委托已被接受 
		 */		
		public static const S034:String = "S034";
		
		/**
		* 服务器推送终端工作时间的指令
		* */
		public static const S029:String = "S029";
		
		/**
		 * 半人工功能信息（推荐问）
		 */
		public static const S033:String = "S033";
		
		/**
		 * 坐席登录
		 */
		public static const Z001:String = "Z001";
		/**
		 * 座席接听
		 */
		public static const Z002:String = "Z002";
		/**
		 * 座席端消发送消息给终端
		 */
		public static const Z003:String = "Z002";
		/**
		 * 座席端消发送消息给坐席
		 */
		public static const Z004:String = "Z104";
		/**
		 * 坐席注销
		 */
		public static const Z005:String = "Z004";
		/**
		 * 座席转接
		 */
		public static const Z006:String = "Z006";
		/**
		 * 坐席状态切换 status==00 在线 status==01 离开
		 */		
		public static const Z007:String = "Z007";
		/**
		 * 用户请求协助
		 */
		public static const C001:String = "C001";
		/**
		 * 终端发送消息给坐席
		 */
		public static const C003:String = "C002";
		/**
		 * 终端发送消息给终端
		 */
		public static const C004:String = "C003";
		/**
		 * 心跳
		 */
		public static const HEARTBEAT:String = "6666";
		/**
		 * 接受消息成功
		 */
		public static const RECEIVED_SUCCESS:String = "0000";
		
		/**
		 * 坐席登录   确认报文
		 */
		public static const S100:String = "S100";
		/**
		 * 座席接听   确认报文
		 */
		public static const S902:String = "S902";
		/**
		 * 座席端消息请求   确认报文
		 */
		public static const S903:String = "S903";
		/**
		 * 坐席挂断会话   确认报文
		 */
		public static const S904:String = "S904";
		/**
		 * 坐席注销   确认报文
		 */
		public static const S905:String = "S101";
		/**
		 * 座席转接   确认报文
		 */
		public static const S906:String = "S906";
		/**
		 * 坐席状态切换 确认报文 
		 */		
		public static const S907:String = "S907";
		/**
		 * 用户请求协助   确认报文
		 */
		public static const S201:String = "S201";
		/**
		 * 终端端消息请求   确认报文
		 */
		public static const S803:String = "S803";
		/**
		 * 心跳   确认报文
		 */
		public static const S000:String = "S000";
		
	}
}