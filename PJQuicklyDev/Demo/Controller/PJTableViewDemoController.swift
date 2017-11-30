//
//  PJTableViewDemoController.swift
//  PJQuicklyDev
//
//  Created by 飘金 on 2017/4/13.
//  Copyright © 2017年 飘金. All rights reserved.
//

import UIKit
import CocoaLumberjack

let cellID = "ExpressTableViewCell"

class PJTableViewDemoDataSource: PJBaseTableViewDataSourceAndDelegate{
    // MARK: /***********必须重写以告诉表格什么数据模型对应什么cell*************/
    override func tableView(tableView: UITableView, cellClassForObject object: AnyObject?) -> AnyClass {
        if let _ = object?.isKind(of: ExpressItemModel.classForCoder()){
            return ExpressTableViewCell.classForCoder()
        }
        return super.tableView(tableView: tableView, cellClassForObject: object)
    }
}

class PJTableViewDemoController: PJBaseTableViewController {
    /**
     *  网络请求配置,子类可以重写,如果有需要,可以设置返回的数据的模型类型
     */
    typealias ModelType = ExpressModel
    
    lazy var pjTableViewDemoDataSource : PJTableViewDemoDataSource = {
        let tempDataSource = PJTableViewDemoDataSource(dataSourceWithItems: nil)
        // TODO: /*******cell点击事件*******/
        tempDataSource.cellClickClosure = {
            (tableView:UITableView,indexPath : IndexPath,cell : UITableViewCell,object : Any?) in
            PJSVProgressHUD.showSuccess(withStatus: "点击了cell")
        }
        
        // TODO: /************cell的子控件的点击事件************/
        tempDataSource.subVieClickClosure = {
            (sender:AnyObject?, object:AnyObject?) in
            
        }
        return tempDataSource
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView?.register(ExpressTableViewCell.classForCoder(), forCellReuseIdentifier: "ExpressTableViewCell")
        // MARK: 第一步:/******发起网络请求,默认get请求******/
        self.doRequest()
        
        ///请求的数据转成class(ExpressModel)
        var baseRequest = PJBaseRequest<ExpressModel>(path: self.requestUrl)
        baseRequest.headers = self.headers
        baseRequest.httpMethod = .get
        baseRequest.parameter = self.params
        PJHttpRequestClient().send(baseRequest, success: { (model, response) -> Void in
            if let model = model {
                PJCacheManager.saveCustomObject(customObject: model, key: "piaojin")
                let object = PJCacheManager.getCustomObject(type: ExpressModel.self(), forKey: "piaojin")
                DDLogInfo("普通请求完成，json转struct类型，\(String(describing: object))")
            }
        }) { (error) -> Void in
            return
        }

        ///请求的数据转成struct(ExpressModel2)
        var r = PJBaseStrcutRequest<ExpressModel2>(path: "query")
        r.parameter = self.getParams()
        PJHttpRequestClient().sendRequestForStruct(r, success: { (structModel, response) in
            if let model = structModel {
                PJCacheManager.saveCustomObject(customObject: model, key: "piaojin")
                let object = PJCacheManager.getCustomObject(type: ExpressModel2.self(), forKey: "piaojin")
                DDLogInfo("普通请求完成，json转struct类型，\(String(describing: object))")
            }
        }) { (error) in

        }
    }
    
    override func initView() {
        self.title = "快递查询"
    }
    
    /**
     *  网络请求配置,子类可以重写,如果有需要
     */
//    override func getBaseRequest() -> PJBaseRequest<PJBaseModelViewController.ModelType> {
//        var baseRequest = PJBaseRequest<PJBaseModelViewController.ModelType>(path: self.requestUrl, responseClass: self.getModelClassType())
//        baseRequest.headers = self.headers
//        baseRequest.httpMethod = .get
//        baseRequest.parameter = self.params
//        return baseRequest
//    }
    
    /**
     *   第二步:子类重写，网络请求完成
     */
    override func requestDidFinishLoad(success: Any?, failure: Any?) {
        if let expressModel = success as? ExpressModel {
            self.updateView(expressModel: expressModel)
        }
    }
    
    /**
     *   子类重写，网络请求失败
     */
    override func requestDidFailLoadWithError(failure: Any?) {
        
    }
    
    /**
     *   子类重写，以设置tableView数据源
     */
    override func createDataSource(){
        self.dataSourceAndDelegate = self.pjTableViewDemoDataSource
    }
    
    // MARK: 网络请求地址
    override func getRequestUrl() -> String{
        return "query"
    }
    
    // MARK: 网络请求参数
    override func getParams() -> [String:Any] {
        return ["type":"shentong","postid":"3342625464825"]
    }
    
    /// 获取返回的数据的模型类型
    ///
    /// - Returns: 获取返回的数据的模型类型
    override func getModelClassType() -> AnyClass {
        return ExpressModel.classForCoder()
    }
}

/**
 *   子类重写
 */
extension PJTableViewDemoController {
 
    // MARK: 第三步:
    func updateView(expressModel : ExpressModel){
        // TODO: - 注意此处添加网络返回的数据到表格代理数据源中
        self.pjTableViewDemoDataSource.addItems(items: expressModel.data)
        // TODO: - 更新表格显示self.createDataSource(),该调用会在父类进行,子类无需再次手动调用
    }
}
