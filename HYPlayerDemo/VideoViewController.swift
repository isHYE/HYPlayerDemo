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
    

    var videoView: HYPlayerCommonView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .white
        
        createUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        videoView?.dealToDisappear()
    }

    private func createUI() {
        
        let returnBtn = UIButton()
        returnBtn.setTitle("返回", for: .normal)
        returnBtn.setTitleColor(.red, for: .normal)
        returnBtn.addTarget(self, action: #selector(returnBtnPressed), for: .touchUpInside)
        view.addSubview(returnBtn)
        returnBtn.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.top.equalTo(388)
            make.height.equalTo(30)
            make.width.equalTo(50)
        }
        
        let audioBtn = UIButton()
        audioBtn.setTitle("音频", for: .normal)
        audioBtn.setTitleColor(.red, for: .normal)
        audioBtn.addTarget(self, action: #selector(changeToAudioPressed), for: .touchUpInside)
        view.addSubview(audioBtn)
        audioBtn.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview()
            make.top.equalTo(388)
            make.height.equalTo(30)
            make.width.equalTo(50)
        }
        
        let playView = UIView()
        playView.backgroundColor = .white
        view.addSubview(playView)
        playView.snp.makeConstraints { (make) in
            make.top.equalTo(100)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.size.width / 16 * 9)
        }
        
        
        videoView = HYPlayerCommonView(playView)
        videoView?.delegate = self
        videoView?.updateCurrentPlayer(playerConfig: HYPlayerCommonConfig(title: "视频测试", videoUrl: "http://1253131631.vod2.myqcloud.com/26f327f9vodgzp1253131631/f4c0c9e59031868222924048327/f0.mp4", needCache: true, placeHoldImg: URL(string: "http://chinaapper.com/pth/pth80coursepictures/teacher_2.png")))
        
    }
    

    /** 返回*/
    @objc private func returnBtnPressed() {
        dismiss(animated: true)
    }
    
    /** 切换为音频播放*/
    @objc private func changeToAudioPressed() {
        videoView?.updateCurrentPlayer(playerConfig: HYPlayerCommonConfig(title: "音频测试", audioUrl: "http://chinaapper.com/pthtest/pthtestmodel/teachermodel.mp3", placeHoldImg: "radio_bg_video"))
    }
}

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

