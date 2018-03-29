//
//  PJBaseCustomTableViewController.swift
//  PJQuicklyDev
//
//  Created by 飘金 on 2017/4/29.
//  Copyright © 2017年 飘金. All rights reserved.
//

import UIKit

// MARK: 只封装了表格的上下拉刷新以及分页
class PJBaseCustomTableViewController: PJBaseModelViewController,UITableViewDelegate,UITableViewDataSource {

    lazy var tableView:UITableView = {
        var tempTableView = UITableView(frame: self.tableViewFrame(), style: self.tableViewStyle())
        tempTableView.backgroundColor = self.view.backgroundColor
        tempTableView.delegate = self
        tempTableView.dataSource = self
        tempTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tempTableView.estimatedRowHeight = 66
        tempTableView.rowHeight = UITableViewAutomaticDimension
        tempTableView.translatesAutoresizingMaskIntoConstraints = false
        return tempTableView
    }()
    
    /**
     刷新类型,上拉或下拉
     */
    var pullLoadType:PullLoadType = .pullDefault
    var page: Int = 0
    var limit: Int = 15
    
    /**
     是否可以上拉刷新
     */
    var loadMoreEnable: Bool = true {
        willSet {
            self.tableView.mj_footer.isHidden = !newValue
        }
    }
    
    /**
     是否可以下拉刷新
     */
    var loadRefreshEnable: Bool = true {
        willSet {
            self.tableView.mj_header.isHidden = !newValue
        }
    }
    
    /**
     是否禁用上拉刷新
     */
    var forbidLoadMore: Bool = false {
        willSet {
            self.tableView.mj_footer.isHidden = newValue
            self.tableView.mj_footer.isAutomaticallyHidden = false
        }
    }
    
    /**
     是否禁用下拉刷新
     */
    var forbidRefresh: Bool = false {
        willSet {
            self.tableView.mj_header.isHidden = newValue
        }
    }
    
    lazy var freshHeader: PJRefreshNormalHeader? = {
        let tempFreshHeader = PJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(beginPullDownRefreshing))
        return tempFreshHeader
    }()
    
    lazy var freshFooter: PJRefreshAutoNormalFooter? = {
        let tempFreshFooter = PJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(beginPullUpLoading))
        return tempFreshFooter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initFreshView()
        self.initTableView()
        self.initTableViewData()
    }
    
    /**
     初始化UI控件
     */
    func initFreshView() {
        //下拉刷新
        self.tableView.mj_header = self.freshHeader
        //上拉加载更多
        self.tableView.mj_footer = self.freshFooter
    }
    
    /**
     子类可以重写，以初始化tabeView
     */
    func initTableView() {
        self.view.addSubview(self.tableView)
        tableView.tableFooterView = UIView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        if #available(iOS 11.0, *) {
            self.tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        } else {
            self.tableView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
            self.tableView.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.bottomAnchor).isActive = true
        }
    }
    
    /**
     初始化默认值
     */
    func initTableViewData() {
        self.loadRefreshEnable = true
        self.loadMoreEnable = true
        self.forbidLoadMore = false
        self.page = 1
        self.limit = 10
        self.registerCell()
    }
    
    /**
     注册cell
     */
    func registerCell() {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableViewStyle() -> UITableViewStyle {
        return UITableViewStyle.plain
    }
    
    // MARK: - 表格的frame
    func tableViewFrame() -> CGRect {
        return self.view.bounds
    }
    
    override func onDataUpdated() {
        super.onDataUpdated()
        self.createDataSource()
        self.handleWhenLessOnePage()
        self.handleWhenNoneData()
        self.setPullEndStatus()
    }
    
    override func onLoadFailed() {
        super.onLoadFailed()
        self.setPullFailedStatus()
    }
    
    // MARK: - 上下拉刷新数据相关
    /**
     下拉刷新
     */
    @objc func beginPullDownRefreshing() {
        if self.canPullDownRefreshed() {
            self.beforePullDownRefreshing()
            self.refreshForNewData()
        }
    }
    
    func canPullDownRefreshed() -> Bool {
        return self.loadRefreshEnable
    }
    
    //初始化：是否上拉更多
    func canPullUpLoadMore() -> Bool{
        return self.loadMoreEnable
    }
    
    /**
     在下拉刷新之前可以处理的事
     */
    func beforePullDownRefreshing() {
        
    }
    
    /**
     上拉刷新
     */
    @objc func beginPullUpLoading() {
        self.beforePullUpLoading()
        self.isLoading = true
        self.isPullingUp = true
        self.pullLoadType = .pullUpLoadMore
        self.page += 1
        self.doRequest()
    }
    
    /**
     在上拉刷新之前可以处理的事
     */
    func beforePullUpLoading() {
        
    }
    
    /**
     更新了新数据
     */
    func refreshForNewData() {
        self.isLoading = true
        self.pullLoadType = .pullDownRefresh
        self.page = 1
        //下拉刷新先清空旧数据
        self.items?.removeAll()
        self.doRequest()
    }
    
    /**
     直接调用自动下拉刷新
     */
    func autoPullDown() {
        self.refreshForNewData()
    }
    
    /**
     停止刷新
     */
    func endRefreshing() {
        if self.pullLoadType == .pullDownRefresh {
            self.endRefresh()
        } else if self.pullLoadType == .pullUpLoadMore {
            self.endLoadMore()
        }
    }
    
    /**
     停止上拉更多
     */
    func endLoadMore() {
        self.tableView.mj_footer.endRefreshing()
        self.isLoading = false
        self.pullLoadType = .pullDefault
        self.isPullingUp = false
    }
    
    /**
     停止下拉更多
     */
    @objc func endRefresh() {
        self.tableView.mj_header.endRefreshing()
        self.isLoading = false
        if self.pullLoadType != .pullUpLoadMore {
            self.pullLoadType = .pullDefault
        }
    }
    
    func setPullEndStatus() {
        if self.pullLoadType == .pullUpLoadMore {
            self.endLoadMore()
        } else {
            self.perform(#selector(endRefresh), with: nil, afterDelay: 0.62)
        }
    }
    
    func setPullFailedStatus() {
        self.setPullEndStatus()
    }
    
    /**
     *   每页item数少于limit处理方法
     */
    func handleWhenLessOnePage() {
        if !self.forbidLoadMore {
            var isLoadMore = true
            if let tempItemsCount = self.items?.count {
                if (tempItemsCount < self.limit && self.page == 1) || tempItemsCount <= 0 {
                    isLoadMore = false
                }
            }
            
            if (self.newItemsCount < self.limit && self.page >= 2) || self.newItemsCount <= 0 {
                isLoadMore = false
            }
            
            self.loadMoreEnable = isLoadMore
        }
    }
    
    /**
     *   如果无数据则进行处理
     */
    func handleWhenNoneData() {
        if self.page == 1 {
            if let tempCount = self.items?.count {
                if tempCount <= 0 {
                    //没有数据
                    self.showEmpty(show: true)
                }
            } else {
                self.showEmpty(show: false)
            }
        } else {
            self.showEmpty(show: false)
        }
    }
    
    // MARK: - tableView相关
    /**
     *   子类重写，以设置tableView数据源
     */
    func createDataSource() {
        
    }
    
    // MARK: - 网络请求相关
    /**
     在网络请求之前可以做的处理
     */
    override func beforeDoRequest() {
        self.params[self.pageParameterName()] = self.page
        self.params[self.limitParameterName()] = self.limit
        self.baseRequest.parameter = self.params
    }
    
    //分页参数
    func pageParameterName() -> String {
        return "page"
    }
    
    func limitParameterName() -> String {
        return "limit"
    }
    
    /**
     *   数据请求返回
     */
    override func didFinishLoad(success: Any?, failure: Any?) {
        self.endRefreshing()
        super.didFinishLoad(success: success, failure: failure)
    }
    
    /**
     数据请求失败
     */
    override func didFailLoadWithError(failure: Any?) {
        if self.pullLoadType == .pullUpLoadMore {
            self.page -= 1
        }
        self.endRefreshing()
        super.didFailLoadWithError(failure: failure)
    }
    
    /**
     * 显示正在加载,如果是表格下拉或上拉刷新则不显示加载动画,直接用表格的刷新动画(头部或尾部菊花转圈动画)
     */
    override func showLoading(show: Bool) {
        if show {
            if self.pullLoadType == .pullDefault {
                super.showLoading(show: show)
            }
        } else {
            super.showLoading(show: show)
        }
    }
}

// MARK: - tableView dataSource
extension PJBaseCustomTableViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = self.items?.count else {
            return 0
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell") else {
            return UITableViewCell()
        }
        return cell
    }
}
