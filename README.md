#### XWebiPhone

### iPhone 2.4版本Feature

#### bugfix
* 修复缓存系统支持HTTP状态码200才缓存返回的bug

#### 首页速度优化
* 首次配置获取改成从后台获取，App内含备用配置

#### 统一网络层
* App（ASIHTTPRequest|AFNetwork）所有网络流量统一走JMWebResourceURLProtocol拦截和加载
* 去除原先版本的WebView重载URL Query字段，减少干扰，后面依赖cookie和native缓存
* 白名单拦截机制
* 统一超时时间至15s（暂定15s，2G|3G|4G|WIFI 尽量考虑不一样，以用户体验考虑）
* 所有请求Header中新增
	* udid(必须有)
	* lat
	* lng
	* token(Push消息的时候使用)
* 加入native_cache=t(s)来实现单体缓存功能，本版本t参数功能不启用
* MD5检验（HTTP Response 返回头内含 x-oss-meta-md5）
* 建立网络层白名单来自 http://cdn.52shangou.com/buyer/1.0.1/build/online.json

#### Bridge新增
* bridge.get_sync 同步读
* bridge.set_sync 同步写
* bridge.delete_sync 同步删

#### 新增Log监控	iConsole
* Debug版本新增摇一摇弹出手机版日志查询功能

#### 待续


##### BridgeLibVersion 2.1
* 支付返回增加状态参数
	
		支付返回callbackURL 后面新增参数 payback=success|inprocess|fail|cancelbyuser|networkfail
	
* 增加网络异常情况处理
		
		东西
		
* 增加清除缓存处理、
* 缓存系统处理

