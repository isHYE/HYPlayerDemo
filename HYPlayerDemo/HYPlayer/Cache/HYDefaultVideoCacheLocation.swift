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
    
    init(remoteURL: URL, mediaType: HYMediaType, authenticationFunc: ((URL) -> URL)? = nil) {
        self.init(remoteURL: remoteURL, mediaType: mediaType)
        
        
        if let authenticationFunc = authenticationFunc {
            self.authenticatedURL = authenticationFunc(remoteURL)
        }
    }
    
    // , authenticationFunc: ((URL) -> URL)? = nil
    init(remoteURL: URL, mediaType: HYMediaType) {
        
        let videoDirectory = HYFileDirectory.VideoCache.videoDirectory
        
        func playURL(originalURL: URL, identifier: String) -> URL {
            
            let pathExtension: String = originalURL.pathExtension
            
//            switch originalURL.pathExtension {
//            case "mp3", "caf":
//                pathExtension = "caf"
//
//            default:
//                pathExtension = originalURL.pathExtension
//            }
            
            let fileName = (identifier + "_decrypted").HYmd5
            let filePath = videoDirectory + "/" + fileName + "." + pathExtension
            return URL(fileURLWithPath: filePath)
        }
        
        func storageURL(originalURL: URL, identifier: String) -> URL {
            
            let pathExtension: String = originalURL.pathExtension
            
//            switch originalURL.pathExtension {
//            case "mp3", "caf":
//                pathExtension = "caf"
//
//            default:
//                pathExtension = originalURL.pathExtension
//            }
            
            let fileName = identifier
            let filePath = videoDirectory + "/" + fileName + "." + pathExtension
            return URL(fileURLWithPath: filePath)
        }
        
        self.identifier = remoteURL.absoluteString.HYmd5
        
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
