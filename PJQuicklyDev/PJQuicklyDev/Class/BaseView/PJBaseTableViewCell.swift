//
//  PJBaseTableViewCell.swift
//  Swift3Learn
//
//  Created by 飘金 on 2017/4/11.
//  Copyright © 2017年 飘金. All rights reserved.
//

import UIKit
import SnapKit

class PJBaseTableViewCell: UITableViewCell {
    
    /**
     cell子控件点击事件
     */
    var subVieClickClosure : ((_ sender:AnyObject?, _ object:AnyObject?) -> Void)?
    
    /// 是否从xib加载初始化cell
    static var isLoadFromXIB:Bool {
        return false
    }
    var model: AnyObject?
    //cell所在的控制器
    weak var controller:PJBaseViewController?
    
    /**
     cell的高度,如果是以自动计算高度的方式获取cell高度,则子类无需重写改方法,否则需要子类重写改方法以手动计算cell的高度
     */
    class func tableView(tableView: UITableView, rowHeightForObject model: AnyObject?,indexPath:IndexPath) -> CGFloat{
        return 44.0;
    }
    
    /**
     设置model到cell(在这里更新UI),子类重写
     */
    func setModel(model: AnyObject?){
        
    }
    
    /**
     初始化UI
     */
    func initView(){
        
    }
    
    /**
     消除重用造成的数据重复显示
     */
    func clearData(){
        
    }
    
    /**
     从xib初始化cell
     */
    class func cellWithTableView(tableview: UITableView) -> PJBaseTableViewCell {
        let cellid = String(describing: type(of: self))
        
        if let cell = tableview.dequeueReusableCell(withIdentifier: cellid) as? PJBaseTableViewCell {
            return cell
        } else {
            if let cell = Bundle.main.loadNibNamed(cellid, owner: nil, options: nil)?.first as? PJBaseTableViewCell {
                return cell
            } else {
                return PJBaseTableViewCell()
            }
        }
    }
    
    required override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
