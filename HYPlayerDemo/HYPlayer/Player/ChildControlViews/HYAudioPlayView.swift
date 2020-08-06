//
//  HYAudioPlayView.swift
//  SuperPlayerDemo
//
//  Created by 黄益 on 2020/7/30.
//  Copyright © 2020 黄益. All rights reserved.
//

import UIKit

class HYAudioPlayView: UIView {
    
    /// 音阶
    var audioImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "hy_audio_ic_Play_0", in: HY_SOURCE_BUNDLE, compatibleWith: nil)
        return imgView
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
        
        addSubview(audioImgView)
        audioImgView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.width.equalTo(40)
        }
    }
    
    func startAudioAnimation() {
        var imgArray: [UIImage] = []
        for i in 0...4{
            imgArray.append(UIImage(named: "hy_audio_ic_Play_\(i)", in: HY_SOURCE_BUNDLE, compatibleWith: nil)!)
        }
        
        audioImgView.animationImages = imgArray
        audioImgView.contentMode = .scaleToFill
        audioImgView.animationDuration = 1.0
        audioImgView.startAnimating()
    }
    
    func stopAudioAnimation() {
        audioImgView.stopAnimating()
    }

}
