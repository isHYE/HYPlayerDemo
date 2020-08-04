//
//  HYResponseExpandButtton.swift
//  HYPlayerDemo
//
//  Created by 黄益 on 2020/8/4.
//  Copyright © 2020 黄益. All rights reserved.
//

import UIKit

class HYResponseExpandButtton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        super.point(inside: point, with: event)
        var bounds = self.bounds
        
            let x: CGFloat = -10
            let y: CGFloat = -10
            let width: CGFloat = bounds.width + 20
            let height: CGFloat = bounds.height + 20 
            bounds = CGRect(x: x, y: y, width: width, height: height) //负值是方法响应范围
        
        return bounds.contains(point)
    }

}
