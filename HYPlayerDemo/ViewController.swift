//
//  ViewController.swift
//  HYPlayerDemo
//
//  Created by 黄益 on 2020/8/3.
//  Copyright © 2020 黄益. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        createUI()
        
    }
    
    
    private func createUI() {
        let btn = UIButton(frame: CGRect(x: 100, y: 200, width: 100, height: 50))
        btn.setTitle("Player", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
        view.addSubview(btn)
    }
    
    @objc func playVideo() {
        let vc = VideoViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        //        navigationController?.pushViewController(vc, animated: true)
    }
    
}

