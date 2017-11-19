//
//  PJBaseErrorView.swift
//  Swift3Learn
//
//  Created by 飘金 on 2017/4/11.
//  Copyright © 2017年 飘金. All rights reserved.
//

import UIKit

protocol PJBaseErrorViewDelegate : NSObjectProtocol{
    /**
     为空时点击回调
     */
    func errorClick()
}

class PJBaseErrorView: PJBaseView {
    
    weak var delegate:PJBaseErrorViewDelegate?
    
    //点击空页面
    override func viewClick(){
        self.delegate?.errorClick()
    }
    
    /**
     *   设置出错时的提示文字
     */
    func setErrorText(text: String?) {
        self.setLabelText(text: text)
    }
}
