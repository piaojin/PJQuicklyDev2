//
//  PJBaseTableViewController.swift
//  PJQuicklyDev
//
//  Created by 飘金 on 2017/4/11.
//  Copyright © 2017年 飘金. All rights reserved.
//

import UIKit

open class PJBaseTableViewController: PJBaseModelViewController {
    
    /**
     * 是否自动隐藏上拉加载更多
     */
    open var isAutoHiddenFooterView = true
    
    /**
     * 表格的数据源和事件全部放在里面
     */
    open weak var dataSourceAndDelegate: PJBaseTableViewDataSourceAndDelegate? {
        didSet {
            self.tableView.delegate = self.dataSourceAndDelegate
            self.tableView.dataSource = self.dataSourceAndDelegate
        }
    }
    
    open override var items: [Any]? {
        get {
            if let isSection = self.dataSourceAndDelegate?.isSection(), isSection  {
                return self.dataSourceAndDelegate?.sectionsItems
            } else {
                return self.dataSourceAndDelegate?.items
            }
        }
        set {
            if let isSection = self.dataSourceAndDelegate?.isSection(), isSection {
                self.dataSourceAndDelegate?.addSectionItems(sectionItems: newValue)
            } else {
                self.dataSourceAndDelegate?.addItems(items: newValue)
            }
        }
    }
    
    //默认自动计算高度
    open lazy var tableView:UITableView = {
        var tempTableView = UITableView(frame: self.tableViewFrame(), style: self.tableViewStyle())
        tempTableView.backgroundColor = self.view.backgroundColor
        tempTableView.separatorStyle = .none
        tempTableView.estimatedRowHeight = 44.0
        tempTableView.rowHeight = UITableView.automaticDimension
        return tempTableView
    }()
    
    /**
     刷新类型,上拉或下拉
     */
    open var pullLoadType: PullLoadType = .pullDefault
    open var page: Int = 0
    open var limit: Int = 15
    
    /**
     是否可以上拉刷新
     */
    open var loadMoreEnable: Bool = true {
        willSet {
            if self.isAutoHiddenFooterView {
                self.tableView.mj_footer?.isHidden = !newValue
            }
        }
    }
    
    /**
     是否可以下拉刷新
     */
    open var loadRefreshEnable: Bool = true {
        willSet {
            self.tableView.mj_header?.isHidden = !newValue
        }
    }
    
    /**
     是否禁用上拉刷新
     */
    open var forbidLoadMore: Bool = false {
        willSet {
            self.tableView.mj_footer?.isHidden = newValue
        }
    }
    
    /**
     是否禁用下拉刷新
     */
    open var forbidRefresh: Bool = false {
        willSet {
            self.tableView.mj_header?.isHidden = newValue
        }
    }
    
    open lazy var freshHeader: PJRefreshNormalHeader? = {
        let tempFreshHeader = PJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(beginPullDownRefreshing))
        return tempFreshHeader
    }()
    
    open lazy var freshFooter: PJRefreshAutoNormalFooter? = {
        let tempFreshFooter = PJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(beginPullUpLoading))
        return tempFreshFooter
    }()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.initTableView()
        self.registerCell()
        self.initFreshView()
        self.initTableViewData()
        self.createDataSource()
    }
    
    /**
     子类可以重写，以初始化tabeView
     */
    open func initTableView() {
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
     初始化UI控件
     */
    open func initFreshView() {
        //下拉刷新
        self.tableView.mj_header = self.freshHeader
        //上拉加载更多
        self.tableView.mj_footer = self.freshFooter
    }
    
    /**
     初始化默认值
     */
    open func initTableViewData() {
        self.loadRefreshEnable = true
        self.loadMoreEnable = true
        self.forbidLoadMore = false
        self.page = 1
        self.limit = 10
    }
    
    /**
     注册cell
     */
    open func registerCell() {
        
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: 网络请求相关
    /**
     在网络请求之前可以做的处理
     */
    override open func beforeDoRequest() {
        self.params[self.pageParameterName()] = self.page
        self.params[self.limitParameterName()] = self.limit
        self.baseRequest.parameter = self.params
    }
    
    //分页参数
    open func pageParameterName() -> String {
        return "page"
    }
    
    open func limitParameterName() -> String {
        return "limit"
    }
    
    /**
     *   数据请求返回
     */
    override open func didFinishLoad(success: Any?, failure: Any?) {
        self.endRefreshing()
        super.didFinishLoad(success: success, failure: failure)
    }
    
    /**
     数据请求失败
     */
    override open func didFailLoadWithError(failure: Any?) {
        if self.pullLoadType == .pullUpLoadMore {
            self.page -= 1
        }
        self.endRefreshing()
        super.didFailLoadWithError(failure: failure)
    }
    
    /**
     * 显示正在加载,如果是表格下拉或上拉刷新则不显示加载动画,直接用表格的刷新动画(头部或尾部菊花转圈动画)
     */
    override open func showLoading(show: Bool) {
        if show {
            if self.pullLoadType == .pullDefault {
                super.showLoading(show: show)
            }
        } else {
            super.showLoading(show: show)
        }
    }
    
    /**
     *   子类重写，以设置tableView数据源
     */
    open func createDataSource() {
        
    }
    
    /**
     *   刷新数据
     */
    open func reloadData() {
        self.tableView.reloadData()
    }
    
    override open func onDataUpdated() {
        super.onDataUpdated()
        self.reloadData()
        self.handleWhenLessOnePage()
        self.handleWhenNoneData()
        self.setPullEndStatus()
    }
    
    override open func onLoadFailed() {
        super.onLoadFailed()
        self.setPullFailedStatus()
    }
    
    open func tableViewStyle() -> UITableView.Style {
        return UITableView.Style.plain
    }
    
    // MARK: - 表格的frame
    open func tableViewFrame() -> CGRect {
        return self.view.bounds
    }
    
    // MARK: - 上下拉刷新数据相关
    /**
     下拉刷新
     */
    @objc open func beginPullDownRefreshing() {
        if self.canPullDownRefreshed() {
            self.beforePullDownRefreshing()
            self.refreshForNewData()
        }
    }
    
    open func canPullDownRefreshed() -> Bool {
        return self.loadRefreshEnable
    }
    
    //初始化：是否上拉更多
    open func canPullUpLoadMore() -> Bool {
        return self.loadMoreEnable
    }
    
    /**
     在下拉刷新之前可以处理的事
     */
    open func beforePullDownRefreshing() {
        
    }
    
    /**
     上拉刷新
     */
    @objc open func beginPullUpLoading() {
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
    open func beforePullUpLoading() {
        
    }
    
    /**
     更新了新数据
     */
    open func refreshForNewData() {
        self.isLoading = true
        self.pullLoadType = .pullDownRefresh
        self.page = 1
        //下拉刷新先清空旧数据
        self.items?.removeAll()
        //if let 解包,只要成功解包就会进入{}中,并不会因为isSection()的值为true,故这边要这么写
        if let isSection = self.dataSourceAndDelegate?.isSection() {
            if isSection {
                self.dataSourceAndDelegate?.sectionsItems?.removeAll()
            } else {
                self.dataSourceAndDelegate?.items?.removeAll()
            }
        }
        
        self.doRequest()
    }
    
    /**
     直接调用自动下拉刷新
     */
    open func autoPullDown() {
        self.refreshForNewData()
    }
    
    /**
     停止刷新
     */
    open func endRefreshing() {
        if self.pullLoadType == .pullDownRefresh {
            self.endRefresh()
        } else if self.pullLoadType == .pullUpLoadMore {
            self.endLoadMore()
        }
        
    }
    
    /**
     停止上拉更多
     */
    open func endLoadMore() {
        self.tableView.mj_footer?.endRefreshing()
        self.isLoading = false
        self.pullLoadType = .pullDefault
        self.isPullingUp = false
    }
    
    /**
     停止下拉更多
     */
    @objc open func endRefresh() {
        self.tableView.mj_header?.endRefreshing()
        self.isLoading = false
        if self.pullLoadType != .pullUpLoadMore {
            self.pullLoadType = .pullDefault
        }
    }
    
    open func setPullEndStatus() {
        if self.pullLoadType == .pullUpLoadMore {
            self.endLoadMore()
        } else {
            self.perform(#selector(endRefresh), with: nil, afterDelay: 0.62)
        }
    }
    
    open func setPullFailedStatus() {
        self.setPullEndStatus()
    }
    
    /**
     *   每页item数少于limit处理方法
     */
    open func handleWhenLessOnePage() {
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
    open func handleWhenNoneData() {
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
}

