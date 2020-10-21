//
//  HYPlayerCacheListCell.swift
//  PTHLearning
//
//  Created by 黄益 on 2020/7/2.
//  Copyright © 2020 黄益. All rights reserved.
//

import UIKit

class HYPlayerCacheListCell: UITableViewCell {
    
    /// 缓存标志
    var cacheIdentifier: String?
    /// 是否可以缓存
    var hasCached: Bool = false
    /// 播放地址
    var playUrl: String?
    /// 缓存大小
    var size: Float?
    /// 缓存进度指示器
    var cacheProgressView: HYCacheProgressView?
    
    /// 标题
    var titleLabel: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.textColor = UIColor.lightGray
        return lab
    }()
    
    /// 删除按钮
    var deleteButton: HYPlayerCacheListCellButton = {
        let btn = HYPlayerCacheListCellButton()
        btn.setImage(UIImage(named: "cache_ic_delete"), for: .normal)
        return btn
    }()
    
    /// 勾选标志
    var completionImageView: UIImageView = {
        let imgView = UIImageView(image: UIImage(named: "cache_ic_checkoff"))
        return imgView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        clipsToBounds = true
        
        createUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if hasCached {
            completionImageView.isHidden = true
            deleteButton.isHidden = false
        } else {
            completionImageView.isHidden = false
            deleteButton.isHidden = true
            completionImageView.image = selected ? UIImage(named: "cache_ic_checkon") : UIImage(named: "cache_ic_checkoff")
        }
        // Configure the view for the selected state
    }
    
    
    private func createUI() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(14)
            make.centerY.equalToSuperview()
        }
        
        contentView.addSubview(completionImageView)
        completionImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(-14)
            make.height.width.equalTo(20)
        }
        
        contentView.addSubview(deleteButton)
        deleteButton.snp.makeConstraints { (make) in
            make.edges.equalTo(completionImageView)
        }
        
        cacheProgressView = HYCacheProgressView(frame: CGRect(x: HY_SCREEN_WIDTH - 36, y: 10, width: 24, height: 24))
        cacheProgressView?.isHidden = true
        contentView.addSubview(cacheProgressView!)
    }
}

class HYPlayerCacheListCellButton: UIButton {
    var mp4URL: URL?
}
