//
//  PlayerCacheListController.swift
//  HYPlayerDemo
//
//  Created by 黄益 on 2020/8/16.
//  Copyright © 2020 黄益. All rights reserved.
//

import UIKit

class PlayerCacheListController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        createUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(cacheProgressUpdate(_:)), name: NSNotification.Name.HYVideoCacheManagerDidUpdateProgress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cacheManagerDidFinishCachingAVideo(_:)), name: NSNotification.Name.HYVideoCacheManagerDidFinishCachingAVideo, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cacheManagerDidFinishCachingAllVideos(_:)), name: NSNotification.Name.HYVideoCacheManagerDidFinishCachingAllVideos, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    

    private func createUI() {
        
    }

    private func startCache(mp4URLs: [URL]) {
        if HYVideoCacheManager.shared.cacheVideos(with: mp4URLs) {
            // 开始缓存
            print("开始缓存")
        } else {
            print("无法下载视频")
        }
    }
    
    
    /** 下载进度更新*/
    @objc private func cacheProgressUpdate(_ notification: Notification) {
        if let progress = (notification.userInfo?["progress"] as? NSNumber)?.floatValue {
            print("缓存进度\(progress)")
        }
    }
    
    /** 下载完成*/
    @objc private func cacheManagerDidFinishCachingAVideo(_ notification: Notification) {
        if let cacheLocation = notification.userInfo?["videoCache"] as? HYMediaCacheLocation {
            print("下载完成")
        }
        
    }
    
    /** 下载全部完成*/
    @objc func cacheManagerDidFinishCachingAllVideos(_ notification: Notification) {
        print("全部下载完成")
    }
}
