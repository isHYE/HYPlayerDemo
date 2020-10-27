//
//  HYAudiovisualSpeedyManager.swift
//  SuperPlayerDemo
//
//  Created by 黄益 on 2020/7/31.
//  Copyright © 2020 黄益. All rights reserved.
//  播放器快捷操作

import Foundation
import MediaPlayer

class HYAudiovisualSpeedyManager {
    
    enum SpeedyType {
        /// 快进
        case fastForward
        /// 快退
        case fastRewind
        /// 调亮
        case lightingUp
        /// 调暗
        case lightingDown
        /// 音量调高
        case volumeUp
        /// 音量调低
        case volumeDown
        
        var remindImg: UIImage? {
            switch self {
            case .fastForward:
                return UIImage(named: "hy_video_fastForward", in: HY_SOURCE_BUNDLE, compatibleWith: nil)
            case .fastRewind:
                return UIImage(named: "hy_video_fastRewind", in: HY_SOURCE_BUNDLE, compatibleWith: nil)
            case .lightingUp, .lightingDown:
                return UIImage(named: "hy_video_light", in: HY_SOURCE_BUNDLE, compatibleWith: nil)
            default:
                return nil
            }
        }
        
    }
    
    weak var playerView: HYPlayerCommonView?
    
    /// 当前快捷操作类型
    var currentSpeedyType: SpeedyType?
    
    /// 进度调节起始进度
    private var tempCurrentTime: Double?
    /// 亮度调节起始亮度
    private var tempCurrentLighting: CGFloat?
    /// 音量调节起始音量
    private var tempCurrentVolume: Float?
    
    // 获取设置声音的slider
    private lazy var volumeSlider: UISlider? = {
        let v = MPVolumeView()
//        v.showsRouteButton = true
        v.showsVolumeSlider = true
        v.sizeToFit()
        v.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        for v in v.subviews {
            if (v.classForCoder.description() == "MPVolumeSlider") {
                return v as? UISlider
            }
        }
        return nil
    }()
    
    
    /// 触摸起始点
    private var startPoint: CGPoint?
    /// 开始快捷操作
    private var isSpeedyStart = false
    
    convenience init(_ view: HYPlayerCommonView) {
        self.init()
        
        playerView = view
    }
    
    /** 开始拖拽起始点*/
    func startDrag(point: CGPoint) {
        startPoint = point
        isSpeedyStart = false
        currentSpeedyType = nil
    }
    
    /** 拖拽最新点更新*/
    func movedDrag(point: CGPoint) {
        
        guard let startPoint = startPoint, startPoint != point else {
            endDrag()
            return
        }
        
        // 判断调整类型
        if abs(point.x - startPoint.x) > abs(point.y - startPoint.y)
            && (currentSpeedyType == nil || currentSpeedyType == .fastForward || currentSpeedyType == .fastRewind)
        {
            // 快进｜快退
            currentSpeedyType = point.x > startPoint.x ? .fastForward : .fastRewind
        }
        else if startPoint.x < HY_SCREEN_WIDTH / 2
            && abs(point.x - startPoint.x) < abs(point.y - startPoint.y)
            && (currentSpeedyType == nil || currentSpeedyType == .lightingUp || currentSpeedyType == .lightingDown)
        {
            // 亮度调节
            currentSpeedyType = point.y < startPoint.y ? .lightingUp : .lightingDown
        }
        else if startPoint.x > HY_SCREEN_WIDTH / 2
            && abs(point.x - startPoint.x) < abs(point.y - startPoint.y)
            && (currentSpeedyType == nil || currentSpeedyType == .volumeUp || currentSpeedyType == .volumeDown)
        {
            // 声音调节
            currentSpeedyType = point.y < startPoint.y ? .volumeUp : .volumeDown
        }
        
        
        if (abs(point.x - startPoint.x) > 10 || abs(point.y - startPoint.y) > 10) && !isSpeedyStart {
            isSpeedyStart = true
            
            if currentSpeedyType != nil {
                
                if currentSpeedyType != .volumeUp && currentSpeedyType != .volumeDown {
                    // 展示快捷操作提示
                    playerView?.speedyRemindView?.isHidden = false
                }
                
                if currentSpeedyType == .fastForward || currentSpeedyType == .fastRewind {
                    // 暂停播放器
                    playerView?.playerPause()
                }
            }
        }
        
        // 调节
        if let currentSpeedyType = currentSpeedyType {
            switch currentSpeedyType {
            // 进度调节
            case .fastForward, .fastRewind:
                
                if let currentTime = playerView?.videoPlayer?.currentItem?.currentTime().seconds,
                    let duration = playerView?.videoPlayer?.currentItem?.duration.seconds,
                    !duration.isNaN
                {
                    if tempCurrentTime == nil {
                        tempCurrentTime = currentTime
                    }
                    
                    let speedyNum = Double(abs(point.x - startPoint.x)) / 5
                    
                    let speedyTime = tempCurrentTime! + (currentSpeedyType == .fastForward ? speedyNum : -speedyNum)
                    
                    // 调整当前播放时间点
                    if speedyTime < duration && speedyTime > 0 {
                        playerView?.speedyRemindView?.remindImgView.image = currentSpeedyType.remindImg
                        playerView?.speedyRemindView?.remindLab.text = (currentSpeedyType == .fastForward ? "+ " : "- ") + "\(Int(speedyNum))s"
                        
                        let progress = Float(speedyTime / duration)
                        
                        playerView?.controlPanel?.slider.value = progress
                        playerView?.changePlayerProgress(progress: progress)
                    }
                }
                break
                
            // 亮度调节
            case .lightingUp, .lightingDown:
                
                if tempCurrentLighting == nil {
                    tempCurrentLighting = UIScreen.main.brightness
                }
                
                let speedyNum = CGFloat(abs(point.y - startPoint.y)) / 80
                
                var speedyLighting = tempCurrentLighting! + (currentSpeedyType == .lightingUp ? speedyNum : -speedyNum)
                
                if speedyLighting < 0 {
                    speedyLighting = 0
                } else if speedyLighting > 1 {
                    speedyLighting = 1
                }
                
                if speedyLighting >= 0 && speedyLighting <= 1 {
                    playerView?.speedyRemindView?.remindImgView.image = currentSpeedyType.remindImg
                    playerView?.speedyRemindView?.remindLab.text = String(format: "%.0f", speedyLighting * 100) + "%"
                    UIScreen.main.brightness = speedyLighting
                }
                
                break
                
            // 音量调节
            case .volumeUp, .volumeDown:
                
                
                if tempCurrentVolume == nil {
                    tempCurrentVolume = volumeSlider?.value
                }
                
                let speedyNum = Float(abs(point.y - startPoint.y)) / 80
                
                var speedyVolume = tempCurrentVolume! + (currentSpeedyType == .volumeUp ? speedyNum : -speedyNum)
                
                if speedyVolume < 0 {
                    speedyVolume = 0
                } else if speedyVolume > 1 {
                    speedyVolume = 1
                }
                
                if speedyVolume >= 0 && speedyVolume <= 1 {
                    
                    volumeSlider?.setValue(speedyVolume, animated: false)
                }
                
                break
            }
            
            
        }
    } 
    
    /** 结束滑动*/
    func endDrag() {
        tempCurrentTime = nil
        tempCurrentLighting = nil
        playerView?.speedyRemindView?.isHidden = true
        
        if let currentSpeedyType = currentSpeedyType {
            if currentSpeedyType == .fastForward || currentSpeedyType == .fastRewind {
                playerView?.playerPlay()
            }
        }
    }
    
}
