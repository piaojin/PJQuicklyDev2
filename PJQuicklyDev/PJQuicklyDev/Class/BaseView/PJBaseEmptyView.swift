//
//  PJBaseEmptyView.swift
//  Swift3Learn
//
//  Created by 飘金 on 2017/4/11.
//  Copyright © 2017年 飘金. All rights reserved.
//

import UIKit

public protocol PJBaseEmptyViewDelegate: NSObjectProtocol {
    /**
     为空时点击回调
     */
    func emptyClick()
}

open class PJBaseEmptyView: PJBaseView {
    open weak var delegate: PJBaseEmptyViewDelegate?

    // 点击空页面
    override open func viewClick() {
        delegate?.emptyClick()
    }

    /**
     *   设置出错时的提示文字
     */
    open func setEmptyText(text: String?) {
        setLabelText(text: text)
    }
}
