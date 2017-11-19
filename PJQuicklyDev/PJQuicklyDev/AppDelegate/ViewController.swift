//
//  ViewController.swift
//  PJQuicklyDev
//
//  Created by 飘金 on 2017/4/12.
//  Copyright © 2017年 飘金. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //"http://v5.owner.mjbang.cn/api/gallery/get_experience_house"
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let testViewController = PJTestViewController()
        self.present(testViewController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

