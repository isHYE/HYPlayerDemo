//
//  HYPlayerCacheListView.swift
//  PTHLearning
//
//  Created by 黄益 on 2020/7/2.
//  Copyright © 2020 黄益. All rights reserved.
//

import UIKit

protocol HYPlayerCacheListViewDelegate: NSObjectProtocol {
    
    /** 确认删除缓存*/
    func alertToDeleteVideoCache(url: URL)
    /** 删除缓存*/
    func deleteVideoCache(urls: [URL])
    /** 开始缓存*/
    func startVideoCache()
}


class HYPlayerCacheListView: UIView {
    
    weak var delegate: HYPlayerCacheListViewDelegate?
    
    
    /// 下载
    private var downLoadBtn: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle("下载", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return btn
    }()
    
    /// 缓存
    private var cacheLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.textColor = .white
        return lab
    }()
    
    var tableView: UITableView = { () -> UITableView in
        let tableView = UITableView(frame: .zero, style: .plain)
        
        tableView.register(HYPlayerCacheListCell.self, forCellReuseIdentifier: "HYPlayerCacheListCell")
        tableView.allowsMultipleSelection = true
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        tableView.bounces = true
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private var cacheList: [HYPlayerCommonConfig] = []
    
    private var expandingSectionSet: Set<Int> = [0]
    
    private var selectedIndexPaths: [IndexPath] = []
    
    private var videoCacher: HYMediaCacher<HYDefaultVideoCacheLocation>?
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        createUI()
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        //        downloadTimer?.invalidate()
    }
    
    private func createUI() {
        backgroundColor = .clear
        
        let cornerView = UIView()
        cornerView.backgroundColor = .white
        cornerView.layer.cornerRadius = 16
        addSubview(cornerView)
        cornerView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(32)
        }
        
        let backView = UIView()
        backView.backgroundColor = .white
        addSubview(backView)
        backView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(16)
        }
        
        let bottomView = UIView()
        bottomView.backgroundColor = .red
        addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(HY_IS_IPHONEX ? 77 : 48)
        }
        
        bottomView.addSubview(cacheLab)
        cacheLab.snp.makeConstraints { (make) in
            make.leading.equalTo(18)
            make.top.equalTo(10)
            make.height.equalTo(20)
        }
        
        downLoadBtn.addTarget(self, action: #selector(downloadBtnPressed), for: .touchUpInside)
        bottomView.addSubview(downLoadBtn)
        downLoadBtn.snp.makeConstraints { (make) in
            make.top.equalTo(7)
            make.trailing.equalTo(-18)
            make.height.equalTo(24)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top)
        }
    }
    
    
    
    /** 下载按钮被点击*/
    @objc private func downloadBtnPressed() {
        
        guard let indexPaths = tableView.indexPathsForSelectedRows else {
            print("请选择要下载的视频")
            return
        }
        
        selectedIndexPaths = indexPaths
        
        let sizes: [Float] = [1, 1]
        
        var total: Float = 0
        for size in sizes {
            total += size
        }
        
        if
            let free = HYStorage.available,
            total * pow(1024, 2) >= free {
            print("存储空间不足，无法下载视频")
            return
        }
        //计算完毕
        let mp4URLs = indexPaths.compactMap { [weak self] (indexPath) -> URL? in
            
            if self?.cacheList.count ?? 0 > indexPath.row {
                if let cacheConfig = self?.cacheList[indexPath.row] {
                    if let urlString = cacheConfig.videoUrl {
                        
                        // 设置缓存标志
                        if let cell = tableView.cellForRow(at: indexPath) as? HYPlayerCacheListCell, let url = URL(string: urlString) {
                            let location = HYDefaultVideoCacheLocation(remoteURL: url, mediaType: .video)
                            cell.cacheIdentifier = location.identifier
                            cell.cacheProgressView?.isHidden = false
                        }
                        
                        return URL(string: urlString)
                    }
                }
            }
            
            return nil
        }
        
        if HYVideoCacheManager.shared.cacheVideos(with: mp4URLs) {
            // 开始缓存
            delegate?.startVideoCache()
        } else {
            print("无法下载视频")
        }
    }
    
    /** 删除按钮被点击*/
    @objc private func deleteButtonDidClicked(_ sender: HYPlayerCacheListCellButton) {
        if let url = sender.mp4URL {
            delegate?.alertToDeleteVideoCache(url: url)
        }
    }
    
    /** 列表中视频选中状态发生改变*/
    private func cacheListSelectChange() {
        var str1: String?
//        var str2: String?
        
        if let number = tableView.indexPathsForSelectedRows?.count {
            str1 = "\(number)个文件"
        }
        
//        if let indexPaths = tableView.indexPathsForSelectedRows {
//
//            let sizes = indexPaths.compactMap({ (indexPath) -> Float? in
//                return 1
//            })
//
//            var sum: Float = 0
//            for num in sizes {
//                sum += num
//            }
//
//            str2 = String(format: "(%.1fMB)", sum)
//        }
        
        if str1 != nil {
//            if str2 != nil {
//                cacheLab.text = str1! + str2!
//            } else {
            cacheLab.text = str1!
//            }
        } else {
            cacheLab.text = "请选择需要缓存的文件"
        }
    }
    
}

//MARK: Public Function
extension HYPlayerCacheListView {
    
    /// 配置缓存列表
    /// - Parameters:
    ///   - cacheList: 视频配置集合
    ///   - videoCacher: 缓存对象
    func configView(cacheList: [HYPlayerCommonConfig], videoCacher: HYMediaCacher<HYDefaultVideoCacheLocation>) {
        
        self.cacheList = cacheList.filter { (config) -> Bool in
            var cacheUrl: String? = nil
            if let videoUrl = config.videoUrl, videoUrl != "" {
                cacheUrl = videoUrl
            } else if let audioUrl = config.audioUrl, audioUrl != "" {
                cacheUrl = audioUrl
            }
            if let playUrl = cacheUrl, playUrl.starts(with: "http"), (playUrl.contains(".mp4") || playUrl.contains(".caf")) {
                return true
            }
            
            return false
        }
        
        self.videoCacher = videoCacher
        downLoadBtn.setTitle("下载", for: .normal)
        tableView.reloadData()
        
        cacheLab.text = ""
    }
    
    
    /// 刷新缓存列表
    /// - Parameter videoCacher: 缓存对象
    func reloadCache(videoCacher: HYMediaCacher<HYDefaultVideoCacheLocation>) {
        self.videoCacher = videoCacher
        cacheLab.text = ""
        tableView.reloadData()
    }
    
    
    /// 刷新视频下载进度
    /// - Parameters:
    ///   - cacheIdentifier: 缓存标志
    ///   - progress: 缓存进度
    func updateCacheProgress(cacheIdentifier: String, progress: CGFloat) {
        for indexPath in selectedIndexPaths {
            if let cell = tableView.cellForRow(at: indexPath) as? HYPlayerCacheListCell {
                if cell.cacheIdentifier == cacheIdentifier {
                    cell.cacheProgressView?.isHidden = false
                    cell.cacheProgressView?.updateProgress(progress: progress)
                }
            }
        }
    }
    
    
    /// 完成视频下载
    /// - Parameter cacheIdentifier: 缓存标志
    func finishVideoCache(cacheIdentifier: String) {
        for indexPath in selectedIndexPaths {
            if let cell = tableView.cellForRow(at: indexPath) as? HYPlayerCacheListCell {
                if cell.cacheIdentifier == cacheIdentifier {
                    cell.cacheProgressView?.isHidden = true
                }
            }
        }
    }
    
    /** 完成所有视频下载*/
    func finishAllVideoCache() {
        for indexPath in selectedIndexPaths {
            if let cell = tableView.cellForRow(at: indexPath) as? HYPlayerCacheListCell {
                cell.cacheProgressView?.isHidden = true
            }
        }
    }
}

//MARK:UITableViewDelegate
extension HYPlayerCacheListView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cacheList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if cacheList.count > indexPath.row {
            
            let cacheConfig = cacheList[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "HYPlayerCacheListCell", for: indexPath) as! HYPlayerCacheListCell
            
            cell.backgroundColor = .clear
            
            cell.titleLabel.text = cacheConfig.title
            
            var cacheUrl: String? = nil
            var isVideo = true
            if let videoUrl = cacheConfig.videoUrl, videoUrl != "" {
                cacheUrl = videoUrl
            } else if let audioUrl = cacheConfig.audioUrl, audioUrl != "" {
                cacheUrl = audioUrl
                isVideo = false
            }
            
            if let mp4URL = cacheUrl,
                let url = URL(string: mp4URL)
            {
                cell.deleteButton.mp4URL = url
                cell.playUrl = mp4URL
                //TODO:
                let location = HYDefaultVideoCacheLocation(remoteURL: url, mediaType: isVideo ? .video : .audio)
                cell.hasCached = videoCacher?.cacheList.contains(location.identifier) == true// || (videoCacher?.currentCache?.remoteURL == url && shouldContinueCurrentVideo)
                cell.deleteButton.addTarget(self, action: #selector(deleteButtonDidClicked(_:)), for: .touchUpInside)
            }
            
            return cell
        }
        
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        cacheListSelectChange()
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        let cell = tableView.cellForRow(at: indexPath) as? HYPlayerCacheListCell
        guard cell?.hasCached != true else {
            return nil
        }
        
        if let cell = tableView.cellForRow(at: indexPath) as? HYPlayerCacheListCell {
            if let playUrl = cell.playUrl, playUrl.starts(with: "http")
            {
                if playUrl.contains(".mp4") || playUrl.contains(".caf") {
                    return indexPath
                } else {
                    print("暂不支持该缓存格式")
                    return nil
                }
            }
        }
        
        return nil
    }
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        cacheListSelectChange()
    }
}
