//
//  HYDefaultVideoCacheLocation.swift
//  SuperPlayerDemo
//
//  Created by 黄益 on 2020/7/29.
//  Copyright © 2020 黄益. All rights reserved.
//

import Foundation


struct HYDefaultVideoCacheLocation: HYMediaCacheLocation {
    
    /// 缓存的列表
    static var cacheListPath: String = HYFileDirectory.VideoCache.cachesPlist
    
    /// 缓存呢标志
    var identifier: String
    /// 鉴权地址（需鉴权可修改）
    var authenticatedURL: URL
    /// 原始地址
    var originalURL: URL
    
    var storageURL: URL
    
    var playURL: URL
    
    let mediaType: HYMediaType
    
    init(remoteURL: URL, mediaType: HYMediaType) {
        let videoDirectory = HYFileDirectory.VideoCache.videoDirectory
        
        func playURL(originalURL: URL, identifier: String) -> URL {
            
            let fileName = (identifier + "_decrypted").md5
            let filePath = videoDirectory + "/" + fileName + "." + originalURL.pathExtension
            return URL(fileURLWithPath: filePath)
        }
        
        func storageURL(originalURL: URL, identifier: String) -> URL {
            
            let fileName = identifier
            let filePath = videoDirectory + "/" + fileName + "." + originalURL.pathExtension
            return URL(fileURLWithPath: filePath)
        }
        
        self.identifier = remoteURL.absoluteString.md5
        
        self.originalURL = remoteURL
        self.authenticatedURL = remoteURL
        
        self.storageURL = storageURL(originalURL: remoteURL, identifier: identifier)
        self.playURL = playURL(originalURL: remoteURL, identifier: identifier)
        
        self.mediaType = mediaType
        
        if !FileManager.default.fileExists(atPath: videoDirectory) {
            try? FileManager.default.createDirectory(atPath: videoDirectory, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    
}
