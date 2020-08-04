//
//  HYEndPlayView.swift
//  SuperPlayerDemo
//
//  Created by 黄益 on 2020/7/30.
//  Copyright © 2020 黄益. All rights reserved.
//  视频播放完毕之后的展示

import UIKit

class HYEndPlayView: UIView {
    
    /// 重播
    var replayBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("重播", for: .normal)
        return btn
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
        backgroundColor = .black
        
        addSubview(replayBtn)
        replayBtn.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }

}
