//
//  PJBaseView.swift
//  Swift3Learn
//
//  Created by 飘金 on 2017/4/11.
//  Copyright © 2017年 飘金. All rights reserved.
//

import UIKit

open class PJBaseView: UIView {

    open lazy var label:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewClick))
        self.addGestureRecognizer(tap)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
     方法
     */
    private func initView(){
        self.label.text = "设置提示文字"
        self.addSubview(self.label)
        self.label.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.label.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.label.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.label.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    open func setLabelText(text:String?) {
        self.label.text = text
    }
    
    /**
     子类重写点击事件
     */
    @objc open func viewClick(){
        
    }

}
