//
//  ExpressTableViewCell.swift
//  PJQuicklyDev
//
//  Created by 飘金 on 2017/4/13.
//  Copyright © 2017年 飘金. All rights reserved.
//

import UIKit

class ExpressTableViewCell: PJBaseTableViewCell {
    var expressItemModel: ExpressItemModel?

    // 当前快递到达地址
    let currentArriveAddress: UILabel = {
        let view = UILabel()
        view.backgroundColor = UIColor.colorWithRGB(red: 219, green: 219, blue: 219)
        view.font = UIFont.systemFont(ofSize: 17.0)
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
//        view.preferredMaxLayoutWidth = PJScreenWidth - 30
        return view
    }()

    // 当前快递时间
    let timeLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = UIColor.orange
        view.font = UIFont.systemFont(ofSize: 15.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func initView() {
        contentView.addSubview(timeLabel)
        timeLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15.0).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12.0).isActive = true

        contentView.addSubview(currentArriveAddress)

        currentArriveAddress.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15.0).isActive = true
        currentArriveAddress.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12.0).isActive = true
        currentArriveAddress.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -15.0).isActive = true
        currentArriveAddress.bottomAnchor.constraint(equalTo: timeLabel.topAnchor, constant: -6.0).isActive = true
    }

    /**
     设置数据
     */
    override func setModel(model: Any?) {
        expressItemModel = model as? ExpressItemModel
        currentArriveAddress.text = expressItemModel?.context
        timeLabel.text = expressItemModel?.time
    }
}
