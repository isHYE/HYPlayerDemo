//
//  HYPlayerCommonConfig.swift
//  SuperPlayerDemo
//
//  Created by 黄益 on 2020/7/29.
//  Copyright © 2020 黄益. All rights reserved.
//

import Foundation
import UIKit

struct HYPlayerCommonConfig {
    
    /// 音视频标题
    var title: String?
    
    /// 视频地址
    var videoUrl: String?
    
    /// 音频地址
    var audioUrl: String?
    
    /// 是否需要缓存
    /// 支持缓存类型：视频（mp4），音频（caf）
    var needCache: Bool = false
    
    /// 是否断点续播（默认true）
    var playContinue: Bool = true
    
    /// 视频封面图
    var placeHoldImgStr: String?
    
    /// 自定义播放结束页面
    var customEndView: UIView?
    
    /// 自定义音频播放页面
    var customAudioView: UIView?
    
    /// 鉴权方法
    var authenticationFunc: ((URL) -> URL)?
    
    
    
    /// 初始化播放器配置
    /// - Parameters:
    ///   - title: 播放音视频标题（全屏时显示），可不传
    ///   - videoUrl: 播放视频地址（不传则播放音频）
    ///   - audioUrl: 播放音频地址
    ///   - needCache: 是否需要缓存（默认不开启）
    ///   - playContinue: 是否断点续播（默认开启）
    ///   - placeHoldImg: 封面图（可传本地图片String或网络图片URL）
    ///   - customEndView: 自定义播放结束界面（可不传）
    ///   - customAudioView: 自定义音频播放界面（可不传）
    ///   - authenticationFunc: 播放地址鉴权函数(可不传)
    init(title: String = "",
            videoUrl: String? = nil,
            audioUrl: String? = nil,
            needCache: Bool = false,
            playContinue: Bool = true,
            placeHoldImg: String? = nil,
            customEndView: UIView? = nil,
            customAudioView: UIView? = nil,
            authenticationFunc: ((URL) -> URL)? = nil)
    {
        self.title = title
        self.audioUrl = audioUrl
        self.videoUrl = videoUrl
        self.needCache = needCache
        self.playContinue = playContinue
        self.customEndView = customEndView
        self.placeHoldImgStr = placeHoldImg
        self.customAudioView = customAudioView
        self.authenticationFunc = authenticationFunc
    }
}
