//
//  HYAudiovisualCommonViewDelegate.swift
//  SuperPlayerDemo
//
//  Created by 黄益 on 2020/7/29.
//  Copyright © 2020 黄益. All rights reserved.
//

import Foundation

protocol HYAudiovisualCommonViewDelegate: NSObjectProtocol {
    
    /** 全屏状态改变*/
    func changeFullScreen(isFull: Bool)
    
    /** 流量提醒*/
    func flowRemind()
    
}
