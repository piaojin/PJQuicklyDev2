//
//  ExpressTableViewCell.swift
//  PJQuicklyDev
//
//  Created by 飘金 on 2017/4/13.
//  Copyright © 2017年 飘金. All rights reserved.
//

import UIKit

class ExpressTableViewCell: PJBaseTableViewCell {

    var expressItemModel : ExpressItemModel?
    
    //当前快递到达地址
    let currentArriveAddress : UILabel = {
    let view = UILabel()
    view.backgroundColor = UIColor.colorWithRGB(red: 219, green: 219, blue: 219)
        view.font = UIFont.systemFont(ofSize: 17.0)
        view.numberOfLines = 0
//        view.preferredMaxLayoutWidth = PJScreenWidth - 30
    return view
    }()
    
    override func initView() {

        self.currentArriveAddress.translatesAutoresizingMaskIntoConstraints = false
        self.currentArriveAddress.numberOfLines = 0
        self.contentView.addSubview(self.currentArriveAddress)
        
        self.currentArriveAddress.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 15.0).isActive = true
        self.currentArriveAddress.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 12.0).isActive = true
        self.currentArriveAddress.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -15.0).isActive = true
        self.currentArriveAddress.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -12.0).isActive = true
    }
    
    /**
     设置数据
     */
    override func setModel(model: AnyObject?) {
        self.expressItemModel = model as? ExpressItemModel
        self.currentArriveAddress.text = self.expressItemModel?.context
    }
}
