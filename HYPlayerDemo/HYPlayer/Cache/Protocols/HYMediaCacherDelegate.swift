//
//  HYMediaCacherDelegate.swift
//  SuperPlayerDemo
//
//  Created by 黄益 on 2020/7/29.
//  Copyright © 2020 黄益. All rights reserved.
//

import Foundation

public protocol HYMediaCacherDelegate: class {
    
    /// 缓存进度更新
    func cacher<LocationType>(_ cacher: HYMediaCacher<LocationType>, cacheProgress progress: Float, of cache: HYMediaCacheManager)
    
    /// 缓存开始
    func cacher<LocationType>(_ cacher: HYMediaCacher<LocationType>, didStartCacheOf cache: HYMediaCacheManager)
    
    /// 缓存完成
    func cacher<LocationType>(_ cacher: HYMediaCacher<LocationType>, didFinishCacheOf cache: HYMediaCacheManager)
    
    /// 缓存失败
    func cacher<LocationType>(_ cacher: HYMediaCacher<LocationType>, didFailToCache cache: HYMediaCacheManager)
}
