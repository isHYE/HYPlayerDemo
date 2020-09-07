//
//  HYCacheProgressView.swift
//  HYPlayerDemo
//
//  Created by 黄益 on 2020/9/4.
//  Copyright © 2020 黄益. All rights reserved.
//  缓存列表缓存进度

import UIKit

class HYCacheProgressView: UIView {
    
    var frontCircle: CAShapeLayer?
    
    var mdowntime: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        let backCircle = CAShapeLayer() //进度条底
        // 画底
        let backPath = UIBezierPath(arcCenter: CGPoint(x: frame.height/2, y: frame.width/2), radius: bounds.width/2, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
        backCircle.lineWidth = 1  // 线条宽度
        backCircle.strokeColor = UIColor.lightGray.cgColor // 边缘线的颜色
        backCircle.fillColor = UIColor.clear.cgColor  // 闭环填充的颜色
        backCircle.lineCap = CAShapeLayerLineCap.butt  // 边缘线的类型
        backCircle.path = backPath.cgPath; // 从贝塞尔曲线获取到形状
        
        layer.addSublayer(backCircle)
        
        
        frontCircle = CAShapeLayer()  // 进度条圆弧
        
        // 画刻度
        let frontPath = UIBezierPath(arcCenter: CGPoint(x: frame.height/2, y: frame.width/2), radius: bounds.width/2, startAngle: CGFloat(Double.pi*3/2), endAngle: CGFloat(Double.pi*2+Double.pi*3/2), clockwise: true)
        frontCircle?.lineWidth = 2
        frontCircle?.strokeColor = UIColor.red.cgColor
        frontCircle?.strokeStart = 0
        frontCircle?.strokeEnd = 0
        frontCircle?.fillColor = UIColor.clear.cgColor
        frontCircle?.lineCap = CAShapeLayerLineCap.butt
        frontCircle?.path = frontPath.cgPath;
        
        layer.addSublayer(frontCircle!)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 更新下载进度
    /// - Parameter progress: 进度百分比
    func updateProgress(progress: CGFloat) {
        frontCircle?.strokeEnd = progress
    }
}
