//
//  HYAudiovisualCommonModel.swift
//  SuperPlayerDemo
//
//  Created by 黄益 on 2020/7/30.
//  Copyright © 2020 黄益. All rights reserved.
//

import Foundation
import UIKit

enum HYAudiovisualStatus {
    
    /// 准备
    case prepare
    /// 正在播放
    case playing
    /// 暂停
    case pause
    /// 释放播放器（销毁时使用）
    case stop
    
    /// 控制面板播放按钮图标
    var controlPlayImg: UIImage? {
        switch self {
        case .playing:
            return UIImage(named: "hy_video_ic_pause", in: SOURCE_BUNDLE, compatibleWith: nil)
        case .pause:
            return UIImage(named: "hy_video_ic_play", in: SOURCE_BUNDLE, compatibleWith: nil)
        default:
            return nil
        }
    }
}
