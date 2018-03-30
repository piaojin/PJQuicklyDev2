//
//  PJBaseErrorView.swift
//  Swift3Learn
//
//  Created by 飘金 on 2017/4/11.
//  Copyright © 2017年 飘金. All rights reserved.
//

import UIKit

public protocol PJBaseErrorViewDelegate : NSObjectProtocol {
    /**
     为空时点击回调
     */
    func errorClick()
}

open class PJBaseErrorView: PJBaseView {
    
    weak open var delegate:PJBaseErrorViewDelegate?
    
    //点击空页面
    override open func viewClick(){
        self.delegate?.errorClick()
    }
    
    /**
     *   设置出错时的提示文字
     */
    open func setErrorText(text: String?) {
        self.setLabelText(text: text)
    }
}
