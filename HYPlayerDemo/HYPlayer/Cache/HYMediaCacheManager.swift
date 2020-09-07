//
//  HYMediaCacheManager.swift
//  SuperPlayerDemo
//
//  Created by 黄益 on 2020/7/29.
//  Copyright © 2020 黄益. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

public enum HYMediaType {
    case audio
    case video
}

public class HYMediaCacheManager: NSObject {
    
    public let identifier: String
    public let remoteURL: URL
    
    private weak var delegate: HYMediaCacheDelegate?
    private let cacheLocation: HYMediaCacheLocation
    
    private var timer: Timer?
    
    private let cacheListPath: String
    public var isCached: Bool {
        
        let cacheList: [String]
        
        if let array = (NSArray(contentsOfFile: cacheListPath) as? [String]) {
            cacheList = Array(Set(array))
        } else {
            cacheList = []
        }
        
        return cacheList.contains(identifier)
    }
    
    private var exportSession: AVAssetExportSession?
    
    public private(set) var asset: AVAsset? {
        
        didSet {
            
            if let asset = asset, asset is AVURLAsset {
                
                let ext = cacheLocation.playURL.pathExtension
                
                let outputFileType: AVFileType
                let outputFileExt = HYMediaCacheManager.preferredLocalPathExtension(from: cacheLocation.mediaType)
                switch cacheLocation.mediaType {
                case .video:
                    outputFileType = AVFileType.mp4
                    
                case .audio:
                    outputFileType = AVFileType.caf
                    
                }
                
                guard ext == outputFileExt else {
                    exportSession = nil
                    print("文件输出类型不支持，请检查HYMediaCacheLocation中playURL的扩展名")
                    return
                }
                
                exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough)
                exportSession?.outputURL = cacheLocation.playURL
                //TODO: 添加文件类型的判断，适配音频缓存
                exportSession?.outputFileType = outputFileType
            } else {
                exportSession = nil
            }
        }
    }
    
    init(cacheLocation: HYMediaCacheLocation, cacheListPath: String, delegate: HYMediaCacheDelegate) {
        
        self.cacheLocation = cacheLocation
        self.cacheListPath = cacheListPath
        
        identifier = cacheLocation.identifier
        remoteURL = cacheLocation.originalURL
        
        super.init()
        
        self.delegate = delegate
        
        updateAsset()
        
        NotificationCenter.default.addObserver(self, selector: #selector(deleteDecryptedFile), name: UIApplication.willTerminateNotification, object: nil)
    }
    
    deinit {
        
        print("====================")
        print("HYMediaCacheManager deinit")
        print("停止缓存任务")
        print("删除未加密的文件")
        print("====================")
        
        exportSession?.cancelExport()
        deleteDecryptedFile()
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.willTerminateNotification, object: nil)
    }
    
    public class func preferredLocalPathExtension(from mediaType: HYMediaType) -> String {
        switch mediaType {
        case .audio:
            return "caf"
        case .video:
            return "mp4"
        }
    }
    
    enum CacheStatus {
        case caching
        case cached
        case begin
        case failed
    }
    
    func start() -> CacheStatus {
        
        updateAsset()
        
        guard !isCached, let session = self.exportSession else { return .cached }
        
        switch session.status {
        case .failed:
            return .failed
        case .waiting, .exporting:
            return .caching
        case .completed:
            return .cached
        case .unknown, .cancelled:
            break
        default:
            break
        }
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(postProgress(_:)), userInfo: nil, repeats: true)
        
        session.exportAsynchronously {
            
            self.timer?.invalidate()
            
            DispatchQueue.main.async {
                
                if session.status == AVAssetExportSession.Status.completed {
                    
                    self.delegate?.cache(self, progress: 1)
                    
                    if let _ = self.createEncryptedFile() {
                        
                        //把远程的AVURLAsset替换成本地的AVAsset，并把session设为空
                        if let outputURL = session.outputURL {
                            
                            self.asset = AVAsset(url: outputURL)
                            self.exportSession = nil
                        }
                        
                        self.delegate?.cacheDidFinished(self)
                    }
                } else {
                    
                    print("AVAssetExportSession Error:", session.error ?? "")
                    self.delegate?.cacheDidFailed(self, withError: session.error)
                }
            }
        }
        
        return .begin
    }
    
    /// 停止缓存，并删除已缓存的【临时数据】。如果缓存已完成，不会删除任何数据。
    func stop() -> Bool {
        
        guard let status = exportSession?.status else { return false }
        
        if status == .exporting || status == .waiting || status == .unknown {
            exportSession?.cancelExport()   //这个方法会自动删除未缓存完的数据
            return true
        } else {
            return false
        }
    }
    
    /// 暂停缓存。如果暂停前状态为【正在缓存】【等待缓存】【未开始缓存】返回true，否则返回false。
    func suspend() -> Bool {
        
        guard let status = exportSession?.status else { return false }
        
        if status == .exporting || status == .waiting || status == .unknown {
            exportSession?.cancelExport()
            return true
        } else {
            return false
        }
    }
    
    /// 更新asset属性。如果asset已经存在，且类型与将要创建的asset类型相同，则不会更新。如果视频已经缓存，asset指向本地文件；否则，asset指向远程文件。这个方法同时会触发exportSession属性的didSet方法。
    private func updateAsset() {
        
        if isCached && (asset is AVURLAsset == false || asset == nil) {
            
            if let url = createDecryptedFile() {
                asset = AVAsset(url: url)
            } else {
                asset = nil
            }
        } else if !isCached, (asset is AVURLAsset || asset == nil) {
            
            let asset = AVURLAsset(url: cacheLocation.authenticatedURL)
            asset.resourceLoader.setDelegate(self, queue: DispatchQueue.main)
            self.asset = asset
        }
    }
    
    /// 发送缓存进度
    @objc private func postProgress(_ sender: Timer) {
        
        guard let progress = exportSession?.progress else {
            sender.invalidate()
            return
        }
        
        delegate?.cache(self, progress: progress)
    }
}

extension HYMediaCacheManager: AVAssetResourceLoaderDelegate {
    
}

extension HYMediaCacheManager {
    
    /// 根据加密文件创建未加密文件。如果创建成功，返回解密文件的URL；否则，返回nil。
    func createDecryptedFile() -> URL? {
        
        let encryptedURL = cacheLocation.storageURL
        
        guard FileManager.default.fileExists(atPath: encryptedURL.path) else {
            print("加密视频文件不存在，无法创建未加密视频文件")
            return nil
        }
        
        do {
            try? FileManager.default.removeItem(at: cacheLocation.playURL)
            try FileManager.default.copyItem(at: encryptedURL, to: cacheLocation.playURL)
            try HYMediaCryptor.endecryptFile(at: cacheLocation.playURL)
            return cacheLocation.playURL
        } catch let error {
            print("创建未加密文件失败，错误：", error.localizedDescription)
            return nil
        }
    }
    
    /// 删除未加密文件
    @objc func deleteDecryptedFile() {
        
        let url = cacheLocation.playURL
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("未加密视频文件不存在，无需删除")
            return
        }
        
        do {
            try FileManager.default.removeItem(at: url)
            print("删除未加密视频：\(url.path)")
        } catch let error {
            print("无法删除未加密视频，错误：", error.localizedDescription)
        }
        
    }
    
    /// 删除加密文件
    func deleteEncryptedFile() {
        
        let url = cacheLocation.storageURL
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("加密视频文件不存在，无需删除")
            return
        }
        
        do {
            try FileManager.default.removeItem(at: url)
            print("删除加密视频：\(url.path)")
        } catch let error {
            print("无法删除加密视频，错误：", error.localizedDescription)
        }
    }
    
    /// 根据未加密文件创建加密文件
    private func createEncryptedFile() -> URL? {
        
        let decryptedURL = cacheLocation.playURL
        
        guard FileManager.default.fileExists(atPath: decryptedURL.path) else {
            print("未加密视频文件不存在，无法创建加密视频")
            return nil
        }
        
        do {
            try? FileManager.default.removeItem(at: cacheLocation.storageURL)
            try FileManager.default.copyItem(at: decryptedURL, to: cacheLocation.storageURL)
            try HYMediaCryptor.endecryptFile(at: cacheLocation.storageURL)
            return cacheLocation.storageURL
        } catch let error {
            print("创建加密文件失败，错误：", error.localizedDescription)
            return nil
        }
    }
}
