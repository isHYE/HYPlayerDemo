//
//  HYPlayerCommonView.swift
//  SuperPlayerDemo
//
//  Created by 黄益 on 2020/7/29.
//  Copyright © 2020 黄益. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation

/// 资源文件
let SOURCE_BUNDLE = Bundle.init(path: Bundle.main.path(forResource: "HYPlayer", ofType: "bundle")! + "/Icons")
/// 屏幕宽度
let SCREEN_WIDTH = UIScreen.main.bounds.size.width
/// 屏幕高度
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height

class HYPlayerCommonView: UIView {
    
    /// 播放器回调
    weak var delegate: HYPlayerCommonViewDelegate?
    /// 播放器的父view
    weak var fatherView: UIView?
    
    
    //MARK: View Control
    /// 封面图
    var placeHoldImgView: UIImageView! // 视频封面图
    /// 视频承载View
    var videoView: UIView!
    /// 中新播放按钮遮罩
    var centerDartView: UIView!
    /// 中心播放按钮
    var centerPlayBtn: UIButton!
    /// 控制播放面板
    var controlPanel: HYControlPanelView!
    /// 全屏状态下遮罩
    var fullMaskView: HYFullScreenMaskView?
    /// 音频播放界面（遮罩）
    var audioPlayView: HYAudioPlayView?
    /// 播放完毕之后展示
    var endPlayView: HYEndPlayView?
    /// 快捷操作提醒
    var speedyRemindView: HYSpeedyRemindView?
    
    //MARK: Private Config
    /// 普通事件管理
    private var manager: HYAudiovisualCommonManager?
    /// 快捷操作管理
    private var speedyManager: HYAudiovisualSpeedyManager?
    /// 播放进度计时器
    private var playTimer: Timer?
    
    //MARK: 播放器相关
    /// 播放器
    var videoPlayer: AVPlayer?
    /// 播放器layer
    var playerLayer: AVPlayerLayer?
    
    
    convenience init(_ baseView: UIView) {
        self.init()
        
        fatherView = baseView
        
        manager = HYAudiovisualCommonManager(self)
        speedyManager = HYAudiovisualSpeedyManager(self)
        
        createBaseView()
        
        addObserver()
        
        // 开启屏幕常亮
        UIApplication.shared.isIdleTimerDisabled = true
        //按下slider的时候会停，抬起手后恢复，其他时间计时器在运行
        playTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(updatePanel(sender:)), userInfo: nil, repeats: true)
    }
    
    //MARK: 视图创建
    /** 创建基础试图*/
    private func createBaseView() {
        
        fatherView?.addSubview(self)
        snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        placeHoldImgView = UIImageView()
        placeHoldImgView.isHidden = true
        placeHoldImgView.contentMode = .scaleAspectFill
        placeHoldImgView.clipsToBounds = true
        addSubview(placeHoldImgView)
        placeHoldImgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        videoView = UIView()
        let videoViewTap = UITapGestureRecognizer.init(target: self, action: #selector(playerViewDidTapped))
        videoView.addGestureRecognizer(videoViewTap)
        let videoViewMoreTap = UITapGestureRecognizer.init(target:self, action: #selector(playButtonDidClicked))
        videoViewMoreTap.numberOfTapsRequired = 2
        videoView.addGestureRecognizer(videoViewMoreTap)
        videoView.backgroundColor = .clear
        addSubview(videoView)
        videoView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        audioPlayView = HYAudioPlayView()
        let audioViewTap = UITapGestureRecognizer.init(target: self, action: #selector(playerViewDidTapped))
        audioPlayView?.addGestureRecognizer(audioViewTap)
        let audioViewMoreTap = UITapGestureRecognizer.init(target:self, action: #selector(playButtonDidClicked))
        audioViewMoreTap.numberOfTapsRequired = 2
        audioPlayView?.addGestureRecognizer(audioViewMoreTap)
        audioPlayView?.isHidden = true
        addSubview(audioPlayView!)
        audioPlayView?.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        
        speedyRemindView = HYSpeedyRemindView()
        speedyRemindView?.isHidden = true
        addSubview(speedyRemindView!)
        speedyRemindView?.snp.makeConstraints({ (make) in
            make.center.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(50)
        })
        
        createAllScreenNavigationBar()
        createControlPanel()
        createEndPlayView()
    }
    
    /** 配置控制面板*/
    private func createControlPanel() {
        controlPanel = HYControlPanelView()
        controlPanel.playButton.addTarget(self, action: #selector(playButtonDidClicked), for: .touchUpInside)
        controlPanel.screenButton.addTarget(self, action: #selector(screenButtonDidClicked), for: .touchUpInside)
        controlPanel.slider.addTarget(self, action: #selector(sliderTouchUp(_:)), for: .touchUpInside)
        controlPanel.slider.addTarget(self, action: #selector(sliderTouchUp(_:)), for: .touchUpOutside)
        controlPanel.slider.addTarget(self, action: #selector(sliderTouchDown(_:)), for: .touchDown)
        controlPanel.slider.addTarget(self, action: #selector(sliderDraging(_:)), for: .valueChanged)
        addSubview(controlPanel)
        controlPanel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.right.left.equalToSuperview()
            make.height.equalTo(40)
        }
    }
    
    /** 配置全屏界面*/
    private func createAllScreenNavigationBar()  {
        fullMaskView = HYFullScreenMaskView()
        fullMaskView?.delegate = self
        let fullMaskTap = UITapGestureRecognizer.init(target: self, action: #selector(playerViewDidTapped))
        fullMaskView?.addGestureRecognizer(fullMaskTap)
        let fullMaskMoreTap = UITapGestureRecognizer.init(target:self, action: #selector(playButtonDidClicked))
        fullMaskMoreTap.numberOfTapsRequired = 2
        fullMaskView?.addGestureRecognizer(fullMaskMoreTap)
        fullMaskView?.backBtn.addTarget(self, action: #selector(screenButtonDidClicked), for: .touchUpInside)
        fullMaskView?.lockBtn.addTarget(self, action: #selector(fullScreenLockClicked), for: .touchUpInside)
        fullMaskView?.moreBtn.addTarget(self, action: #selector(fullScreenMoreClicked), for: .touchUpInside)
        addSubview(fullMaskView!)
        fullMaskView?.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    /** 配置播放完毕展示视图*/
    private func createEndPlayView() {
        endPlayView = HYEndPlayView()
        endPlayView?.isHidden = true
        endPlayView?.replayBtn.addTarget(self, action: #selector(replayItem), for: .touchUpInside)
        addSubview(endPlayView!)
        endPlayView?.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
    }
    
    //MARK: 通知监听
    /** 添加通知监听*/
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(avplayerItemDidPlayToEndTime(_:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
        print("HYPlayerCommonView Deinit")
    }
}

//MARK: 公共配置方法
extension HYPlayerCommonView {
    
    /** 暂停播放器*/
    func playerPause() {
        manager?.showControlPanel(animated: true)
        playTimer?.invalidate()
        manager?.hideTimer?.invalidate()
        videoPlayer?.pause()
    }
    
    /** 继续播放*/
    func playerPlay() {
        videoPlayer?.play()
        if let rate = UserDefaults.standard.value(forKey: "HYPlayer_rate") as? Float {
            videoPlayer?.rate = rate
        }
        
        playTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(updatePanel(sender:)), userInfo: nil, repeats: true)
        manager?.resetHideTimer()
    }
    
    /// 更新当前播放内容
    /// - Parameter commonConfig: 播放配置
    func updateCurrentPlayer(playerConfig: HYPlayerCommonConfig) {
        
        manager?.playerConfig = playerConfig
        audioPlayView?.isHidden = manager?.isVideo == true
    }
    
    /** 修改播放器进度*/
    func changePlayerProgress(progress: Float) {
        manager?.updatePanel()
        manager?.changePlayerProgress(progress: progress)
    }
    
    /** 退出页面时的处理*/
    func dealToDisappear(){
        
        // 保存当前播放时间记录
        if let config = manager?.playerConfig, config.playContinue {
            manager?.setPlayContinue()
        }
        
        // 关闭播放器
        manager?.playerStatus = .stop
        // 销毁播放器计时器
        playTimer?.invalidate()
        // 销毁隐藏控制面板计时器
        manager?.hideTimer?.invalidate()
        // 关闭屏幕常亮
        UIApplication.shared.isIdleTimerDisabled = false
    }
}

//MARK: 私有处理方法
extension HYPlayerCommonView {
    
    /** 全屏播放处理*/
    private func dealForFullScreenPlayer()  {
        
        backgroundColor = .black
        // 防止手动先把设备置为横屏,导致下面的语句失效.
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        manager?.isFullScreen = true
        fullMaskView?.isHidden = false
        controlPanel?.screenButton.setImage(UIImage(named: "hy_video_ic_fullscreen", in: SOURCE_BUNDLE, compatibleWith: nil), for: .normal)
        
        removeFromSuperview()
        UIApplication.shared.windows.first?.addSubview(self)
        snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        playerLayer?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        
        
        bringSubviewToFront(fullMaskView!)
        bringSubviewToFront(controlPanel)
        
    }
    
    /** 回到小屏播放处理*/
    private func dealForNormalScreenPlayer() {
        
        backgroundColor = .white
        
        fullMaskView?.isHidden = true
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        manager?.isFullScreen = false
        controlPanel.isHidden = false
        bringSubviewToFront(controlPanel)
        controlPanel.alpha = 1
        controlPanel?.screenButton.setImage(UIImage(named: "hy_video_ic_normalscreen", in: SOURCE_BUNDLE, compatibleWith: nil), for: .normal)
        
        removeFromSuperview()
        fatherView?.addSubview(self)
        snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        playerLayer?.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_WIDTH / 16 * 9)
        
    }
}

//MARK: 屏幕拖动处理（快进|快退|亮度、音量调节）
extension HYPlayerCommonView {
    /** 开始滑动*/
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, fullMaskView?.lockBtn.isSelected == false {
            let touchPoint = touch.location(in: self)
            speedyManager?.startDrag(point: touchPoint)
        }
    }
    
    /** 滑动中*/
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, fullMaskView?.lockBtn.isSelected == false {
            let touchPoint = touch.location(in: self)
            speedyManager?.movedDrag(point: touchPoint)
        }
    }
    
    /** 结束滑动*/
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if fullMaskView?.lockBtn.isSelected == false {
            speedyManager?.endDrag()
        }
    }
    
    /** 滑动取消*/
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if fullMaskView?.lockBtn.isSelected == false {
//            playerPlay()
//        }
    }
}

//MARK: 控件事件
extension HYPlayerCommonView {
    
    /** app退出活跃状态*/
    @objc func applicationWillResignActive() {
        manager?.playerStatus = .pause
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    }
    
    /** app进入活跃状态*/
    @objc func applicationDidBecomeActive() {
        if manager?.isFullScreen == true {
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        }
    }
    
    /** 播放器屏幕被点击 -> 呼出控制面板*/
    @objc func playerViewDidTapped() {
        if fullMaskView?.moreFunctionView.frame.origin.x == SCREEN_HEIGHT - (fullMaskView?.moreFunctionWidth ?? 0) {
            // 收起更多功能面板
            fullMaskView?.hidMoreFunctionView()
            manager?.hideControlPanel(sender: nil)
        } else {
            if controlPanel.alpha == 0 {
                // 控制面板隐藏 -> 呼出
                manager?.showControlPanel(animated: true)
            } else {
                // 隐藏控制面板
                manager?.hideControlPanel(sender: nil)
            }
        }
    }
    
    /** 播放｜暂停按钮被点击*/
    @objc private func playButtonDidClicked() {
        switch manager?.playerStatus {
        case .playing:
            manager?.playerStatus = .pause
            break
        case .pause:
            manager?.playerStatus = .playing
            break
        default:
            break
        }
    }
    
    /** 全屏响应处理的方法（全屏状态回到小屏，小屏状态展开全屏）*/
    @objc private func screenButtonDidClicked() {
        if manager?.isFullScreen == false {
            placeHoldImgView.isHidden = true
            dealForFullScreenPlayer()
        } else if manager?.isFullScreen == true {
            fullMaskView?.hidMoreFunctionView()
            dealForNormalScreenPlayer()
        }
        
        manager?.resetHideTimer()
        
        if let isFullScreen = manager?.isFullScreen {
            delegate?.changeFullScreen(isFull: isFullScreen)
        }
    }
    
    /** 全屏锁定｜解锁*/
    @objc private func fullScreenLockClicked() {
        if let isLock = fullMaskView?.lockBtn.isSelected {
            fullMaskView?.lockBtn.isSelected = !isLock
            if !isLock {
                controlPanel.isHidden = true
                fullMaskView?.naviView.isHidden = true
                fullMaskView?.hidMoreFunctionView()
            } else {
                controlPanel.isHidden = false
                fullMaskView?.naviView.isHidden = false
            }
            
            manager?.resetHideTimer()
        }
    }
    
    /** 全屏更多功能*/
    @objc private func fullScreenMoreClicked() {
        if fullMaskView?.moreFunctionView.frame.origin.x == SCREEN_HEIGHT {
            fullMaskView?.showMoreFunctionView()
            manager?.hideTimer?.invalidate()
        } else {
            fullMaskView?.hidMoreFunctionView()
            manager?.resetHideTimer()
        }
    }
    
    /** 刷新播放器控制面板（进度｜时间）*/
    @objc func updatePanel(sender: Timer) {
        manager?.updatePanel()
    }
    
    /** 播放器进度条按下*/
    @objc func sliderTouchDown(_ sender: Any) {
        playerPause()
    }
    
    /** 播放器进度条拖拽过程*/
    @objc func sliderDraging(_ sender: UISlider) {
        manager?.updatePanel(progress: sender.value)
    }
    
    /** 播放器进度条抬起*/
    @objc func sliderTouchUp(_ sender: UISlider) {
        changePlayerProgress(progress: sender.value)
        playerPlay()
    }
    
    /** 视频播放完毕*/
    @objc func avplayerItemDidPlayToEndTime(_ notification: Notification) {
        endPlayView?.isHidden = false
        print("视频播放完毕")
    }
    
    /** 重播*/
    @objc func replayItem() {
        manager?.replayPlayerItem()
    }
}

//MARK: 更多功能调整
extension HYPlayerCommonView: HYFullScreenMaskViewDelegate {
    /** 更改播放器播放速度*/
    func changePlayerRate(rate: Float) {
        videoPlayer?.rate = rate
    }
}

//MARK: 缓存回调
extension HYPlayerCommonView: HYMediaCacherDelegate {
    /** 缓存进度更新*/
    func cacher<LocationType>(_ cacher: HYMediaCacher<LocationType>, cacheProgress progress: Float, of cache: HYMediaCacheManager) where LocationType : HYMediaCacheLocation {
        print("缓存进度更新：\(progress)")
        
        controlPanel.cacheView.frame = CGRect(x: 48, y: 20, width: (SCREEN_WIDTH - 176) * CGFloat(progress), height: 1)
    }
    
    /** 缓存开始*/
    func cacher<LocationType>(_ cacher: HYMediaCacher<LocationType>, didStartCacheOf cache: HYMediaCacheManager) where LocationType : HYMediaCacheLocation {
        print("缓存开始")
    }
    
    /** 缓存完成*/
    func cacher<LocationType>(_ cacher: HYMediaCacher<LocationType>, didFinishCacheOf cache: HYMediaCacheManager) where LocationType : HYMediaCacheLocation {
        print("缓存完成")
    }
    
    /** 缓存失败*/
    func cacher<LocationType>(_ cacher: HYMediaCacher<LocationType>, didFailToCache cache: HYMediaCacheManager) where LocationType : HYMediaCacheLocation {
        print("缓存失败")
    }
    
}
