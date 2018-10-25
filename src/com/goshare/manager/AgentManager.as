package com.goshare.manager
{
	import com.goshare.data.Client;
	import com.goshare.data.Entrust;
	import com.goshare.data.EntrustType;
	import com.goshare.data.Message;
	import com.goshare.data.MessageType;
	import com.goshare.data.Status;
	import com.goshare.event.AgentManagerEvent;
	import com.goshare.event.AgentServiceEvent;
	import com.goshare.service.AgentService;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.net.NetStream;
	import flash.utils.Timer;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	[Event(name="clientLogin", type="com.goshare.event.AgentManagerEvent")]
	
	[Event(name="clientLoginFail", type="com.goshare.event.AgentManagerEvent")]
	
	[Event(name="clientLogout", type="com.goshare.event.AgentManagerEvent")]
	
	[Event(name="clientMessage", type="com.goshare.event.AgentManagerEvent")]
	
	[Event(name="clientStatus", type="com.goshare.event.AgentManagerEvent")]
	
	[Event(name="clientEntrust", type="com.goshare.event.AgentManagerEvent")]
	
	[Event(name="hearBeatError", type="com.goshare.event.AgentManagerEvent")]
	
	[Event(name="systemError", type="com.goshare.event.AgentManagerEvent")]
	
	[Event(name="systemNotice", type="com.goshare.event.AgentManagerEvent")]
	
	[Event(name="logMessage", type="com.goshare.event.AgentManagerEvent")]
	
	/**
	 *
	 * 人工坐席管理器
	 *  
	 * @author coco
	 * 
	 */	
	public class AgentManager extends EventDispatcher
	{
		public function AgentManager(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		
		//--------------------------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------------------------
		
		private var _agentService:AgentService; // 人工坐席服务
		
		public function get agentService():AgentService
		{
			if (!_agentService)
			{
				_agentService = new AgentService();
				_agentService.addEventListener(AgentServiceEvent.MINA_CONNECT, this_minaConnectHandler);
				_agentService.addEventListener(AgentServiceEvent.MINA_MESSAGE, this_minaMessageHandler);
				_agentService.addEventListener(AgentServiceEvent.MINA_ERROR, this_minaErrorHandler);
				_agentService.addEventListener(AgentServiceEvent.MINA_DISCONNECT, this_minaDisconnectHandler);
				_agentService.addEventListener(AgentServiceEvent.LOG_MESSAGE, this_logMessageHandler);
				_agentService.addEventListener(AgentServiceEvent.MINA_HEARBEAT_ERROR, this_hearBeatErrorHandler);
				
				// 监听到FMS服务器连接异常ERROR
				_agentService.addEventListener(AgentServiceEvent.FMS_ERROR, this_fmsServiceErrorHandler);
				// 监听到FMS服务器连接断开
				_agentService.addEventListener(AgentServiceEvent.FMS_DISCONNECT, this_fmsDisconnectHandler);
				// FMS服务器通信信息 - 事件监听 
				_agentService.addEventListener(AgentServiceEvent.FMS_MESSAGE, this_fmsServiceMessageHandler);
				// FMS服务器通信信息 - 事件监听 
				_agentService.addEventListener(AgentServiceEvent.FMS_CONNECT, this_fmsConnectHandler);
			}
			
			return _agentService;
		}
		
		//--------------------------------------------------------------------------------------------
		//
		//  Service Handler (FMS)
		//		201803 增加FMS服务器异常掉线重连机制 		(正常断开的情况除外)
		//
		//
		//--------------------------------------------------------------------------------------------
		public var fmsServerUrl:String;
		private var needReConnectFlag:Boolean = false;
		private var _setTimeNum:uint = 0;
		
		/**
		 * 与fms服务器是否已连接
		 */		
		public function get connectedFMS():Boolean
		{
			return _agentService && _agentService.fmsConnected;
		}
		
		/**
		 * 登录FMS服务器
		 */		
		public function loginFMS():void
		{
			if(!agentService.fmsConnected && !agentService.isConnectIng){
				agentService.connectFMS(fmsServerUrl);
			}
		}
		
		/**
		 * 项目主动断开FMS服务器(正常断开，无需自动重连)
		 */
		public function disconnectFMS():void
		{
			needReConnectFlag = false;
			agentService.disconnectFMS();
		}
		
		
		/**
		 * 订阅视频流 
		 * @param streamName 视频流名称
		 */		
		public function subscribe(streamName:String):NetStream
		{
			return agentService.subscribe(streamName);
		}
		
		/**
		 * FMS服务建立连接成功
		 * 默认 needReConnectFlag = true，即连接断开时候，自动重建连接
		 */
		protected function this_fmsConnectHandler(event:AgentServiceEvent):void
		{
			if(needReConnectFlag){
				// 派发事件 - FMS已恢复连接
				var ame:AgentManagerEvent = new AgentManagerEvent(AgentManagerEvent.FMS_RECONNECT_EVENT);
				dispatchEvent(ame);
			}else{
				// 派发事件 - FMS正常建立连接
				var ameNormal:AgentManagerEvent = new AgentManagerEvent(AgentManagerEvent.FMS_CONNECT_EVENT);
				dispatchEvent(ameNormal);
			}
			needReConnectFlag = true;
		}
		
		/**
		 * FMS服务连接断开处理
		 * 
		 * 断开原因有两种：异常断开/正常断开，根据 needReConnectFlag 判定是否重连
		 * ---	故请正常断开连接前，将needReConnectFlag更改为false
		 */
		protected function this_fmsDisconnectHandler(event:AgentServiceEvent):void
		{
			if(needReConnectFlag){
				trace("FMS连接异常断开，2s后开始自动重连");
				log("FMS连接异常断开，2s后开始自动重连")
				// 派发事件 - FMS异常断开
				var ame:AgentManagerEvent = new AgentManagerEvent(AgentManagerEvent.FMS_DISCONNECT_UNNORMALEVENT);
				dispatchEvent(ame);
				// 2秒后重新登录FMS
				if(_setTimeNum > 0){
					clearTimeout(_setTimeNum);
				}
				_setTimeNum = setTimeout(loginFMS, 2000);
			}else{
				trace("FMS连接正常断开，不再启动重连");
				// 派发事件 - FMS正常断开
				var ameUn:AgentManagerEvent = new AgentManagerEvent(AgentManagerEvent.FMS_DISCONNECT_NORMAL_EVENT);
				dispatchEvent(ameUn);
			}
		}
		
		/**
		 * FMS服务连接异常处理
		 * 
		 * 异常原因清单：
		 * 		1. 发送失败，FMS服务器未连接
		 * 		2. 接收失败，FMS服务器未连接
		 * 		3. 连接失败
		 * 		4. 指定的应用程序没有找到
		 * 		5. 拒绝连接
		 * 		6. 服务器应用程序已经关闭（由于资源耗用过大等原因）或者服务器已经关闭
		 * 		7. other
		 */
		protected function this_fmsServiceErrorHandler(event:AgentServiceEvent):void
		{
			if(needReConnectFlag){
				trace("[AgentManager] FMS连接失败(断线重连情况)，继续重连！");
				log("[AgentManager] FMS连接失败(断线重连情况)，继续重连！");
			}else{
				trace("[AgentManager] FMS连接失败(正常情况)，继续重连！");
				log("[AgentManager] FMS连接失败(正常情况)，继续重连！");
			}
			// 2秒后重新登录FMS
			if(_setTimeNum > 0){
				clearTimeout(_setTimeNum);
			}
			_setTimeNum = setTimeout(loginFMS, 2000);
		}
		
		/**
		 * FMS服务器信息接收处理
		 */
		private var fmsInitTimer:Timer;
		protected function this_fmsServiceMessageHandler(event:AgentServiceEvent):void
		{
			log("[FMSService] 服务消息：" + event.descript);
			var msg:String = event.descript;
			
			if(fmsInitTimer == null){
				fmsInitTimer = new Timer(4000,1);
				fmsInitTimer.addEventListener(TimerEvent.TIMER_COMPLETE,closeFMSTime);
			}
			if(msg == "视频流为空"){
				// 当FMS连接未断开，但通讯数据为空时，则重新建立连接
				trace("视频流为空，重新建立连接！");
				if(agentService.fmsConnected){
					fmsInitTimer.stop();
					trace("因视频流为空，认为连接异常，先断开连接重连！");
					needReConnectFlag = true;
					agentService.disconnectFMS();
				}
			}else if(msg == "流已暂停"){
				fmsInitTimer.reset();
				fmsInitTimer.start();
			}else if(msg == "流已恢复"){
				fmsInitTimer.stop();
			}
		}
		
		protected function closeFMSTime(e:TimerEvent):void{
			fmsInitTimer.stop();
			if(agentService.fmsConnected){
				needReConnectFlag = true;
				agentService.disconnectFMS();
			}
		}
		
		//--------------------------------------------------------------------------------------------
		//
		//  Service Handler
		//
		//--------------------------------------------------------------------------------------------
		/**
		 * 与mina服务器是否已连接
		 * @return 
		 */		
		public function get connected():Boolean
		{
			return _agentService && _agentService.minaConnected;
		}
		
		protected function this_minaConnectHandler(event:AgentServiceEvent):void
		{
			// [Mina服务] 服务连接成功
			// 发送登录指令
			var userData:Object={userName:minaUsername, 
				password: minaPassword, 
				mac: minaMacAddress,
				version: minaVersion};
			log("[AgentManager] 开始登录 " + userData.userName + " " + userData.password + " " + userData.mac);
			var sendMessage:Message = new Message();
			sendMessage.messageType = isSeatClient ? MessageType.Z001 : MessageType.C001;
			sendMessage.messageContent = userData;
			agentService.sendMessage(sendMessage);
		}	
		
		protected function this_minaDisconnectHandler(event:AgentServiceEvent):void
		{
			// [Mina服务] 服务主动断开
			// [Mina服务] 服务正常断开
			log("[Mina服务] 服务主动断开 ");
			disconnectFMS();
			
			var ame:AgentManagerEvent = new AgentManagerEvent(AgentManagerEvent.CLIENT_LOGOUT);
			dispatchEvent(ame);
		}
		
		protected function this_minaErrorHandler(event:AgentServiceEvent):void
		{
			log("[Mina服务] mina服务器发生错误 ");
			// mina服务器发生错误
			agentService.disconnectMina();
			
			// 派发错误事件
			var ame:AgentManagerEvent = new AgentManagerEvent(AgentManagerEvent.SYSTEM_ERROR);
			ame.descript = "服务器发生错误, 请联系管理员";
			dispatchEvent(ame);
		}
		
		protected function this_hearBeatErrorHandler(event:AgentServiceEvent):void
		{
			// 派发心跳错误事件
			var ame:AgentManagerEvent = new AgentManagerEvent(AgentManagerEvent.HEAR_BEAT_ERROR);
			dispatchEvent(ame);
		}
		
		protected function this_minaMessageHandler(event:AgentServiceEvent):void
		{
//			trace(event.message.messageType);
			var ame:AgentManagerEvent;
			switch(event.message.messageType)
			{
				case MessageType.S903: // 终端客户端登录成功
				{
//					trace("服务端转发 Z to C1 消息成功");
					break;
				}
				case MessageType.S201: // 终端客户端登录成功
				{
					processSeatClientList(event.message.messageContent);
					
					// 发送登录成功事件
					ame = new AgentManagerEvent(AgentManagerEvent.CLIENT_LOGIN);
					ame.descript = event.message.messageContent;
					dispatchEvent(ame);
					break;
				}
				case MessageType.S100: // 坐席客户端登录成功
				{
					processRobotClientList(event.message.messageContent);
					
					// 发送登录成功事件
					ame = new AgentManagerEvent(AgentManagerEvent.CLIENT_LOGIN);
					ame.descript = event.message.messageContent;
					dispatchEvent(ame);
					break;
				}
				case MessageType.S024: // 坐席客户端状态包
				{
					processSeatClientStatus(event.message.messageContent);
					break;
				}
				case MessageType.S023: // 终端客户端状态包
				{
					trace("收到S102终端客户端状态包--终端有上下线");
					processRobotClientStatus(event.message.messageContent);
					break;
				}
				case MessageType.S025: // 申请委托
				{
					processSeatClientEntrust(event.message.messageContent, EntrustType.ENTRUST_REQUESTED);
					break;
				}
				case MessageType.S026: // 终止委托
				{
					processSeatClientEntrust(event.message.messageContent, EntrustType.ENTRUST_STOPED);
					break;
				}
				case MessageType.S027: // 申请终止委托
				{
					processSeatClientEntrust(event.message.messageContent, EntrustType.ENTRUST_STOP_REQUESTED);
					break;
				}
				case MessageType.S028: // 接受委托
				{
					processSeatClientEntrust(event.message.messageContent, EntrustType.ENTRUST_ACCEPTED);
					break;
				}
				case MessageType.S030: // 拒绝终止委托
				{
					processSeatClientEntrust(event.message.messageContent, EntrustType.ENTRUST_STOP_REQUESTED_REJECTED);
					break;
				}
				case MessageType.S034: // 该委托已被接受
				{
					processSeatClientEntrust(event.message.messageContent, EntrustType.ENTRUST_BEEN_ACCEPTED_BY_OHTERS);
					break;
				}
				case "S001": ////////////////////////////////////////// 客户端消息转发
				{
					try
					{
						var clientMessage:Message = new Message();
						clientMessage.messageType = event.message.messageContent.messageType;
						clientMessage.messageContent = event.message.messageContent.messageContent;
						clientMessage.messageTarget = event.message.messageTarget;
						clientMessage.messageSource = event.message.messageSource;
						processClientMessage(clientMessage);
//						trace("内部转发",JSON.stringify(clientMessage));
					}
					catch(error:Error) 
					{
						log("[AgentManager] 解析ClientMessage错误");
						trace("[AgentManager] 解析ClientMessage错误");
					}
					break;
				}
				case MessageType.S905: // 客服注销
				{
					agentService.disconnectMina();
					break;
				}
				case MessageType.S022: // 系统公告
				{
					ame = new AgentManagerEvent(AgentManagerEvent.SYSTEM_NOTICE);
					ame.descript = event.message.messageContent;
					dispatchEvent(ame);
					break;
				}
				case MessageType.S011: // 登录失败 
				{
					ame = new AgentManagerEvent(AgentManagerEvent.CLIENT_LOGIN_FAIL);
					ame.descript = event.message.messageContent;
					dispatchEvent(ame);
					break;
				}
				case MessageType.S013: // 异地登陆
				case MessageType.S006: // 成员类型错误
				case MessageType.S007: // 未知消息类型 
				case MessageType.S005: // 连接超时 无心跳信息 
				case MessageType.S017: // 终端（终端）不存在
				case MessageType.S018: // 长时间无消息传输 只有心跳信息，无其他信息 
				case MessageType.S019: // 系统异常
				case MessageType.S021: // 心跳包无效
				{
					agentService.disconnectMina();
					
					ame = new AgentManagerEvent(AgentManagerEvent.SYSTEM_ERROR);
					ame.descript = event.message.messageContent;
					dispatchEvent(ame);
					break;
				}
				case MessageType.S016: // 缺少必要字段
				{
					ame = new AgentManagerEvent(AgentManagerEvent.SYSTEM_ERROR);
					ame.descript = event.message.messageContent;
					dispatchEvent(ame);
					break;
				}
				case MessageType.S033: //有推荐问的情况下 半人工功能
				{
					ame = new AgentManagerEvent(AgentManagerEvent.RECOMMEND_QS);
					ame.obj = event.message.messageContent
					trace("收到的数据："+JSON.stringify(event.message.messageContent));
					dispatchEvent(ame);
					break;
				}
				default:
				{
					break;
				}
			}
		}
		
		protected function this_logMessageHandler(event:AgentServiceEvent):void
		{
			log(event.descript);
		}
		
		
		//--------------------------------------------------------------------------------------------
		//
		//  日志
		//
		//--------------------------------------------------------------------------------------------
		
		/**
		 * 输出日志
		 * @param args
		 */		
		protected function log(...args):void
		{
			var arg:Array = args as Array;
			if (arg.length > 0)
			{
				var ame:AgentManagerEvent = new AgentManagerEvent(AgentManagerEvent.LOG_MESSAGE);
				ame.descript = args.join(" ");
				dispatchEvent(ame);
			}
		}
		
		
		//--------------------------------------------------------------------------------------------
		//
		//  坐席登录
		//
		//--------------------------------------------------------------------------------------------
		
		private var isSeatClient:Boolean; // 是否是坐席客户端
		private var minaUsername:String;
		private var minaPassword:String; 
		private var minaMacAddress:String;
		private var minaVersion:String;
		
		public var minaServerHost:String;
		public var minaServerPort:int;
		public var policyServerHost:String;
		public var policyServerPort:int;
		
		/**
		 * 客户端登录 
		 * @param useranme
		 * @param password
		 * @param isSeat
		 * 
		 */		
		public function login(useranme:String, 
							  password:String, 
							  version:String, 
							  macAddress:String = "",
							  isSeat:Boolean = true):void
		{
			// 如果当前是连接状态 先断开
			if (_agentService && _agentService.minaConnected)
				_agentService.disconnectMina();
			
			isSeatClient = isSeat;
			
			minaUsername = useranme;
			minaPassword = password;
			minaMacAddress = macAddress;
			minaVersion = version;
			
			agentService.loadMinaPolicyFile(policyServerHost, policyServerPort);
			agentService.connectMina(minaServerHost, minaServerPort);
			log(policyServerHost, policyServerPort);
			log(minaServerHost, minaServerPort);
			log("客户端登录 ,加载策略文件，连接mina服务器");
		}
		
		//--------------------------------------------------------------------------------------------
		//
		//  处理客户端消息
		//
		//--------------------------------------------------------------------------------------------
		
		public var clients:Array; // 客户端数据列表
		
		/**
		 * 获取指定ID的客户端 
		 * @param id
		 * @return 
		 * 
		 */		
		public function getClient(id:String):Client
		{
			for each (var client:Client in clients)
			{
				if (client.id == id)
					return client;
			}
			
			return null;
		}
		
		/**
		 * 处理终端客户端列表 
		 * @param messageContent
		 * 
		 */		
		private function processRobotClientList(messageContent:*):void
		{
			clients = [];
			var client:Client;
			for each (var item:Object in messageContent.termList)
			{
				client = new Client();
				client.id = item.termId;
				client.online = item.status == "00";
				client.version = item.version;
				client.name = "测试名称";
				client.classInfo = "测试班级";
				clients.push(client);
			}
			trace("获取到机器人列表："+clients);
		}
		
		/**
		 * 处理坐席客户端列表 
		 * @param messageContent
		 * 
		 */		
		private function processSeatClientList(messageContent:*):void
		{
			clients = [];
			var client:Client;
			for each (var item:Object in messageContent.seatsList)
			{
				client = new Client();
				client.id = item.id;
				client.online = item.status == "00";
				client.version = item.version;
				clients.push(client);
			}
		}
		
		/**
		 * 处理终端客户端状态
		 * @param messageContent
		 * 
		 */	
		private function processRobotClientStatus(messageContent:*):void
		{
			var status:Status = new Status();
			status.online = messageContent.status == "00";
			status.version = messageContent.version;
			status.id = messageContent.termId;
			
			var client:Client = getClient(status.id);
			if (client)
			{
				client.online = status.online;
				client.version = status.version;
			}
			trace("状态发送改变后的list："+JSON.stringify(clients));
			// 派发状态事件
			var ame:AgentManagerEvent = new AgentManagerEvent(AgentManagerEvent.CLIENT_STATUS);
			ame.status = status;
			dispatchEvent(ame);
		}
		
//		/**
//		 * 处理终端客户端状态 - 增加断线信息延时发送功能
//		 * @param messageContent
//		 * 
//		 */	
//		private var _downC1Array:Array = []; // 终端掉线延时处理队列清单
//		private function processRobotClientStatus(messageContent:*):void
//		{
//			var status:Status = new Status();
//			status.online = messageContent.status == "00";
//			status.version = messageContent.version;
//			status.id = messageContent.termId;
//			
//			// 20180402 修改：针对C1端在短时间内，掉线又上线的情况，做个延时处理
//			var myIndex:int = -1;
//			if(messageContent.status == "00"){
//				trace("终端" + messageContent.termId + "上线处理！");
//				// C1端上线 - 立刻发送给坐席
//				// 检查队列内该终端是否刚掉过线
//				for(var index:int=0; index<_downC1Array.length; index++){
//					if(_downC1Array[index]["termID"] == messageContent.termId){
//						trace("终端"+ messageContent.termId +"曾在2s内掉过线！现在上线，取消掉线信息派发！timeoutUint-" + _downC1Array[index]["timeoutUint"]);
//						
//						// 既然已经上线，取消掉线信息发送
//						clearTimeout(_downC1Array[index]["timeoutUint"] as uint);
//						myIndex = index;
//						break;
//					}
//				}
//				
//				if(myIndex > -1){
//					trace("从延时队列中清除该终端！");
//					_downC1Array.splice(myIndex, 1);
//				}else{
//					trace("发送终端上线请求！ -- " + messageContent.termId);
//					sendC1StatusToZHandler(status);
//				}
//			}else{
//				// C1端掉线 - 2s后通知坐席端 (若在此期间收到上线信息了，则取消发送掉线信息)
//				
//				trace("终端" + messageContent.termId + "掉线处理！");
//				for each(var queueItem:Object in _downC1Array){
//					if(queueItem["termID"] == messageContent.termId){
//						clearTimeout(queueItem["timeoutUint"] as uint);
//						queueItem["statusInfo"] = status;
//						queueItem["timeoutUint"] = setTimeout(sendC1StatusToZHandler1, 2000, queueItem["termID"]);
//						trace("该终端2s内掉过线，当前正在延时处理，重新计时处理！");
//						return;
//					}
//				}
//				
//				var newItem:Object = new Object();
//				newItem["termID"] = messageContent.termId;
//				newItem["statusInfo"] = status;
//				newItem["timeoutUint"] = setTimeout(sendC1StatusToZHandler1, 2000, newItem["termID"]);
//				trace("终端" + messageContent.termId + "首次掉线，加入到延时队列中！timeoutUint - " + newItem["timeoutUint"]);
//				_downC1Array.push(newItem);
////				_c1DisconnectTimeout = setTimeout(sendC1StatusToZHandler, 2000, status);
//			}
//		}
//		
//		/**
//		 * 发送C1上下线状态到坐席端
//		 * @param 
//		 */
//		private function sendC1StatusToZHandler(statusData:Status=null):void
//		{
//			// 派发状态事件
//			var ame:AgentManagerEvent = new AgentManagerEvent(AgentManagerEvent.CLIENT_STATUS);
//			ame.status = statusData;
//			dispatchEvent(ame);
//		}
//		
//		/**
//		 * 发送C1上下线状态到坐席端 - 延时
//		 * @param 
//		 */
//		private function sendC1StatusToZHandler1(termID:String):void
//		{
//			var myIndex:int = -1;
//			for(var index:int=0; index<_downC1Array.length; index++){
//				if(_downC1Array[index]["termID"] == termID){
//					trace("终端" + termID + "掉线信息 延时触发！timeoutUint - " + _downC1Array[index]["timeoutUint"]);
//					myIndex = index;
//					clearTimeout(_downC1Array[index]["timeoutUint"] as uint);
//					sendC1StatusToZHandler(_downC1Array[index]["statusInfo"] as Status);
//					break;
//				}
//			}
//			
//			if(myIndex>=0){
//				_downC1Array.splice(myIndex, 1);
//			}
//		}
		
		/**
		 * 处理坐席客户端状态
		 * @param messageContent
		 * 
		 */	
		private function processSeatClientStatus(messageContent:*):void
		{
			var status:Status = new Status();
			status.online = messageContent.status == "00";
			status.version = messageContent.version;
			status.id = messageContent.id;
			
			var client:Client = getClient(status.id);
			if (client)
			{
				client.online = status.online;
				client.version = status.version;
			}
			
			// 派发状态事件
			var ame:AgentManagerEvent = new AgentManagerEvent(AgentManagerEvent.CLIENT_STATUS);
			ame.status = status;
			dispatchEvent(ame);
		}
		
		/**
		 * 处理坐席客户端委托
		 * @param messageContent
		 * 
		 */	
		private function processSeatClientEntrust(messageContent:*, entrustType:String):void
		{
			var entrust:Entrust = new Entrust();
			entrust.type = entrustType;
			entrust.serialNo = messageContent.serialNo;
			entrust.principle = messageContent.principle;
			if(messageContent.terms == null)
			{
				entrust.termId = messageContent.termId;
			}else
			{
				entrust.termId = messageContent.terms;
			}
			entrust.descript = messageContent.entrustDesc;
			entrust.termList = messageContent.termList;
			entrust.mandatary = messageContent.mandatary;
			
			// 派发委托事件
			var ame:AgentManagerEvent = new AgentManagerEvent(AgentManagerEvent.CLIENT_ENTRUST);
			ame.entrust = entrust;
			dispatchEvent(ame);
		}
		
		private function processClientMessage(clientMessage:Message):void
		{
			var ame:AgentManagerEvent = new AgentManagerEvent(AgentManagerEvent.CLIENT_MESSAGE);
			ame.message = clientMessage;
			dispatchEvent(ame);
		}
		//--------------------------------------------------------------------------
		//
		//  消息通信方法
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 给服务器发送消息 
		 * @param message
		 */		
		public function sendMessage(message:Message):void
		{
			agentService.sendMessage(message);
		}
		
		/**
		 * 发送消息给C1端
		 */		
		public function sendMessageToC1(message:Message):void
		{
			var sendmessage:Message = new Message();
			sendmessage.messageType = MessageType.Z003;
			sendmessage.messageContent = message;
			sendmessage.messageTarget = message.messageTarget;
			sendmessage.messageSource = message.messageSource;
			sendMessage(sendmessage);
		}
		
		/**
		 * 发送消息给C1端--封装
		 * @param mesType 消息类型
		 * @param mesContent 消息内容
		 * @param mesTarget 发送对象
		 * @param mesSource 消息来源
		 */
		public function sendMessageToC1Quick(mesType:String=null,mesContent:*=null,mesTarget:String=null,mesSource:String=null):void
		{
			var sendMessage:Message = new Message();
			sendMessage.messageType = mesType;
			sendMessage.messageTarget = mesTarget;
			sendMessage.messageSource = mesSource;
			sendMessage.messageContent = mesContent;
			sendMessageToC1(sendMessage);
		}
		
		/**
		 * 发送消息给Z端
		 */		
		/*public function sendMessageToZ(message:Message):void
		{
			var sendmessage:Message = new Message();
			sendmessage.messageType = isSeatClient ? MessageType.Z004 : MessageType.C003;
			sendmessage.messageContent = message;
			sendmessage.messageTarget = message.messageTarget;
			sendmessage.messageSource = message.messageSource;
			sendMessage(sendmessage);
		}*/

	}
}