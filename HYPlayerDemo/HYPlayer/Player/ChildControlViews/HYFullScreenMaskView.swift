//
//  HYFullScreenMaskView.swift
//  SuperPlayerDemo
//
//  Created by 黄益 on 2020/7/30.
//  Copyright © 2020 黄益. All rights reserved.
//  播放器全屏状态下的导航栏

import UIKit

protocol HYFullScreenMaskViewDelegate: NSObjectProtocol {
    
    /** 更改播放器播放速度*/
    func changePlayerRate(rate: Float)
    
}

class HYFullScreenMaskView: UIView {
    
    weak var delegate: HYFullScreenMaskViewDelegate?
    
    var moreFunctionWidth: CGFloat = 300
    /// 当前播放速度
    var currentSpeed: Float = 1
    /// 倍速列表
    private let speedArray: [Float] = [0.75, 1.0, 1.5, 2.0]
    
    /// 退出全屏
    var backBtn: HYResponseExpandButtton = {
        let btn = HYResponseExpandButtton.init(type: .custom)
        btn.setImage(UIImage(named: "hy_video_ic_back", in: HY_SOURCE_BUNDLE, compatibleWith: nil), for: .normal)
        return btn
    }()
    
    /// 导航栏
    var naviView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()
    
    /// 标题
    var titleLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 17)
        lab.textColor = UIColor.white
        lab.textAlignment = .center
        lab.font = UIFont.boldSystemFont(ofSize: 17)
        return lab
    }()
    
    /// 更多功能
    var moreBtn: HYResponseExpandButtton = {
        let btn = HYResponseExpandButtton()
        btn.setImage(UIImage(named: "hy_fullscreen_ic_more", in: HY_SOURCE_BUNDLE, compatibleWith: nil), for: .normal)
        return btn
    }()
    
    /// 屏幕锁定按钮
    var lockBtn: HYResponseExpandButtton = {
        let btn = HYResponseExpandButtton()
        btn.setImage(UIImage(named: "hy_fullscreen_unlock", in: HY_SOURCE_BUNDLE, compatibleWith: nil), for: .normal)
        btn.setImage(UIImage(named: "hy_fullscreen_lock", in: HY_SOURCE_BUNDLE, compatibleWith: nil), for: .selected)
        return btn
    }()
    
    /// 更多功能面板
    var moreFunctionView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()
    
    /// 倍速列表
    private var speedCollectionView: UICollectionView = { () -> UICollectionView in
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: 50, height: 30)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(HYMoreFunctionSpeedCollectionViewCell.self, forCellWithReuseIdentifier: "HYMoreFunctionSpeedCollectionViewCell")
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        isUserInteractionEnabled = true
        
        // 读区本地存储播放速率
        if let rate = UserDefaults.standard.value(forKey: "HYPlayer_rate") as? Float {
            currentSpeed = rate
        }
        
        createUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createUI() {
        backgroundColor = .clear
        
        createMoreFunctionView()
        
        addSubview(naviView)
        naviView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(64)
        }
        
        naviView.addSubview(backBtn)
        backBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-10)
            make.left.equalToSuperview().offset(15)
            make.height.width.equalTo(48)
        }
        
        naviView.addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.centerY.equalTo(backBtn.snp.centerY)
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
            make.leading.equalTo(70)
            make.trailing.equalTo(-70)
        }
        
        naviView.addSubview(moreBtn)
        moreBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(backBtn.snp.centerY)
            make.trailing.equalTo(-15)
            make.height.width.equalTo(30)
        }
        
        addSubview(lockBtn)
        lockBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalTo(40)
            make.height.width.equalTo(30)
        }
    }
    
    /** 创建更多功能面板*/
    private func createMoreFunctionView() {
        moreFunctionView.frame = CGRect(x: HY_SCREEN_HEIGHT, y: 64, width: 100, height: HY_SCREEN_WIDTH - (HY_IS_IPHONEX ? 119 : 104))
        addSubview(moreFunctionView)
        
        let speedLab = UILabel()
        speedLab.text = "倍速："
        speedLab.textColor = UIColor.white
        speedLab.font = UIFont.boldSystemFont(ofSize: 15)
        moreFunctionView.addSubview(speedLab)
        speedLab.snp.makeConstraints { (make) in
            make.top.leading.equalTo(14)
            make.height.equalTo(30)
        }
        
        speedCollectionView.delegate = self
        speedCollectionView.dataSource = self
        moreFunctionView.addSubview(speedCollectionView)
        speedCollectionView.snp.makeConstraints { (make) in
            make.leading.equalTo(speedLab.snp.trailing)
            make.centerY.equalTo(speedLab)
            make.height.equalTo(30)
            make.trailing.equalToSuperview()
        }
    }
    
    /** 展示更多功能面板*/
    func showMoreFunctionView() {
        UIView.animate(withDuration: 0.2) {
            self.moreFunctionView.frame = CGRect(x: HY_SCREEN_HEIGHT - self.moreFunctionWidth, y: 64, width: self.moreFunctionWidth, height: HY_SCREEN_WIDTH - (HY_IS_IPHONEX ? 119 : 104))
        }
    }
    
    /** 隐藏更多功能面板*/
    func hidMoreFunctionView() {
        UIView.animate(withDuration: 0.2) {
            self.moreFunctionView.frame = CGRect(x: HY_SCREEN_HEIGHT, y: 64, width: self.moreFunctionWidth, height: HY_SCREEN_WIDTH - (HY_IS_IPHONEX ? 119 : 104))
        }
    }
    
    
    /** 更换播放器速度*/
    @objc private func changePlayerSpeed(_ btn: UIButton) {
        if speedArray.count > btn.tag {
            if currentSpeed != speedArray[btn.tag] {
                
                // 存储改变速率到本地
                UserDefaults.standard.setValue(speedArray[btn.tag], forKey: "HYPlayer_rate")
                // 给播放器返回当前速率
                delegate?.changePlayerRate(rate: speedArray[btn.tag])
                // 刷新视图
                currentSpeed = speedArray[btn.tag]
                speedCollectionView.reloadData()
                
            }
        }
    }
}

//MARK: UICollectionViewDelegate
extension HYFullScreenMaskView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return speedArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HYMoreFunctionSpeedCollectionViewCell", for: indexPath) as! HYMoreFunctionSpeedCollectionViewCell
        if speedArray.count > indexPath.row {
            cell.speedBtn.tag = indexPath.row
            cell.speedBtn.addTarget(self, action: #selector(changePlayerSpeed(_:)), for: .touchUpInside)
            cell.speedBtn.setTitle("\(speedArray[indexPath.row])x", for: .normal)
            cell.speedBtn.setTitleColor(currentSpeed == speedArray[indexPath.row] ? .red : .white, for: .normal)
        }
        return cell
    }
}
