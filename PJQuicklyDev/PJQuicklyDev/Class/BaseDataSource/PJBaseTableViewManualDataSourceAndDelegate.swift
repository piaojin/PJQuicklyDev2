//
//  PJBaseTableViewManualDataSourceAndDelegate.swift
//  YouXiangBianLi
//
//  Created by piaojin on 2018/3/27.
//  Copyright © 2018年 ywyw.piaojin. All rights reserved.
//

import UIKit

// 适用手动计算cell高度
open class PJBaseTableViewManualDataSourceAndDelegate: PJBaseTableViewDataSourceAndDelegate {
    /**
     获取cell的高度
     */
    open func getHeightForRow(tableView: UITableView, at indexPath: IndexPath) -> CGFloat {
        let object = self.tableView(tableView: tableView, objectAt: indexPath)
        let cls: AnyClass = self.tableView(tableView: tableView, cellClassForObject: object)
        if let tempCls = cls as? PJBaseTableViewCellProtocol.Type {
            if let height = tempCls.tableView?(tableView: tableView, rowHeightForObject: object, indexPath: indexPath) {
                return height
            }
            return 44.0
        } else {
            return 44.0
        }
    }

    /**
     计算cell高度的方式,自动计算(利用FDTemplateLayoutCell库)和手动frame计算,默认自动计算,如果是手动计算则cell子类需要重写class func tableView(tableView: UITableView, rowHeightForObject model: AnyObject?,indexPath:IndexPath) -> CGFloat
     */
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // 自动计算cell高度(带有缓存)
        if isAutoCalculate {
            let object = self.tableView(tableView: tableView, objectAt: indexPath)
            let cls: AnyClass = self.tableView(tableView: tableView, cellClassForObject: object)
            return tableView.fd_heightForCell(withIdentifier: String(describing: cls), cacheBy: indexPath) { [weak self] (cell: Any?) in
                guard let tempCell = cell as? PJBaseTableViewCellProtocol else {
                    return
                }
                // 自动计算cell高度
                tempCell.setModel(model: self?.tableView(tableView: tableView, objectAt: indexPath))
            }
        } else {
            return getHeightForRow(tableView: tableView, at: indexPath)
        }
    }
}
