//
//  HYControlPanelView.swift
//  SuperPlayerDemo
//
//  Created by 黄益 on 2020/7/30.
//  Copyright © 2020 黄益. All rights reserved.
//  播放器控制面板

import UIKit

class HYControlPanelView: UIView {
    
    /// 播放｜暂停
    var playButton: HYResponseExpandButtton = {
        let btn = HYResponseExpandButtton()
        btn.setImage(UIImage(named: "hy_video_ic_play", in: HY_SOURCE_BUNDLE, compatibleWith: nil), for: .normal)
        return btn
    }()
    
    /// 全屏
    var screenButton: HYResponseExpandButtton = {
        let btn = HYResponseExpandButtton()
        btn.setImage(UIImage(named: "hy_video_ic_normalscreen", in: HY_SOURCE_BUNDLE, compatibleWith: nil), for: .normal)
        return btn
    }()
    
    /// 播放器时间指示
    var timeLabel: UILabel = {
        let lab = UILabel()
        lab.text = "00:00/00:00"
        lab.font = UIFont.systemFont(ofSize: 11)
        lab.textColor = UIColor.white
        return lab
    }()
    
    /// 播放器进度条
    var slider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.minimumTrackTintColor = UIColor.white
        slider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.4)
        slider.setThumbImage(UIImage(named: "hy_video_ic_slider", in: HY_SOURCE_BUNDLE, compatibleWith: nil), for: .normal)
        return slider
    }()
    
    /// 缓存进度
    var cacheView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        createUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createUI() {
        backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
        
        addSubview(playButton)
        playButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 40, height: 40))
        }
        
        addSubview(screenButton)
        screenButton.snp.makeConstraints { (make) in
            make.trailing.equalTo(-10)
            make.bottom.equalTo(-5)
            make.height.width.equalTo(30)
        }
        
        addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.right.equalTo(screenButton.snp.left).offset(-8)
            make.width.equalTo(72)
            make.centerY.equalToSuperview()
        }
        
        addSubview(slider)
        slider.snp.makeConstraints { (make) in
            make.right.equalTo(timeLabel.snp.left).offset(-8)
            make.left.equalTo(playButton.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }
        
        cacheView.frame = CGRect(x: 48, y: 20, width: 0, height: 1)
        addSubview(cacheView)
    }

}
