//
//  HYMediaCacheLocation.swift
//  SuperPlayerDemo
//
//  Created by 黄益 on 2020/7/29.
//  Copyright © 2020 黄益. All rights reserved.
//

import Foundation

public protocol HYMediaCacheLocation {
    
    var identifier: String { get }
    
    //远程URL。一般远程URL需要鉴权才能播放。如果远程URL可以直接播放，authenticatedURL和originalURL可以一样。
    var authenticatedURL: URL { get }
    var originalURL: URL { get }
    
    //本地URL。一般本地文件储存时需要加密，播放时再解密。如果本地文件不需要加密，storageURL和playURL可以一样。
    //扩展名必须为HCMediaCache.preferredLocalPathExtension方法返回的值，否则文件将无法缓存或播放。
    var storageURL: URL { get }
    var playURL: URL { get }
    
    var mediaType: HYMediaType { get }
    
    /// 缓存列表存放路径
    static var cacheListPath: String { get }
    
    init(remoteURL: URL, mediaType: HYMediaType)
}
