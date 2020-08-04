//
//  HYCacheStorage.swift
//  SuperPlayerDemo
//
//  Created by 黄益 on 2020/7/31.
//  Copyright © 2020 黄益. All rights reserved.
//

import Foundation

/// 存储空间
struct HYCacheStorage {
    
    private static var dict: [FileAttributeKey : Any] {
        
        let path = NSHomeDirectory()
        
        do {
            let dict = try FileManager.default.attributesOfFileSystem(forPath: path)
            return dict
        } catch let error {
            print(error.localizedDescription)
            return [:]
        }
    }
    
    /// 总容量
    static var capacity: Float? {
        return (dict[FileAttributeKey.systemSize] as? NSNumber)?.floatValue ?? 0
    }
    
    /// 可用容量
    static var available: Float {
        return (dict[FileAttributeKey.systemFreeSize] as? NSNumber)?.floatValue ?? 0
    }
    
}
