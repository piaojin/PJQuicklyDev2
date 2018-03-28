//
//  PJBaseEmptyView.swift
//  Swift3Learn
//
//  Created by 飘金 on 2017/4/11.
//  Copyright © 2017年 飘金. All rights reserved.
//

import UIKit

protocol PJBaseEmptyViewDelegate : NSObjectProtocol {
    /**
     为空时点击回调
     */
    func emptyClick()
}

class PJBaseEmptyView: PJBaseView {
    
    weak var delegate:PJBaseEmptyViewDelegate?
    
    //点击空页面
    override func viewClick(){
        self.delegate?.emptyClick()
    }
    
    /**
     *   设置出错时的提示文字
     */
    func setEmptyText(text: String?) {
        self.setLabelText(text: text)
    }
}
