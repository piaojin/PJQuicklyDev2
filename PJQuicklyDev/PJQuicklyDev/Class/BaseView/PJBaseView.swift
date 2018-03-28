//
//  PJBaseView.swift
//  Swift3Learn
//
//  Created by 飘金 on 2017/4/11.
//  Copyright © 2017年 飘金. All rights reserved.
//

import UIKit

class PJBaseView: UIView {

    lazy var label:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewClick))
        self.addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
     方法
     */
    func initView(){
        self.label.text = "设置提示文字"
        self.addSubview(self.label)
        self.label.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.label.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.label.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.label.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    func setLabelText(text:String?) {
        self.label.text = text
    }
    
    /**
     子类重写点击事件
     */
    @objc func viewClick(){
        
    }

}
