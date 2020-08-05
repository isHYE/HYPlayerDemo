//
//  HYPlayerCommonConfig.swift
//  SuperPlayerDemo
//
//  Created by 黄益 on 2020/7/29.
//  Copyright © 2020 黄益. All rights reserved.
//

import Foundation

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
    var placeHoldImgUrl: URL?
    
    init<T>(title: String = "", audioUrl: String? = nil, videoUrl: String? = nil, needCache: Bool = false, playContinue: Bool = true, placeHoldImg: T? = nil) {
        self.title = title
        self.audioUrl = audioUrl
        self.videoUrl = videoUrl
        self.needCache = needCache
        
        if let img = placeHoldImg {
            if let imgStr = img as? String {
                placeHoldImgStr = imgStr
            } else if let imgUrl = img as? URL {
                placeHoldImgUrl = imgUrl
            }
        }
    }
}
