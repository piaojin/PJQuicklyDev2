//
//  ExpressTableViewCell.swift
//  PJQuicklyDev
//
//  Created by 飘金 on 2017/4/13.
//  Copyright © 2017年 飘金. All rights reserved.
//

import UIKit

class ExpressTableViewCell: PJBaseTableViewCell{

    var expressItemModel : ExpressItemModel?
    
    //当前快递到达地址
    let currentArriveAddress : UILabel = {
    let view = UILabel()
    view.backgroundColor = UIColor.colorWithRGB(red: 219, green: 219, blue: 219)
        view.font = UIFont.systemFont(ofSize: 17.0)
        view.numberOfLines = 0
        view.preferredMaxLayoutWidth = PJScreenWidth - 30
    return view
    }()
    
    //时间
    let timeLabel : UILabel = {
    let view = UILabel()
    view.textColor = UIColor.colorWithRGB(red: 219, green: 219, blue: 219)
        view.font = UIFont.systemFont(ofSize: 15.0)
    return view
    }()

    //底部水平分割线
    let driverH : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.colorWithRGB(red: 219, green: 219, blue: 219)
        return view
    }()
    
    override func initView() {
        self.contentView.addSubview(self.currentArriveAddress)
        self.currentArriveAddress.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView).offset(15)
            make.top.equalTo(self.contentView).offset(12.0)
            make.right.equalTo(self.contentView).offset(-15)
        }
        
        self.contentView.addSubview(self.timeLabel)
        self.timeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.currentArriveAddress.snp.bottom).offset(7)
            make.left.equalTo(self.currentArriveAddress)
            make.bottom.equalTo(-12.0)
        }
        
        self.contentView.addSubview(self.driverH)
        self.driverH.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.contentView).offset(0)
            make.height.equalTo(1)
            make.left.right.equalTo(0)
        }
    }
    
    /**
     设置数据
     */
    override func setModel(model: AnyObject?) {
        self.expressItemModel = model as? ExpressItemModel
        self.currentArriveAddress.text = self.expressItemModel?.context
        self.timeLabel.text = self.expressItemModel?.ftime
    }
}
