//
//  VideoViewController.swift
//  SuperPlayerDemo
//
//  Created by 黄益 on 2020/1/17.
//  Copyright © 2020 黄益. All rights reserved.
//

import UIKit
import SnapKit

class VideoViewController: UIViewController {
    
    /// 音视频播放列表
    private var playerConfigArray: [HYPlayerCommonConfig]
        = [HYPlayerCommonConfig(title: "网络视频测试",
                                videoUrl: "http://1253131631.vod2.myqcloud.com/26f327f9vodgzp1253131631/f4c0c9e59031868222924048327/f0.mp4",
                                needCache: true,
                                placeHoldImg: URL(string: "http://chinaapper.com/pth/pth80coursepictures/teacher_2.png")),
           HYPlayerCommonConfig(title: "本地视频测试",
                                videoUrl: Bundle.main.path(forResource: "testMovie", ofType: "mp4"),
                                placeHoldImg: URL(string: "http://chinaapper.com/pth/pth80coursepictures/teacher_2.png")),
           HYPlayerCommonConfig(title: "音频测试",
                                audioUrl: "http://music.163.com/song/media/outer/url?id=447925558.mp3",
                                placeHoldImg: "radio_bg_video"),
           HYPlayerCommonConfig(title: "本地音频测试",
                                audioUrl: Bundle.main.path(forResource: "testSong", ofType: "mp3"),
                                placeHoldImg: "radio_bg_video")]
    
    /// HYPlayer播放器
    private var videoView: HYPlayerCommonView?
    
    /// 播放列表
    private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(PlayerListTableViewCell.self, forCellReuseIdentifier: "PlayerListTableViewCell")
        
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .white
        tableView.bounces = true
        tableView.separatorStyle = .none
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        createUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        videoView?.dealToDisappear()
    }
    
    private func createUI() {
        
        let naviView = UIView()
        naviView.backgroundColor = .white
        view.addSubview(naviView)
        naviView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(HY_IS_IPHONEX ? 88 : 64)
        }
        
        
        let returnBtn = UIButton()
        returnBtn.setTitle("返回", for: .normal)
        returnBtn.setTitleColor(.red, for: .normal)
        returnBtn.addTarget(self, action: #selector(returnBtnPressed), for: .touchUpInside)
        naviView.addSubview(returnBtn)
        returnBtn.snp.makeConstraints { (make) in
            make.leading.bottom.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(64)
        }
        
        //        let cacheBtn = UIButton()
        //        cacheBtn.setTitle("缓存", for: .normal)
        //        cacheBtn.setTitleColor(.red, for: .normal)
        //        cacheBtn.addTarget(self, action: #selector(showCacheList), for: .touchUpInside)
        //        naviView.addSubview(cacheBtn)
        //        cacheBtn.snp.makeConstraints { (make) in
        //            make.trailing.bottom.equalToSuperview()
        //            make.height.equalTo(30)
        //            make.width.equalTo(64)
        //        }
        
        let playView = UIView()
        playView.backgroundColor = .white
        view.addSubview(playView)
        playView.snp.makeConstraints { (make) in
            make.top.equalTo(naviView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.size.width / 16 * 9)
        }
        
        videoView = HYPlayerCommonView(playView)
        videoView?.delegate = self
        videoView?.updateCurrentPlayer(playerConfig:
            HYPlayerCommonConfig(title: "视频测试",
                                 videoUrl: "http://1253131631.vod2.myqcloud.com/26f327f9vodgzp1253131631/f4c0c9e59031868222924048327/f0.mp4",
                                 needCache: true,
                                 placeHoldImg: URL(string: "http://chinaapper.com/pth/pth80coursepictures/teacher_2.png")))
        
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(playView.snp.bottom)
        }
        
    }
    
    /** 展示缓存列表*/
    @objc private func showCacheList() {
        //        let vc = PlayerCacheListController()
        //        present(vc, animated: true)
    }
    
    /** 返回*/
    @objc private func returnBtnPressed() {
        dismiss(animated: true)
    }
    
    //    //  是否支持自动转屏
    //    override var shouldAutorotate: Bool {
    //        return true
    //    }
    //
    //    // 支持哪些转屏方向
    //    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    //        return .all
    //    }
    //
    //    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
    //        return .landscapeLeft
    //    }
    
}

//MARK: UITableViewDelegate, UITableViewDataSource
extension VideoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playerConfigArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerListTableViewCell", for: indexPath) as! PlayerListTableViewCell
        if playerConfigArray.count > indexPath.row {
            let playerConfig = playerConfigArray[indexPath.row]
            cell.titleLab.text = playerConfig.title
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if playerConfigArray.count > indexPath.row {
            let playerConfig = playerConfigArray[indexPath.row]
            videoView?.updateCurrentPlayer(playerConfig: playerConfig)
        }
    }
}

//MARK: HYPlayerCommonViewDelegate
extension VideoViewController: HYPlayerCommonViewDelegate {
    /** 全屏状态改变*/
    func changeFullScreen(isFull: Bool) {
        print(isFull ? "全屏" : "退出全屏")
    }
    
    /** 流量提醒*/
    func flowRemind() {
        print("正在使用流量")
    }
    
    /** 开始播放*/
    func startPlayer() {
        print("开始播放")
    }
    
    /** 播放暂停*/
    func pausePlayer() {
        print("暂停播放")
    }
    
    /** 结束播放*/
    func stopPlayer() {
        print("结束播放")
    }
    
    /** 缓存开始*/
    func startCache() {
        print("缓存开始")
    }
    
    /** 缓存进行中*/
    func inCaching(progress: Float) {
        print("缓存进度更新：\(progress)")
    }
    
    /** 缓存完成*/
    func completeCache() {
        print("缓存完成")
    }
    
    /** 缓存失败*/
    func faildCache() {
        print("缓存失败")
    }
}

