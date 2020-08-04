//
//  HYAudiovisualCommonManager.swift
//  SuperPlayerDemo
//
//  Created by 黄益 on 2020/7/30.
//  Copyright © 2020 黄益. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class HYAudiovisualCommonManager: NSObject {
    
    weak var playerView: HYAudiovisualCommonView?
    
    /// 隐藏状态栏计时器
    var hideTimer: Timer?
    
    /// 当前音视频配置
    var playerConfig: HYAudiovisualCommonConfig? {
        willSet {
            // 判断是否为第一次初始化，否则判断是否进行断点续播存储
            if let config = playerConfig {
                if config.playContinue {
                    setPlayContinue()
                }
            }
        }
        
        didSet {
            //  初始化播放器
            if let config = playerConfig {
                isVideo = config.videoUrl != nil && config.videoUrl != ""
                updatePlayerItem(config: config)
            }
        }
    }
    
    /// 当前播放器状态
    var playerStatus: HYAudiovisualStatus? {
        didSet {
            if let status = playerStatus {
                
                playerView?.controlPanel.playButton.setImage(status.controlPlayImg, for: .normal)
                //                playerView?.placeHoldImgView.isHidden = status != .prepare
                
                switch status {
                case .playing:
                    guard playerView?.videoPlayer?.currentItem != nil  else {
                        return
                    }
                    
                    playerView?.videoPlayer?.play()
                    if let rate = UserDefaults.standard.value(forKey: "HYPlayer_rate") as? Float {
                        playerView?.videoPlayer?.rate = rate
                    }
                    if !isVideo {
                        playerView?.audioPlayView?.startAudioAnimation()
                    }
                    showControlPanel(animated: true)
                    resetHideTimer()
                    break
                case .pause:
                    
                    playerView?.playerPause()
                    
                    if !isVideo {
                        playerView?.audioPlayView?.stopAudioAnimation()
                    }
                    
                    break
                case .stop:
                    playerView?.videoPlayer?.pause()
                    playerView?.videoPlayer?.replaceCurrentItem(with: nil)
                    break
                default:
                    break
                }
            }
        }
    }
    
    /// 当前播放是否为视频播放
    var isVideo: Bool!
    /// 当前播放器是否全屏
    var isFullScreen = false
    
    /// 视频缓存
    private let videoCacher: HYMediaCacher = HYMediaCacher<HYDefaultVideoCacheLocation>()
    /// 断点续播节点列表
    private var playContiuneListPath: String = HYFileDirectory.PlayContinue.listPlist
    /// 当前播放地址
    private var currentPlayerUrl: String?
    /// 播放暂停时候的时间和播放URL
    private var playStatusWhenPaused: (time: CMTime, playURL: URL)?
    
    
    convenience init(_ view: HYAudiovisualCommonView) {
        self.init()
        
        playerView = view
    }
    
    /** 初始化播放器*/
    func updatePlayerItem(config: HYAudiovisualCommonConfig) {
        // 设置全屏标题
        playerView?.fullMaskView?.titleLab.text = config.title
        
        // 封面图处理
        if let imgStr = config.placeHoldImgStr {
            playerView?.placeHoldImgView.isHidden = false
            playerView?.placeHoldImgView.image = UIImage(named: imgStr)
        } else if let imgUrl = config.placeHoldImgUrl {
            playerView?.placeHoldImgView.isHidden = false
            let data = try? Data(contentsOf: imgUrl)
            if let imageData = data {
                let image = UIImage(data: imageData)
                playerView?.placeHoldImgView.image = image
            }
        }
        
        // 初始化播放器
        if let urlStr = config.videoUrl {
            playVideo(urlStr: urlStr, needCache: config.needCache, playContinue: config.playContinue)
        } else if let urlStr = config.audioUrl {
            playVideo(urlStr: urlStr, needCache: config.needCache, playContinue: config.playContinue)
        }
    }
    
    /** 重播*/
    func replayPlayerItem() {
        playerView?.endPlayView?.isHidden = true
        
        playerView?.videoPlayer?.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
        playerView?.videoPlayer?.play()
        if let rate = UserDefaults.standard.value(forKey: "HYPlayer_rate") as? Float {
            playerView?.videoPlayer?.rate = rate
        }
    }
    
    /** 播放视频*/
    private func playVideo(urlStr: String, needCache: Bool, playContinue: Bool) {
        
        func playVideo(item: AVPlayerItem) {
            playerView?.videoPlayer?.pause()
            
            if playerView?.videoPlayer == nil {
                // 初始化播放器
                playerView?.videoPlayer = AVPlayer(playerItem: item)
                playerView?.playerLayer = AVPlayerLayer(player: playerView?.videoPlayer)
                playerView?.playerLayer?.videoGravity = .resizeAspectFill
                playerView?.playerLayer?.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_WIDTH / 16 * 9)
                playerView?.videoView.layer.addSublayer((playerView?.playerLayer!)!)
            } else {
                // 替换播放资源
                playerView?.videoPlayer?.replaceCurrentItem(with: item)
            }
            
            /// 进行视频的播放
            playerStatus = .playing
            
            if playContinue {
                if let playContinueList = NSDictionary(contentsOfFile: playContiuneListPath) {
                    
                    if let playContinueTime = playContinueList[urlStr.md5] as? Double,
                        let timescale = playerView?.videoPlayer?.currentTime().timescale{
                        playerView?.videoPlayer?.seek(to: CMTime(seconds: playContinueTime, preferredTimescale: timescale))
                    }
                }
            }
        }
        
        currentPlayerUrl = urlStr
        
        let videoUrl = URL(string: urlStr)
        if needCache {
            // 缓存的处理
            let location = HYDefaultVideoCacheLocation(remoteURL: videoUrl!, mediaType: isVideo ? .video : .audio)
            let canCache = HYCacheStorage.available > Float(500 * 1024 * 1024)
            videoCacher.delegate = playerView
            
            // 如已缓存 -> 播放缓存，未缓存 -> 播放Url并进行本地缓存
            if let cache = videoCacher.makeCache(location: location, cacheImmediately: canCache){
                
                if let asset = cache.asset {
                    let item = AVPlayerItem(asset: asset)
                    
                    DispatchQueue.main.async {
                        playVideo(item: item)
                        
                        // 已缓存则读满进度
                        if self.videoCacher.cacheList.contains(cache.identifier) {
                            self.playerView?.controlPanel.cacheView.frame = CGRect(x: 48, y: 20, width: SCREEN_WIDTH - 176, height: 1)
                        }
                    }
                    
                } else {
                    print("视频无法播放")
                }
            }
        } else {
            // 不缓存 -> 直接播放
            let item = AVPlayerItem(url: videoUrl!)
            
            playVideo(item: item)
        }
        
    }
    
    /** 保存断点续播数据*/
    func setPlayContinue() {
        if let urlStr = currentPlayerUrl,
            let currentTime = playerView?.videoPlayer?.currentItem?.currentTime().seconds
        {
            if let playContinueList = NSDictionary(contentsOfFile: playContiuneListPath),
                var playContinueDic = playContinueList as? Dictionary<String, Any> {
                // 已存在记录 -> 添加
                playContinueDic[urlStr.md5] = currentTime
                (playContinueDic as NSDictionary).write(toFile: playContiuneListPath, atomically: true)
            } else {
                // 未存在 —> 新增
                ([urlStr.md5: currentTime] as NSDictionary).write(toFile: playContiuneListPath, atomically: true)
            }
        }
    }
}


//MARK: 控制面板相关
extension HYAudiovisualCommonManager {
    /** 刷新播放器控制面板（进度｜时间）*/
    func updatePanel(progress: Float? = nil) {
        guard let currentTime = playerView?.videoPlayer?.currentItem?.currentTime().seconds,
            let timescale = playerView?.videoPlayer?.currentTime().timescale,
            let duration = playerView?.videoPlayer?.currentItem?.duration.seconds,
            !currentTime.isNaN && !duration.isNaN
            else {
                return
        }
        
        // 更改控制面板显示
        let totalMM = Int(duration / 60)
        let totalSS = Int(duration.truncatingRemainder(dividingBy: 60))
        let currentMM = Int(currentTime / 60)
        let currentSS = Int(currentTime.truncatingRemainder(dividingBy: 60))
        let string = String(format: "%.2i:%.2i/%.2i:%.2i", currentMM, currentSS, totalMM, totalSS)
        
        // 时间显示修改
        playerView?.controlPanel.timeLabel.text = string
        // 进度条修改
        if let progress = progress {
            let time = CMTime(seconds: duration * Double(progress), preferredTimescale: timescale)
            playerView?.videoPlayer?.seek(to: time)
        } else {
            playerView?.controlPanel.slider.value = Float(currentTime) / Float(duration)
        }
    }
    
    
    /// 修改播放器进度
    /// - Parameter progress: 进度
    func changePlayerProgress(progress: Float) {
        if let timescale = playerView?.videoPlayer?.currentTime().timescale,
            let duration = playerView?.videoPlayer?.currentItem?.duration.seconds,
            !duration.isNaN
        {
            
            let currentTime: Double
            if progress < 1 {
                currentTime = (Double(progress) * duration)
            } else {
                currentTime = duration - 2
            }
            
            let time = CMTime(seconds: currentTime, preferredTimescale: timescale)
            playerView?.videoPlayer?.seek(to: time)
        }
    }
    
    /** 显示和隐藏控制面板*/
    func showControlPanel(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.25, animations: {
                if self.playerView?.fullMaskView?.lockBtn.isSelected == false {
                    self.playerView?.controlPanel.isHidden = false
                }
                
                if self.isFullScreen {
                    self.playerView?.fullMaskView?.isHidden = false
                } else {
                    self.playerView?.fullMaskView?.isHidden = true
                }
                
                self.playerView?.controlPanel.alpha = 1
                self.playerView?.fullMaskView?.alpha = 1
            }) { (_) in
            }
        } else {
            
            playerView?.fullMaskView?.alpha = 1
            playerView?.controlPanel.alpha = 1
            playerView?.fullMaskView?.isHidden = false
            
            if self.playerView?.fullMaskView?.lockBtn.isSelected == false {
                playerView?.controlPanel.isHidden = false
            }
        }
        
        resetHideTimer()
    }
    
    // 隐藏控制面板
    @objc func hideControlPanel(sender: Timer?) {
        sender?.invalidate()
        
        if !(playerStatus == .pause && sender != nil) {
            UIView.animate(withDuration: 0.25, animations: {
                self.playerView?.controlPanel.alpha = 0
                if self.isFullScreen {
                    self.playerView?.fullMaskView?.alpha = 0
                }
            }) { (_) in
                self.playerView?.controlPanel.isHidden = true
                if self.isFullScreen {
                    self.playerView?.fullMaskView?.isHidden = true
                }
            }
        }
    }
    
    /** 重置隐藏控制面板计时器*/
    func resetHideTimer() {
        hideTimer?.invalidate()
        hideTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(hideControlPanel(sender:)), userInfo: nil, repeats: false)
    }
}


