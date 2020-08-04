//
//  HYSpeedyRemindView.swift
//  SuperPlayerDemo
//
//  Created by 黄益 on 2020/7/31.
//  Copyright © 2020 黄益. All rights reserved.
//  快捷操作提醒

import UIKit

class HYSpeedyRemindView: UIView {
    
    /// 提醒文字
    var remindLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = UIFont.systemFont(ofSize: 20)
        return lab
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
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        addSubview(remindLab)
        remindLab.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }

}
