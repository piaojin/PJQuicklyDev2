//
//  PJTestViewController.swift
//  PJQuicklyDev
//
//  Created by Zoey Weng on 2017/11/18.
//  Copyright © 2017年 飘金. All rights reserved.
//

import UIKit

class PJTestViewController: PJBaseModelViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.orange
        self.test()
    }

    func test() {
        self.doRequest()
    }
    
    override func requestDidFinishLoad(success: Any?, failure: Any?) {
        
    }
    
    override func requestDidFailLoadWithError(failure: Any?) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func getRequestUrl() -> String{
        return "api/gallery/get_experience_house"
    }
}
