//
//  PlayerListTableViewCell.swift
//  HYPlayerDemo
//
//  Created by 黄益 on 2020/8/16.
//  Copyright © 2020 黄益. All rights reserved.
//

import UIKit

class PlayerListTableViewCell: UITableViewCell {
    
    /// 标题
    var titleLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .gray
        lab.font = UIFont.systemFont(ofSize: 16)
        return lab
    }()
    
//    /// 缓存按钮
//    var cacheBtn: UIButton = {
//        let btn = UIButton()
//        btn.setTitle("下载", for: .normal)
//        btn.setTitleColor(.black, for: .normal)
//        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
//        return btn
//    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        clipsToBounds = true
        
        createUI()
    }
    
    private func createUI() {
        let lineView = UIView()
        lineView.backgroundColor = UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1)
        contentView.addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
        contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalTo(16)
        }
        
//        addSubview(cacheBtn)
//        cacheBtn.snp.makeConstraints { (make) in
//            make.centerY.equalToSuperview()
//            make.trailing.equalTo(-16)
//        }
    }

}
