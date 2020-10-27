//
//  HYSpeedyRemindView.swift
//  SuperPlayerDemo
//
//  Created by 黄益 on 2020/7/31.
//  Copyright © 2020 黄益. All rights reserved.
//  快捷操作提醒

import UIKit

class HYSpeedyRemindView: UIView {
    
    /// 提示图标
    var remindImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.alpha = 0.8
        return imgView
    }()
    
    /// 提醒文字
    var remindLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .black
        lab.font = UIFont.systemFont(ofSize: 16)
        return lab
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        createUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createUI() {
        
        addSubview(remindImgView)
        remindImgView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        addSubview(remindLab)
        remindLab.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }

}
