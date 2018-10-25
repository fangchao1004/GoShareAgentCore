package com.goshare.data
{
	
	/**
	 *
	 * 客户端间传递的数据命令
	 *  
	 * @author coco
	 * 
	 */	
	public class ClientMessageType
	{
		/**
		 * 获取终端当前位置
		 * **/
		public static const ROBOT_LOCATION:String = "robotLocation";
		/**
		 * 启停语音识别 
		 */		
		public static const ZASR:String = "ZASR";
		
		/**
		 * 语音播报 
		 * messageContent=0 停止语音播报
		 */		
		public static const ZTTS:String = "ZTTS";
		
		/**
		 * 人工坐席参与指令  
		 * messageContent=0 参与 
		 */		
		public static const ZXFW:String = "ZXFW";
		
		/**
		 * 切换表情指令  
		 * messageContent 代表表情ID
		 */		
		public static const FACEID:String = "faceid";
		
		/**
		 * 进入应用
		 * messageContent 代表应用ID
		 */		
		public static const MENUID:String = "menuid";
		
		/**
		 * 控制业务流程指令
		 */		
		public static const SERVICE:String = "service";
		
		/**
		 * 返回首页指令
		 */		
		public static const APPINDEX:String = "appIndex";
		
		/**
		 * 广告提示
		 * messageContent=1 弹出广告
		 * messageContent=2 隐藏广告
		 * messageContent=3 下一页广告
		 * messageContent=4 上一页广告
		 */		
		public static const TIPS:String = "tips";
		
		/**
		 * 切换全人工半人工模式指令  
		 * messageContent=0 参与 
		 */		
		public static const ZXFM:String = "ZXFM";
		
		//------------------------------------------------------------------------------------------
		//	终端行走指令
		//------------------------------------------------------------------------------------------
		/**
		 * 终端移动
		 * messageContent=0 停止移动
		 * messageContent=1 前移
		 * messageContent=2 后移
		 * messageContent=3 左移
		 * messageContent=4 右移
		 * messageContent=5 左转
		 * messageContent=6 右转
		 */		
		public static const ROBOT_MOVE:String = "robotMove";
		
		/**
		 * 给终端端发送语音消息的指令 终端端会语音播放这个消息的内容
		 */		
		public static const VOICE:String = "voice";
		
		/**
		 * 传递NLP消息
		 * */
		public static const NLP:String = "nlp";
		
		/**
		 * 播放媒体指令 
		 */		
		public static const AD:String = "AD";
		
		
		//------------------------------------------------------------------------------------------
		//	终端指令集合
		//------------------------------------------------------------------------------------------
		/**
		 * 终端登录指令
		 */
		public static const ROBOT_LOGIN:String = "robotLogin"; // 终端登录指令
		
		/**
		 * 终端打开视频指令
		 * messageContent : {streamName : "", camEnabled : true, micEnabled : true}
		 */	
		/**
		 * 收到客户端消息请求打开视频流
		 */
		public static const OPEN_C1_VIDEO:String = "robotOpenVideoStream";
		public static const OPEN_C1_AUDIO:String = "openC1Audio";
		public static const SWITCH_C1_VIDEO_PROFILE:String = "switchC1VideoProfile";
		/**
		 * 收到客户端消息请求关闭视频流
		 */
		public static const CLOSE_C1_VIDEO:String = "robotCloseVideoStream";
		public static const CLOSE_C1_AUDIO:String = "closeC1Audio";
		public static const OPEN_C1_VOICE:String = "openC1Voice";
		public static const CLOSE_C1_VOICE:String = "closeVoice";
		/**
		 * 打开C1 远程控制
		 */
		public static const OPEN_C1_REMOTE:String = "openC1Remote";
		public static const CLOSE_C1_REMOTE:String = "closeC1Remote";
		public static const C1_REMOTE_MOUSEEVENT:String = "C1RemoteMouseevent";
		public static const OPEN_Z_VIDEO:String = "robotOpenZVideoStream";
		public static const CLOSE_Z_VIDEO:String = "robotCloseZVideoStream";
		public static const REQUEST_C2_CAMERA_PERMISSION:String = "robotOpenVideoStream";
		public static const REQUEST_C2_CAMERA_PERMISSION_SUCCESS:String = "robotOpenVideoStreamSuccess";
		public static const REQUEST_C2_CAMERA_PERMISSION_FAULT:String = "robotOpenVideoStreamFault";
		public static const DISPOSE_C2_CAMERA_PERMISSION:String = "robotCloseVideoStream";
		/**
		 * C2 请求协助
		 */
		public static const ROBOT_REQUEST_SEAT_HELP:String = "robotRequestSeatHelp";   // C2 请求协助
		/**
		 * C2  取消协助
		 */
		public static const ROBOT_REQUEST_SEAT_OVER:String = "robotRequestSeatOver";   // C2  取消协助
		/**
		 * 视频控制终端行走
		 */
		public static const  ROBOT_MOVE_BY_VIDEO_CLICK:String = "robotMoveByVideoClick";//视频控制终端行走
		/**
		 * 声网模式下旋转video内容
		 */
		public static const TELE_C1_VIDEO_ROTATE:String = "teleVideoRotate";//声网模式下旋转video内容
		/**
		 * 旋转video成功后通知z端
		 */
		public static const TELE_C1_VIDEO_ROTATE_SUCCESS:String = "teleVideoRotateSuccess"; //旋转video成功后通知z端
		/**
		 * 声网模式下打开audio
		 */
		public static const  TELE_OPEN_C1_AUDIO:String = "teleOpenAudio";//声网模式下打开audio
		public static const  TELE_CLOSE_C1_AUDIO:String = "teleCloseAudio";//声网模式下关闭audio
		/**
		 * 声网模式下打开或关闭video
		 */
		public static const  TELE_OPEN_CLOSE_C1_VIDEO:String = "teleOpenCloseVideo";//声网模式下打开或关闭video
		public static const  TELE_OPEN_CLOSE_C1_VIDEO_SUCCESS:String = "teleOpenCloseVideoSuccess";//声网模式下打开或关闭video操作成功后通知z端
		
		public static const  TELE_DRAW_LINE_OPEN:String = "teleSetDrawLineOpen";//声网模式下开启画线
		public static const  TELE_DRAW_LINE_CLOSE:String = "teleSetDrawLineClose";//声网模式下关闭画线
		/**
		 * 切换C1端推送的视频质量
		 */
		public static const  SWITCH_C1_VIDEO_QUALITY:String = "switchVideoQuality";// 切换C1端推送的视频质量
		
		/*
		 *与c2状态交互 
		*/
		public static const  ROBOT_FACE:String = "robotface";//机器人表情
		
		public static const  C2_VERSION_INFO:String = "C2VersionInfo";//机器人表情

		//------------------------------------------------------------------------------------------
		//	connection 相关指令
		//------------------------------------------------------------------------------------------
		
		/**
		 * connection的心跳指令 
		 */		
		public static const CONNECTION_HEARBEAT:String = "connectionHearbeat";
		
		/**
		 * connection的心跳指令响应
		 */		
		public static const CONNECTION_HEARBEAT_RESPONSE:String = "connnectionHearbeatResponse";
		
		
		//------------------------------------------------------------------------------------------
		//	Z端 C1端 C2端 交互的相关指令
		//------------------------------------------------------------------------------------------
		
		public static const GET_C1_VERSION_NUMBER : String = "getC1VersionNumber";
		
		/**
		 * 获取C1信息指令
		 */		
		public static const GET_C1_INFO:String = "getC1Info";
		public static const C1_INFO_NOALERT:String = "C1InfoNoAlert";
		/**
		 *  获取C1端日志信息指令
		 */
		public static const GET_C1_LOG_INF0:String = "getC1LogInfo";
		public static const C2_ONLINE_STATE_QUEST:String = "c2OnlineStateQuest";  ///托管转人工时 Z to C
		public static const C2_ONLINE_STATE_RESPONSE:String = "c2OnlineStateResponse";  ///托管转人工时 C to Z
		/**
		 *  通知C1检查更新指令 */		
		public static const C1_CHECK_UPDATE:String = "c1CheckUpdate";
		/**
		 *  C1正在更新中指令 */		
		public static const C1_IS_UPDATING:String = "c1IsUpdating";
		/**
		 *  C1端清除日志命令 */
		public static const C1_CLEAR_LOG:String = "c1ClearLog";
		/**
		 *  C1端切换环境命令 */
		public static const SET_C1_RELEASE:String = "setC1Release";
		public static const SET_C1_DEBUG:String = "setC1Debug";
		/**
		 *  C2端退出事件消息  */
		public static const C2_IS_DISCONNECT:String = "c2IsDisconnect";
		/**
		 *  获取C2截图指令 */
		public static const GET_C2_SCREENSHOT:String = "getC2ScreenShot";
		public static const GET_C2_SCREENSHOT_SUCCESS:String = "getC2ScreenShotSuccess";
		public static const GET_C2_SCREENSHOT_FAULT:String = "getC2ScreenShotFault";
		/**
		 *  获取C1截图指令 */
		public static const GET_C1_SCREENSHOT:String = "getC1ScreenShot";
		public static const GET_C1_SCREENSHOT_SUCCESS:String = "getC1ScreenShotSuccess";
		public static const GET_C1_SCREENSHOT_FAULT:String = "getC1ScreenShotFault";
		/**
		 *  获取C1端网络状态 */
		public static const GET_C1_NET_STATUS:String = "WebStatus";
		public static const GET_C1_NET_STATUS_SUCCESS:String = "WebStatusOk";
		public static const GET_C1_NET_STATUS_FAULT:String = "WebStatusError";
		/**
		 *  C2工作时间结束指令 */
		public static const C2_WORK_TIME_END:String = "AsrUnSpeak";
		/**
		 *  C2工作时间开始指令 */
		public static const C2_WORK_TIME_BEGIN:String = "AsrSpeak";
		/**
		 *  打开视频行走视频*/
		public static const START_MAP_VIDEO:String = "startMapVideo";
		/**
		 * 打开视频带标线*/
		public static const START_MAP_VIDEO_LINE:String = "startMapVideoLine";
		
		/**
		 * 关闭视频控制行走的视频*/
		public static const END_MAP_VIDEO:String = "endMapVideo";
		
		/**
		 * 人脸测试命令*/
		public static const FACE_DETECT_TEST:String = "faceDetectTest";
		/**
		 * 扫描地图*/
		public static const SCAN_MAP:String = "scanMap";
		
		/**
		 * c2给人工坐席发送消息通知*/
		public static const C2_NOTICE:String="c2notice";
		public static const C2_NOTICE_REMOVE:String = "c2noticeRemove";
		
		/**
		 * 社区终端发送红外或人脸信息给c1*/
		public static const NOTICE_C1_FACE:String="noticec1face";
		
		public static const OPEN_CAM_ERROR:String = "openCamError";
		
		public static const SYN_NON_MAP_OBSTACLE_LIST:String = "SynNonMapObstacleList";
		
		public static const VIDEO_STATU_REPORT:String = "VideoStatusReport";
	}
}