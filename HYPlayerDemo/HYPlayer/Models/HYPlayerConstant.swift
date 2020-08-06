//
//  HYPlayerConstant.swift
//  HYPlayerDemo
//
//  Created by 黄益 on 2020/8/6.
//  Copyright © 2020 黄益. All rights reserved.
//

import Foundation
import UIKit

/// 资源文件
let HY_SOURCE_BUNDLE = Bundle.init(path: Bundle.main.path(forResource: "HYPlayer", ofType: "bundle")! + "/Icons")

/// 屏幕宽度
let HY_SCREEN_WIDTH = UIScreen.main.bounds.size.width

/// 屏幕高度
let HY_SCREEN_HEIGHT = UIScreen.main.bounds.size.height

/// 是否为X系列手机
var HY_IS_IPHONEX: Bool {
    let screenHeight = UIScreen.main.nativeBounds.size.height;
    if screenHeight == 2436 || screenHeight == 1792 || screenHeight == 2688 || screenHeight == 1624 {
        return true
    }
    return false
}
