//
//  PJBaseView.swift
//  Swift3Learn
//
//  Created by 飘金 on 2017/4/11.
//  Copyright © 2017年 飘金. All rights reserved.
//

import UIKit

class PJBaseView: UIView {

    lazy var label:UILabel! = {
        return UILabel()
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewClick))
        self.addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     方法
     */
    func initView(){
        self.label.text = "设置提示文字"
        self.label.sizeToFit()
        self.label.frame = CGRect(x: (self.pj_width - self.label.pj_width) / 2.0, y: (self.pj_height - self.label.pj_height) / 2.0, width: self.label.pj_width, height: self.label.pj_height)
        self.addSubview(self.label)
    }
    
    func setLabelText(text:String?) {
        self.label.text = text
        self.label.sizeToFit()
        self.label.frame = CGRect(x: (self.pj_width - self.label.pj_width) / 2.0, y: (self.pj_height - self.label.pj_height) / 2.0, width: self.label.pj_width, height: self.label.pj_height)
        self.addSubview(self.label)
    }
    
    /**
     子类重写点击事件
     */
    @objc func viewClick(){
        
    }

}
