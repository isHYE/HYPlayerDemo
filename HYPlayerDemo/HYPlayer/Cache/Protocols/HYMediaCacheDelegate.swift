//
//  HYMediaCacheDelegate.swift
//  SuperPlayerDemo
//
//  Created by 黄益 on 2020/7/29.
//  Copyright © 2020 黄益. All rights reserved.
//

import Foundation

protocol HYMediaCacheDelegate: class {
    
    /// 缓存进度更新
    func cache(_ cache: HYMediaCacheManager, progress: Float)
    
    /// 缓存开始
    func cacheDidStarted(_ cache: HYMediaCacheManager)
    
    /// 缓存完成
    func cacheDidFinished(_ cache: HYMediaCacheManager)
    
    /// 缓存失败
    func cacheDidFailed(_ cache: HYMediaCacheManager, withError error: Error?)
}
