//
//  HYWithoutNetView.swift
//  HYPlayerDemo
//
//  Created by 黄益 on 2020/9/1.
//  Copyright © 2020 黄益. All rights reserved.
//  无网界面

import UIKit

class HYWithoutNetView: UIView {
    
    /// 检查网络
    var checkNetBtn: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.layer.cornerRadius = 4
        btn.clipsToBounds = true
        btn.setTitle("检查网络", for: .normal)
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.titleLabel?.textAlignment = .center
        return btn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        backgroundColor = .black
        createUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createUI() {
        addSubview(checkNetBtn)
        checkNetBtn.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.equalTo(42)
            make.width.equalTo(136)
        }
    }

}
