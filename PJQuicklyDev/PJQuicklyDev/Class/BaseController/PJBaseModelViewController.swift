//
//  PJBaseModelViewController.swift
//  Swift3Learn
//
//  Created by 飘金 on 2017/4/11.
//  Copyright © 2017年 飘金. All rights reserved.
//

import UIKit
import Alamofire

//刷新类型
public enum PullLoadType: Int {
    case pullDefault = 0
    case pullDownRefresh //下拉
    case pullUpLoadMore  //上拉
}

protocol PJBaseRequestProtocol {
    /**
     *  网络请求配置,子类可以重写,如果有需要,可以设置返回的数据的模型类型
     */
    associatedtype ModelType: PJDecodable
    /**
     *  网络请求地址
     */
    func getRequestUrl() -> String
    
    /**
     *  网络请求参数
     */
    func getParams() -> [String : Any]
    
    /**
     *  网络请求头
     */
    func getHeaders() -> HTTPHeaders
    
    /**
     *  请求完成后数据传递给子类，子类需要重写
     */
    func getHttpMethod() -> HTTPMethod
    
    /**
     *  请求完成后数据传递给子类，子类需要重写
     */
    func requestDidFinishLoad(success: Any?, failure: Any?)
    
    /**
     *  请求失败后数据传递给子类，子类需要重写
     */
    func requestDidFailLoadWithError(failure: Any?)
    
    /// 获取返回的数据的模型类型,子类需要重写
    ///
    /// - Returns: 获取返回的数据的模型类型
    func getModelClassType() -> AnyClass
}

open class PJBaseModelViewController: PJBaseViewController, PJBaseRequestProtocol {
    /**
     *  网络请求配置,子类可以重写,如果有需要,可以设置返回的数据的模型类型
     */
    public typealias ModelType = PJBaseModel
    
    /**
     *  数据源(设置为可选是因为这样外包或子类使用时不用去每次都解包，父类统一解包)
     */
    open lazy var items: [Any]? =  {
        return [Any]()
    }()
    
    /**
     *  网络请求类,子类可以重写,如果有需要
     */
    open lazy var httpRequestClient: PJClient = {
        return PJHttpRequestClient()
    }()
    
    /**
     *  网络请求配置
     */
    open lazy var baseRequest: PJBaseRequest = {
        return self.getBaseRequest()
    }()
    
    open var headers: HTTPHeaders = [:]
    
    open var httpMethod: HTTPMethod = .get
    
    /**
     *  请求参数,子类重写以设置请求参数(重写params的get)
     */
    open var params:[String : Any] = [:]
    
    /**
     *  请求地址，需要子类重写
     */
    open var requestUrl: String {
        return self.getRequestUrl()
    }
    
    ///每次网络请求返回的新的数据量
    open var newItemsCount: Int = 0
    
    ///是否正在上拉刷新
    open var isPullingUp: Bool = false
    
    /**
     *  是否正在加载
     */
    open var isLoading = false
    
    ///初始化网络请求数据
    private func initData() {
        self.params = self.getParams()
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.initData()
        // Do any additional setup after loading the view.
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     *  网络请求配置,子类可以重写,如果有需要,可以设置返回的数据的模型类型
     */
    open func getBaseRequest() -> PJBaseRequest<ModelType> {
        var baseRequest = PJBaseRequest<ModelType>(path: self.requestUrl, responseClass: self.getModelClassType())
        baseRequest.headers = self.headers
        baseRequest.httpMethod = .get
        baseRequest.parameter = self.params
        return baseRequest
    }
    
    /**
     *  发起请求数据
     */
    open func doRequest(){
        PJPrintLog("网络请求的参数params: = \(String(describing: self.getParams()))")
        self.beforeDoRequest()
        if !self.requestUrl.isEmpty {
            /**
             *   开始网络请求，设置默认参数
             */
            let httpRequestClient = PJHttpRequestClient()
            httpRequestClient.send(self.baseRequest, success: { (model, response) -> Void in
                self.didFinishLoad(success: model, failure: nil)
            }, fatalError: { (error) -> Void in
                self.didFailLoadWithError(failure: error)
            })
            
        }else{
            PJPrintLog("requestUrl不能为空!")
        }
        self.requestDidStartLoad()
    }
    
    /**
     在网络请求之前可以做的处理
     */
    open func beforeDoRequest(){
        
    }
    
    /**
     *  开始请求
     */
    open func requestDidStartLoad() {
        //不是在下拉刷新
        if !self.isPullingUp {
            self.showLoading(show:true)
        } else {
            DispatchQueue.global().async {
                //如果现在加载中而且不是在下拉刷新
                DispatchQueue.main.async {
                    if self.isLoading && !self.isPullingUp {
                        self.showLoading(show:true)
                    }
                }
            }
        }
        self.showError(show:false)
        self.isLoading = true
    }
    
    /**
     *  请求完成
     */
    open func didFinishLoad(success: Any?, failure: Any?) {
        self.requestDidFinishLoad(success: success, failure: failure)
        self.onDataUpdated()
        self.showLoading(show: false)
    }
    
    /**
     *  请求失败
     */
    open func didFailLoadWithError(failure: Any?) {
        self.requestDidFailLoadWithError(failure: failure)
        self.onLoadFailed()
        self.showLoading(show: false)
    }
    
    /**
     *  数据开始更新
     */
    open func onDataUpdated() {
        self.showLoading(show:false)
        self.showError(show:false)
        self.isLoading = false
    }
    
    /**
     *  加载失败
     */
    open func onLoadFailed() {
        self.showLoading(show:false)
        self.showError(show:true)
        self.isLoading = false
    }
    
    /**
     *   添加数据，每次请求完数据调用,items中的数据即是一个个model(items设置成可选，外部调用时不用每次都解包，这边统一处理，下同)
     *
     */
    open func addItems(items: [Any]?) {
        if let tempItem = items {
            self.items? += tempItem
            self.newItemsCount = tempItem.count
        }else{
            self.newItemsCount = 0
        }
    }
    
    //添加数据，每次请求完数据调用,item即是一个model
    open func addItem(item: Any?) {
        if let tempItem = item {
            self.items?.append(tempItem)
            self.newItemsCount = 1
        }else{
            self.newItemsCount = 0
        }
    }
    
    // MARK: /********子类需要重写的方法（PJBaseRequestFunc）*********/
    ///网络请求地址
    open func getRequestUrl() -> String {
        PJPrintLog("------->子类需要重写getRequestUrl<-------")
        return ""
    }
    
    ///网络请求参数
    open func getParams() -> [String : Any] {
        PJPrintLog("------->子类需要重写getParams<-------")
        return [:]
    }
    
    /**
     *  请求完成后数据传递给子类，子类需要重写
     */
    open func requestDidFinishLoad(success: Any?, failure: Any?){
        
    }
    
    /**
     *  请求失败后数据传递给子类，子类需要重写
     */
    open func requestDidFailLoadWithError(failure: Any?) {
        
    }
    
    open func getHeaders() -> HTTPHeaders {
        return self.headers
    }
    
    open func getHttpMethod() -> HTTPMethod {
        return self.httpMethod
    }
    
    /// 获取返回的数据的模型类型,子类需要重写
    ///
    /// - Returns: 获取返回的数据的模型类型
    open func getModelClassType() -> AnyClass {
        return ModelType.classForCoder()
    }
}

