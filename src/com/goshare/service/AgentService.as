package com.goshare.service
{
	import com.goshare.data.Message;
	import com.goshare.data.MessageType;
	import com.goshare.event.AgentServiceEvent;
	import com.goshare.event.FMSServerEvent;
	import com.goshare.event.MinaServerEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.VideoStreamSettings;
	import flash.net.NetStream;
	import flash.system.Security;
	import flash.utils.Timer;
	
	[Event(name="minaServerConnect", type="com.goshare.event.AgentServiceEvent")]
	
	[Event(name="minaServerDisconnect", type="com.goshare.event.AgentServiceEvent")]
	
	[Event(name="minaServerError", type="com.goshare.event.AgentServiceEvent")]
	
	[Event(name="minaServerHearBeatError", type="com.goshare.event.AgentServiceEvent")]
	
	[Event(name="minaServerMessage", type="com.goshare.event.AgentServiceEvent")]
	
	[Event(name="fmsServerConnect", type="com.goshare.event.AgentServiceEvent")]
	
	[Event(name="fmsServerDisconnect", type="com.goshare.event.AgentServiceEvent")]
	
	[Event(name="fmsServerError", type="com.goshare.event.AgentServiceEvent")]
	
	[Event(name="fmsServerMessage", type="com.goshare.event.AgentServiceEvent")]
	
	[Event(name="logMessage", type="com.goshare.event.AgentServiceEvent")]
	
	/**
	 *
	 * 人工坐席入口类
	 *
	 * <p>此类已经封装Socket服务器通信，FMS服务器通信。请直接实例化此类或者继承此类使用。</p>
	 *
	 * @example 使用说明
	 * <listing>
	 * var agentService:AgentService = new AgentService();
	 * agentService.addEventListener(AgentServiceEvent.MINA_MESSAGE, agentService_messageHandler);
	 * // 连接Mina Socket 服务区
	 * agentService.loadMinaPolicyFile("127.0.0.1", 8899);
	 * agentService.connectMina("127.0.0.1", 11889);
	 * // 连接FMS rtmp服务器
	 * agentService.connectFMS("127.0.0.1/fmsurl");
	 * </listing>
	 *
	 * @author coco
	 *
	 */
	[ExcludeClass]
	public class AgentService extends EventDispatcher
	{
		public function AgentService(target:IEventDispatcher = null)
		{
			super(target);
			
			addMinaServerHandler();
			addFMSServerHandler();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 心跳间隔时间
		 */
		public var heartbeatInterval:Number = 30000;
		
		public var messageTypeFilters:Array = [MessageType.S000];
		
		/**
		 *  上一个心跳包是否被响应
		 */
		public var heartbeatResponsed:Boolean;
		
		/**
		 * mina服务器连接状态
		 * @return
		 *
		 */
		public function get minaConnected():Boolean
		{
			return MinaServerService.getInstance().connected;
		}
		
		/**
		 * fms服务器连接状态
		 * @return
		 */
		public function get fmsConnected():Boolean
		{
			return FMSServerService.getInstance().connected;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Mina Server
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 加载Mina服务器安全策略文件
		 *
		 * @param host 安全策略主机
		 * @param port 安全策略端口
		 *
		 */
		public function loadMinaPolicyFile(host:String, port:int):void
		{
			log("[MinaService] 主动加载服务器策略文件", host, port);
			Security.loadPolicyFile("xmlsocket://" + host + ":" + port); // 加载跨域文件
		}
		
		/**
		 *
		 * 连接到Mina Socket服务器
		 *
		 * @param host Mina服务器主机
		 * @param port Mina服务器端口
		 *
		 */
		public function connectMina(host:String, port:int):void
		{
			log("[MinaService] 主动连接服务器", host, port);
			if (minaConnected)
				log("[MinaService] 服务已经连接，请先断开连接再尝试");
			else
				MinaServerService.getInstance().connect(host, port);
		}
		
		/**
		 *
		 * 断开Mina服务器连接
		 *
		 */
		public function disconnectMina():void
		{
			if (minaConnected)
			{
				log("[MinaService] 主动断开服务器");
				MinaServerService.getInstance().disconnect();
				
				var de:AgentServiceEvent = new AgentServiceEvent(AgentServiceEvent.MINA_DISCONNECT);
				de.descript = "服务主动断开";
				dispatchEvent(de);
				
				stopHearbeat();	// 停止心跳
			}
		}
		
		/**
		 * 向Mina服务器发送消息
		 * <p>监听AgentServiceEvent.MINA_MESSAGE事件来获取服务器返回的消息</p>
		 *
		 * @param message 要发送的消息
		 *
		 * @see com.tangdi.data.Message
		 *
		 */
		private var filterCount:int=0; // 坐标发送信息计数器 (日志频繁打印过滤用)
		public function sendMessage(message:Message):void
		{
			var messageJsonString:String = JSON.stringify(message);
			
			if(messageJsonString.indexOf("TEST_MAP_POS_LINK") < 0){
				log("[MinaService] 发送消息：" + messageJsonString);
			}else{
				filterCount++;
				if(filterCount >= 30){
					log("接收消息: " + messageJsonString);
					filterCount=0;
				}
			}
			MinaServerService.getInstance().send(messageJsonString);
		}
		
		private function addMinaServerHandler():void
		{
			MinaServerService.getInstance().addEventListener(MinaServerEvent.CONNECT, mina_connectHandler);
			MinaServerService.getInstance().addEventListener(MinaServerEvent.DISCONNECT, mina_disconnectHandler);
			MinaServerService.getInstance().addEventListener(MinaServerEvent.ERROR, mina_errorHandler);
			MinaServerService.getInstance().addEventListener(MinaServerEvent.DATA, mina_dataHandler);
		}
		
		private function mina_connectHandler(event:MinaServerEvent):void
		{
			log("[MinaService] 服务已经连接");
			
			startHearbeat();	// 启动心跳
			
			var de:AgentServiceEvent = new AgentServiceEvent(AgentServiceEvent.MINA_CONNECT);
			de.descript = event.descript;
			dispatchEvent(de);
		}
		
		private function mina_disconnectHandler(event:MinaServerEvent):void
		{
			log("[MinaService] 服务正常断开");
			var de:AgentServiceEvent = new AgentServiceEvent(AgentServiceEvent.MINA_DISCONNECT);
			de.descript = "服务正常断开";
			dispatchEvent(de);
			
			stopHearbeat();	// 停止心跳
		}
		
		private function mina_errorHandler(event:MinaServerEvent):void
		{
			log("[MinaService] 服务错误：" + event.descript);
			var de:AgentServiceEvent = new AgentServiceEvent(AgentServiceEvent.MINA_ERROR);
			de.descript = event.descript;
			dispatchEvent(de);
			
			stopHearbeat();	// 停止心跳
		}
		
		private function mina_dataHandler(event:MinaServerEvent):void
		{
			var ase:AgentServiceEvent;
			try
			{
				// 将json字符串 转换为 mina消息
				//	Message
				//		messaegType
				//		messageContent
				var messageObject:Object = JSON.parse(event.message);
				var message:Message = new Message();
				message.messageType = messageObject.messageType;
				message.messageContent = messageObject.messageContent;
				message.messageTarget = messageObject.messageTarget;
				message.messageSource = messageObject.messageSource;
				
				ase = new AgentServiceEvent(AgentServiceEvent.MINA_MESSAGE);
				ase.message = message;
				ase.descript = "接收消息";
				
				if (!isFilterMessage(message)) // 将非过滤类型的消息日志输出
					log("[MinaService] 接收消息：" + event.message);
			}
			catch (error:Error)
			{
				log("[MinaService] 解析消息包失败 " + event.message);
				ase = new AgentServiceEvent(AgentServiceEvent.MINA_ERROR);
				ase.descript = error.message;
			}
			
			if (ase.message &&
					ase.message.messageType == MessageType.S000)
			{
				// 这是一个心跳包 不上抛
				receiveHeartbeatMessage(ase.message);
			}
			else
				dispatchEvent(ase);
		}
		
		/**
		 * 是否是过滤消息
		 * */
		private function isFilterMessage(message:Object):Boolean
		{
			for each(var messageType:String in messageTypeFilters)
			{
				if (message.messageType == messageType)
					return true;
			}
			
			if (message.messageContent && message.messageContent.hasOwnProperty("messageType"))
				return isFilterMessage(message.messageContent);
			else
				return false;
		}
		
		//--------------------------------------------------------------------------
		//
		//  FMS Server
		//  FMS 服务器代码处理部分
		//
		//--------------------------------------------------------------------------
		/** 正在连接中 **/
		public var isConnectIng:Boolean = false;
		/**
		 *
		 * 连接FMS服务器
		 * @param url
		 *
		 */
		public function connectFMS(url:String):void
		{
			log("[FMSService] 主动连接服务器", url);
			if (fmsConnected){
				log("[FMSService] 服务已经连接，请先断开连接再尝试");
			}else{
				isConnectIng = true;
				FMSServerService.getInstance().connect(url);
			}
		}
		
		/**
		 *
		 * 断开FMS服务器
		 *
		 */
		public function disconnectFMS():void
		{
			if (fmsConnected)
			{
				log("[FMSService] 主动断开服务器");
				FMSServerService.getInstance().disconnect();
			}
		}
		
		/**
		 *
		 * FMS服务器断开重连一次
		 *
		 */
		private var _reconnectFlg:Boolean;
		private var _reconnentFmsServerUrl:String;
		public function reconnectFMS(fmsServerUrl:String):void
		{
			if (fmsConnected)
			{
				log("[FMSService] 主动断开服务器");
				_reconnectFlg = true;
				_reconnentFmsServerUrl = fmsServerUrl;
				FMSServerService.getInstance().disconnect();
			}
		}
		
		
		/**
		 *
		 * 发布fms数据流
		 *
		 * @param name 流名称
		 * @param camera  发送的摄像头
		 * @param microphone 发送的麦克风
		 * @param type 流类型
		 *
		 */
		public function publish(name:String,
								camera:Camera = null,
								microphone:Microphone = null,
								videoStreamSettings:VideoStreamSettings = null,
								type:String = "live"):NetStream
		{
			log("[FMSService] 主动发布视频流", name);
			trace("主动推流",name);
			return FMSServerService.getInstance().send(name, camera, microphone, videoStreamSettings, type);
		}
		
		/**
		 *
		 * 切换fms数据流  孙敏增加 20180314
		 *
		 * @param name 流名称
		 * @param camera  发送的摄像头
		 * @param microphone 发送的麦克风
		 * @param type 流类型
		 *
		 */
		public function publishSwtich(name:String,
									  camera:Camera = null,
									  microphone:Microphone = null,
									  videoStreamSettings:VideoStreamSettings = null,
									  type:String = "live"):NetStream
		{
			log("[FMSService] 主动发布视频流", name);
			return FMSServerService.getInstance().sendSwitch(name, camera, microphone, videoStreamSettings, type);
		}
		
		/**
		 * 订阅fms视频流
		 *
		 * @param name 要接收的流名称
		 */
		public function subscribe(name:String):NetStream
		{
			log("[FMSService] 主动订阅视频流", name);
			trace("[FMSService] 主动订阅视频流", name);
			return FMSServerService.getInstance().receive(name);
		}
		
		private function addFMSServerHandler():void
		{
			FMSServerService.getInstance().addEventListener(FMSServerEvent.CONNECT, fms_connectHandler);
			FMSServerService.getInstance().addEventListener(FMSServerEvent.DISCONNECT, fms_disconnectHandler);
			FMSServerService.getInstance().addEventListener(FMSServerEvent.ERROR, fms_errorHandler);
			FMSServerService.getInstance().addEventListener(FMSServerEvent.DATA, fms_dataHandler);
		}
		
		/**
		 * 连接FMS服务器成功的时候派发
		 */
		private function fms_connectHandler(event:FMSServerEvent):void
		{
			isConnectIng = false;
			log("[FMSService] 服务已经连接");
			
			var de:AgentServiceEvent = new AgentServiceEvent(AgentServiceEvent.FMS_CONNECT);
			de.descript = event.descript;
			dispatchEvent(de);
			
			if(_reconnectFlg)
			{
				_reconnectFlg = false;
				de = new AgentServiceEvent(AgentServiceEvent.FMS_SERVER_RECONNECT_SUCCESS);
				de.descript = event.descript;
				dispatchEvent(de);
			}
		}
		
		/**
		 * 与FMS服务器连接错误的时候派发
		 */
		private function fms_disconnectHandler(event:FMSServerEvent):void
		{
			isConnectIng = false;
			log("[FMSService] 服务正常断开");
			
			var de:AgentServiceEvent = new AgentServiceEvent(AgentServiceEvent.FMS_DISCONNECT);
			de.descript = event.descript;
			dispatchEvent(de);
			
			if(_reconnectFlg)
			{
				connectFMS(_reconnentFmsServerUrl);
			}
		}
		
		/**
		 * 与FMS服务器连接错误的时候派发
		 */
		private function fms_errorHandler(event:FMSServerEvent):void
		{
			isConnectIng = false;
			log("[FMSService] 服务错误：" + event.descript);
			
			var de:AgentServiceEvent = new AgentServiceEvent(AgentServiceEvent.FMS_ERROR);
			de.descript = event.descript;
			dispatchEvent(de);
		}
		
		/**
		 * 收到FMS服务器数据的时候派发
		 */
		private function fms_dataHandler(event:FMSServerEvent):void
		{
			isConnectIng = false;
			log("[FMSService] 服务消息：" + event.descript);
			
			var de:AgentServiceEvent = new AgentServiceEvent(AgentServiceEvent.FMS_MESSAGE);
			de.descript = event.descript;
			dispatchEvent(de);
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  心跳逻辑代码
		//
		//--------------------------------------------------------------------------
		
		private var _heartbeatTimer:Timer;
		
		private function get heartbeatTimer():Timer
		{
			if (!_heartbeatTimer)
			{
				_heartbeatTimer = new Timer(heartbeatInterval);
				_heartbeatTimer.addEventListener(TimerEvent.TIMER, heartbeatTimer_TimerHandler);
			}
			
			return _heartbeatTimer;
		}
		
		/**
		 * 开始心跳
		 */
		protected function startHearbeat():void
		{
			if (!heartbeatTimer.running)
			{
				log("[MinaService] 心跳启动");
				heartbeatResponsed = true;
				heartbeatTimer.start();
			}
		}
		
		/**
		 * 停止心跳
		 */
		protected function stopHearbeat():void
		{
			if (_heartbeatTimer && _heartbeatTimer.running)
			{
				log("[MinaService] 心跳停止");
				heartbeatResponsed = false;
				_heartbeatTimer.stop();
				_heartbeatTimer.reset();
			}
		}
		
		private function heartbeatTimer_TimerHandler(event:TimerEvent):void
		{
			// 检查上一个心跳包是否被响应
			if (!heartbeatResponsed)
			{
				log("[MinaService] 服务心跳异常");
				var ase:AgentServiceEvent = new AgentServiceEvent(AgentServiceEvent.MINA_HEARBEAT_ERROR);
				ase.descript = "服务心跳异常";
				dispatchEvent(ase);
			}
			
			// 发送心跳消息
			sendHeartbeatMessage();
		}
		
		/**
		 * 发送心跳消息
		 */
		public function sendHeartbeatMessage():void
		{
			heartbeatResponsed = false;
			var message:Message = new Message();
			message.messageType = MessageType.HEARTBEAT;
			message.messageContent = "心跳请求" + new Date().time;
			message.messageTarget = "";
			sendMessage(message);
//			trace("发送心跳请求");
		}
		
		private function receiveHeartbeatMessage(message:Message):void
		{
			heartbeatResponsed = true;
		}
		
		//--------------------------------------------------------------------------
		//
		//  LOG 
		//
		//--------------------------------------------------------------------------
		
		/**
		 *
		 * 输出日志
		 *
		 * @param args
		 *
		 */
		protected function log(...args):void
		{
			var arg:Array = args as Array;
			if (arg.length > 0)
			{
				var ase:AgentServiceEvent = new AgentServiceEvent(AgentServiceEvent.LOG_MESSAGE);
				ase.descript = args.join(" ");
				dispatchEvent(ase);
			}
		}
		
	}
}