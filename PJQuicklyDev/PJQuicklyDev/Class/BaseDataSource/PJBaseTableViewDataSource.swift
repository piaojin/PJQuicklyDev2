//
//  PJBaseTableViewDataSource.swift
//  Swift3Learn
//
//  Created by 飘金 on 2017/4/12.
//  Copyright © 2017年 飘金. All rights reserved.
//

import UIKit

public protocol PJBaseTableViewDataSourceDelegate {
    
    /**
     * 子类必须实现协议,以告诉表格每个model所对应的cell是哪个
     */
    func tableView(tableView: UITableView, cellClassForObject object: Any?) -> AnyClass
    
    /**
     *若为多组需要子类重写
     */
    func tableView(tableView: UITableView, indexPathForObject object: Any) -> NSIndexPath?
    
    func tableView(tableView: UITableView, objectAt indexPath: IndexPath) -> Any?
    
    /// MARK: 子类可以重写以获取到刚初始化的cell,可在此时做一些额外的操作
    func pj_tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, cell: UITableViewCell,object:Any?)
}

/**
 * 表格的数据源和事件全部放在里面,自动布局(如果要手动计算高度需要继承PJBaseTableViewManualDataSourceAndDelegate)
 */
open class PJBaseTableViewDataSourceAndDelegate: NSObject,UITableViewDataSource,UITableViewDelegate,PJBaseTableViewDataSourceDelegate {
    
    /**
     * 单组数据的数据源
     */
    open lazy var items :[Any]? = {
        return [Any]()
    }()
    
    /**
     * 分组数据的数据源
     */
    open lazy var sectionsItems :[Any]? = {
        return [Any]()
    }()
    
    /**
     * 计算cell高度的方式,自动计算(利用FDTemplateLayoutCell库)和手动frame计算,默认自动计算,如果是手动计算则cell子类需要重写class func tableView(tableView: UITableView, rowHeightForObject model: AnyObject?,indexPath:IndexPath) -> CGFloat
     */
    open var isAutoCalculate = true
    
    /**
     * cell的点击事件回调闭包     */
    open var cellClickClosure :((_ tableView:UITableView,_ indexPath : IndexPath,_ cell : UITableViewCell,_ object : Any?) -> Void)?
    
    /**
     是否处理重用造成的数据重复显示问题
     */
    open var isClearRepeat = false
    
    /**
     是否重用cell
     */
    open var isRepeatCell = true
    
    /**
     * 只有单组数据
     */
    public init(dataSourceWithItems items: [Any]?) {
        super.init()
        if let tempItems = items {
            self.items? += tempItems
        }
    }
    
    /**
     * 分组数据
     */
    public init(dataSourceWithSectionsItems items: [Any]?) {
        super.init()
        if let tempSectionsItems = items {
            self.sectionsItems? += tempSectionsItems
        }
    }
    
    /**
     子类可以重写，以确定那些高度固定的cell
     */
    //    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    //        return self.getHeightForRow(tableView, atIndexPath: indexPath)
    //    }
    
    /**
     设置cell被选中时的样式
     */
    open func getUITableViewCellSelectionStyle() -> UITableViewCellSelectionStyle {
        return UITableViewCellSelectionStyle.default
    }
    
    /// MARK: 子类可以重写以获取到刚初始化的cell,可在此时做一些额外的操作
    open func pj_tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, cell: UITableViewCell,object:Any?) {
        
    }
    
    /**
     * 子类重写,以告诉表格每个model所对应的cell是哪个
     */
    open func tableView(tableView: UITableView, cellClassForObject object: Any?) -> AnyClass {
        return PJBaseTableViewCell.classForCoder()
    }
    
    /**
     *若为多组需要子类重写
     */
    open func tableView(tableView: UITableView, indexPathForObject object: Any) -> NSIndexPath? {
        var objectIndex:Int
        let tempItems = self.items! as NSArray
        objectIndex = tempItems.index(of: object)
        if objectIndex >= 0 {
            return  NSIndexPath(row: objectIndex, section: 0)
        }
        return nil
    }
    
    open func tableView(tableView: UITableView, objectAt indexPath: IndexPath) -> Any? {
        if self.isSection(){
            /**
             *因数据结构差异，需在子类重写
             * eg: id obj = [self.sectionsItems objectAtIndex:(NSUInteger) indexPath.section];
             if ([obj isKindOfClass:[CategoryItem class]]) {
             CategoryItem *item = (CategoryItem *)obj;
             if (indexPath.row < item.dataArray.count) {
             return [item.dataArray objectAtIndex:(NSUInteger) indexPath.row];
             }
             }
             */
            return nil
        } else {
            if let tempItems = self.items {
                if tempItems.count > 0 && indexPath.row < tempItems.count {
                    return self.items![indexPath.row]
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
    }
    
    deinit{
        self.items = nil
        self.sectionsItems = nil
    }
}

/**
 * tableViewDataSource delegate数据源代理
 */
public extension PJBaseTableViewDataSourceAndDelegate {
    
    /**
     * 是否是分组数据,默认否,默认单组,子类可以重写
     */
    public func isSection() -> Bool {
        return false
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        if self.isSection() {
            if let tempSectionsItems = self.sectionsItems {
                if tempSectionsItems.count > 0 {
                    return self.sectionsItems!.count
                } else {
                    return 1
                }
            } else {
                return 1
            }
        } else {
            return 1
        }
    }
    
    /**
     *若为多组需要子类重写
     */
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isSection() {
            if let tempSectionsItemsCount = self.sectionsItems?.count {
                /**
                 *因数据结构差异，需在子类重写
                 * eg:
                 var item:CategoryItem = self.sectionsItems[section]
                 return item.dataArray.count
                 */
                return tempSectionsItemsCount
            } else {
                return 0
            }
        } else {
            if let tempCount = self.items?.count {
                return tempCount
            } else {
                return 0
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object: Any? = self.tableView(tableView: tableView, objectAt: indexPath)
        
        /**
         *根据子类重写方法中返回的类型名来创建对应的cell
         */
        let cellClass:AnyClass = self.tableView(tableView: tableView, cellClassForObject: object)
        let className:String = NSStringFromClass(cellClass)
        //用类型名称做ID
        let identifier:String = "\(cellClass.self)"
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            if cell is PJBaseTableViewCellProtocol, let baseTableViewCellProtocol = cell as? PJBaseTableViewCellProtocol {
                let cellClassType = type(of: baseTableViewCellProtocol)
                if let isLoadFromXIB = cellClassType.isLoadFromXIB, isLoadFromXIB {
                    /**
                     *  从xib加载初始化cell
                     *
                     */
                    cell = cellClassType.cellWithTableView?(tableview: tableView)
                } else {
                    if let classType = NSClassFromString(className) as? UITableViewCell.Type {
                        if self.isRepeatCell {
                            //不重用cell
                            cell = classType.init(style: UITableViewCellStyle.default, reuseIdentifier: nil)
                        } else {
                            cell = classType.init(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
                        }
                    } else {
                        PJPrintLog("获取cell类型失败,创建PJBaseTableViewCell失败!")
                        cell = PJBaseTableViewCell()
                        cell?.textLabel?.text = "获取cell类型失败,创建PJBaseTableViewCell失败!"
                    }
                }
            }
        } else {
            if self.isClearRepeat {
                //删除cell的所有子视图
                while cell?.contentView.subviews.last != nil {
                    cell?.contentView.subviews.last?.removeFromSuperview()
                }
            }
        }
        
        cell?.selectionStyle = self.getUITableViewCellSelectionStyle()
        
        if cell is PJBaseTableViewCellProtocol, let baseTableViewCellProtocol = cell as? PJBaseTableViewCellProtocol {
            baseTableViewCellProtocol.clearData?()
            //传递数据
            baseTableViewCellProtocol.setModel(model: object)
        }
        
        if object != nil {
            self.pj_tableView(tableView, cellForRowAt: indexPath, cell: cell!, object: object)
        }
        
        return cell!
    }
}

/**
 * delegate表格点击事件代理
 */
public extension PJBaseTableViewDataSourceAndDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath), let object = self.tableView(tableView: tableView, objectAt: indexPath) {
            self.cellClickClosure?(tableView,indexPath,cell,object)
        }
    }
}

public extension PJBaseTableViewDataSourceAndDelegate {
    
    /**
     * 单组数据添加多个模型数据
     */
    public func addItems(items : [Any]?) {
        if let items = items {
            self.items? += items
        }
    }
    
    /**
     * 单组数据添加一个模型数据
     */
    public func addItem(item : Any?) {
        if let item = item {
            self.items?.append(item)
        }
    }
    
    /**
     * 分组数据添加多个模型数据
     */
    public func addSectionItems(sectionItems : [Any]?) {
        if let sectionItems = sectionItems {
            self.sectionsItems? += sectionItems
        }
    }
    
    /**
     * 分组数据添加一个模型数据
     */
    public func addSectionItem(sectionItem : AnyObject?) {
        if let sectionItem = sectionItem{
            self.sectionsItems?.append(sectionItem)
        }
    }
}
