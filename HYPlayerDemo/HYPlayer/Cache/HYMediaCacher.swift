//
//  HYMediaCacher.swift
//  SuperPlayerDemo
//
//  Created by 黄益 on 2020/7/29.
//  Copyright © 2020 黄益. All rights reserved.
//

import Foundation
import UIKit

public class HYMediaCacher<Location: HYMediaCacheLocation> {
    
    /// 缓存记录文件路径
    private let cacheListPath: String
    
    /// 缓存记录，记录的是缓存视频的identifier
    public private(set) var cacheList: [String] {
        
        get {
            
            if let array = (NSArray(contentsOfFile: cacheListPath) as? [String]) {
                return Array(Set(array))
            } else {
                return []
            }
        }
        
        set {
            
            let array = Array(Set(newValue))
            (array as NSArray).write(toFile: cacheListPath, atomically: true)
        }
    }
    
    /// 正在进行的缓存
    public private(set) var currentCache: HYMediaCacheManager?
    
    /// 暂停的缓存
    private var suspendedCaches: Set<HYMediaCacheManager> = []
    
    public weak var delegate: HYMediaCacherDelegate?
    
    public init() {
        
        self.cacheListPath = Location.cacheListPath
        
        if
            !FileManager.default.fileExists(atPath: cacheListPath),
            !FileManager.default.createFile(atPath: cacheListPath, contents: nil, attributes: nil)
        {
            print("缓存列表文件创建失败")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(stopAllCaches), name: UIApplication.willTerminateNotification, object: nil)
    }
    
    deinit {
        
        print("HYVideoCacher deinit")
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.willTerminateNotification, object: nil)
    }
    
    /// 创建缓存
    ///
    /// - Parameters:
    ///   - location: 视频地址
    ///   - cacheImmediately: 是否马上开始
    /// - Returns: 如果缓存已完成，缓存的asset指向本地文件；如果视频未缓存，缓存的asset指向远程文件。
    public func makeCache(location: Location, cacheImmediately: Bool = false) -> HYMediaCacheManager? {
        
        if let cache = self.currentCache {
            
            if cache.identifier == location.identifier {
                
                return currentCache
//                //不创建，直接返回当前缓存
//                if cacheImmediately {
//                    _ = cache.start()
//                } else {
//                    _ = cache.suspend()
//                }
//
//                return cache
            } else {
                //记录未缓存完成的视频
                suspendCache(cache)
            }
        }
        
        //创建新视频
        let cache: HYMediaCacheManager
        
        let caches = suspendedCaches.filter { $0.identifier == location.identifier }
        
        if
            let first = caches.first,
            let suspendingCache = suspendedCaches.remove(first) {
            
            //从暂停列表中取出需要缓存的视频
            cache = suspendingCache
        } else {
            
            //创建一个新视频
            cache = HYMediaCacheManager(cacheLocation: location, cacheListPath: cacheListPath, delegate: self)
        }
        
        if cacheImmediately {
            _ = cache.start()
        }
        self.currentCache = cache
        
        return cache
    }
    
    /// 判断音视频是否已经缓存
    public func isUrlCached(url: String) -> Bool {
        if cacheList.contains(url.HYmd5) {
            return true
        }
        return false
    }
    
    /// 开始视频缓存
    public func startCache(_ cache: HYMediaCacheManager) {
        
        //TODO: 根据start()的结果作出相应提示和处理
        _ = cache.start()
        suspendedCaches.remove(cache)
    }
    
    /// 暂停视频缓存
    public func suspendCache(_ cache: HYMediaCacheManager) {
        
        if cache.suspend() {
            suspendedCaches.insert(cache)
        }
    }
    
    /// 停止视频缓存，并清除临时数据
    public func stopCache(_ cache: HYMediaCacheManager) {
        
        //TODO: 根据stop()的结果作出相应提示和处理
        _ = cache.stop()
        suspendedCaches.remove(cache)
    }
    
    /// 停止所有缓存，并清除临时数据
    @objc private func stopAllCaches() {
        
        for cache in suspendedCaches {
            stopCache(cache)
        }
    }
    
    /// 删除视频缓存（未启用）
    private func removeCache(_ cache: HYMediaCacheManager) {
        
        //删除加密文件
        cache.deleteEncryptedFile()
        //删除未加密文件
        cache.deleteDecryptedFile()
        //删除缓存标记
        cacheList = cacheList.filter { $0 != cache.identifier }
    }
}

//MARK: - 直接对磁盘文件进行操作的方法
extension HYMediaCacher {
    
    /// 删除视频缓存
    public func removeCache(located location: Location) {
        
        let cache = HYMediaCacheManager(cacheLocation: location, cacheListPath: cacheListPath, delegate: self)
        removeCache(cache)
    }
}

extension HYMediaCacher: HYMediaCacheDelegate {
    
    /// 缓存进度更新
    func cache(_ cache: HYMediaCacheManager, progress: Float) {
        delegate?.cacher(self, cacheProgress: progress, of: cache)
    }
    
    /// 缓存开始
    func cacheDidStarted(_ cache: HYMediaCacheManager) {
        delegate?.cacher(self, didStartCacheOf: cache)
    }
    
    /// 缓存完成
    func cacheDidFinished(_ cache: HYMediaCacheManager) {
        cacheList.append(cache.identifier)
        delegate?.cacher(self, didFinishCacheOf: cache)
    }
    
    /// 缓存失败
    func cacheDidFailed(_ cache: HYMediaCacheManager, withError error: Error?) {
        delegate?.cacher(self, didFailToCache: cache)
    }
}
