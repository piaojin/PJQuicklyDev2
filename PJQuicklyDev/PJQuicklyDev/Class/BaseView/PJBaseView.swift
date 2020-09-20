//
//  PJBaseView.swift
//  Swift3Learn
//
//  Created by 飘金 on 2017/4/11.
//  Copyright © 2017年 飘金. All rights reserved.
//

import UIKit

open class PJBaseView: UIView {
    open lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        initView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewClick))
        addGestureRecognizer(tap)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /**
     方法
     */
    private func initView() {
        label.text = "设置提示文字"
        addSubview(label)
        label.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    open func setLabelText(text: String?) {
        label.text = text
    }

    /**
     子类重写点击事件
     */
    @objc open func viewClick() {}
}
