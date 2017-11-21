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
        view.translatesAutoresizingMaskIntoConstraints = false
//        view.preferredMaxLayoutWidth = PJScreenWidth - 30
    return view
    }()
    
    //当前快递时间
    let timeLabel : UILabel = {
        let view = UILabel()
        view.backgroundColor = UIColor.orange
        view.font = UIFont.systemFont(ofSize: 15.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func initView() {

        self.contentView.addSubview(self.timeLabel)
        timeLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 15.0).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -12.0).isActive = true
        
        self.contentView.addSubview(self.currentArriveAddress)
        
        self.currentArriveAddress.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 15.0).isActive = true
        self.currentArriveAddress.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 12.0).isActive = true
        self.currentArriveAddress.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -15.0).isActive = true
        self.currentArriveAddress.bottomAnchor.constraint(equalTo: self.timeLabel.topAnchor, constant: -6.0).isActive = true
    }
    
    /**
     设置数据
     */
    override func setModel(model: AnyObject?) {
        self.expressItemModel = model as? ExpressItemModel
        self.currentArriveAddress.text = self.expressItemModel?.context
        self.timeLabel.text = self.expressItemModel?.time
    }
}
