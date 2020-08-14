# HYPlayerDemo
音视频播放器

# 实现功能：
- 屏幕滑动调节进度、亮度、音量
- 倍速播放
- 竖播视频适配
- 全屏状态画面（自适应、铺满）调节
- 在wifi条件下自动缓存
- 断点续播功能
- 自定义播放结束页面及音频播放界面

# 调用方法：
let videoView = HYPlayerCommonView(播放器父视图)
videoView?.updateCurrentPlayer(playerConfig: HYPlayerCommonConfig(title: "标题", videoUrl: "视频地址"))

在controller的viewWillDisappear中调用 videoView.dealToDisappear()以销毁播放器

# 播放器配置(HYPlayerCommonConfig)：
- title: 播放音视频标题（全屏时显示），可不传
- audioUrl: 播放音频地址
- videoUrl: 播放视频地址（不传则播放音频）
- needCache: 是否需要缓存（默认不开启）
- playContinue: 是否断点续播（默认开启）
- placeHoldImg: 封面图（可传本地图片String或网络图片URL）
- customEndView: 自定义播放结束界面（可不传）
- customAudioView: 自定义音频播放界面（可不传）
- authenticationFunc: 播放地址鉴权函数(可不传)

