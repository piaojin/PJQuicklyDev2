//
//  PJBaseTableViewCell.swift
//  Swift3Learn
//
//  Created by 飘金 on 2017/4/11.
//  Copyright © 2017年 飘金. All rights reserved.
//

import UIKit
import CocoaLumberjack

@objc public protocol PJBaseTableViewCellProtocol: NSObjectProtocol {
    /**
     设置model到cell(在这里更新UI)
     */
    func setModel(model: Any?)
    /// 是否从xib加载初始化cell
    @objc optional static var isLoadFromXIB: Bool {set get}
    
    /**
     cell的高度,如果是以自动计算高度的方式获取cell高度,则子类无需重写改方法,否则需要子类重写改方法以手动计算cell的高度
     */
    @objc optional static func tableView(tableView: UITableView, rowHeightForObject model: Any?,indexPath:IndexPath) -> CGFloat
    
    /**
     消除重用造成的数据重复显示
     */
    @objc optional func clearData()
    
    /**
     cellIdentifier
     */
    @objc optional static func cellIdentifier() -> String
    
    /**
     从xib初始化cell
     */
    @objc optional static func cellWithTableView(tableview: UITableView) -> UITableViewCell
}

open class PJBaseTableViewCell: UITableViewCell, PJBaseTableViewCellProtocol {
    
    /// 是否从xib加载初始化cell
    public static var isLoadFromXIB: Bool = false
    var model: AnyObject?
    //cell所在的控制器
    weak var controller:PJBaseViewController?
    
    /**
     cell的高度,如果是以自动计算高度的方式获取cell高度,则子类无需重写改方法,否则需要子类重写改方法以手动计算cell的高度
     */
    public static func tableView(tableView: UITableView, rowHeightForObject model: Any?,indexPath:IndexPath) -> CGFloat {
        return 44.0
    }
    
    /**
     设置model到cell(在这里更新UI),子类重写
     */
    public func setModel(model: Any?) {
        
    }
    
    /**
     初始化UI
     */
    func initView() {
        
    }
    
    /**
     消除重用造成的数据重复显示
     */
    public func clearData() {
        
    }
    
    /**
     cellIdentifier
     */
    public static func cellIdentifier() -> String {
        return String(describing: self)
    }
    
    /**
     从xib初始化cell
     */
    public static func cellWithTableView(tableview: UITableView) -> UITableViewCell {
        let cellid = String(describing: type(of: self))
        
        if let cell = tableview.dequeueReusableCell(withIdentifier: cellid) {
            return cell
        } else {
            if self.isLoadFromXIB {
                if let cell = Bundle.main.loadNibNamed(cellid, owner: nil, options: nil)?.first as? UITableViewCell {
                    return cell
                } else {
                    DDLogError("loadNibNamed from xib error")
                    let cellType = self
                    return cellType.init()
                }
            } else {
                let cellType = self
                return cellType.init()
            }
        }
    }
    
    required override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

