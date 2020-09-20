//
//  PJBaseCustomTableViewController.swift
//  PJQuicklyDev
//
//  Created by 飘金 on 2017/4/29.
//  Copyright © 2017年 飘金. All rights reserved.
//

import UIKit

// MARK: 只封装了表格的上下拉刷新以及分页

open class PJBaseCustomTableViewController: PJBaseModelViewController, UITableViewDelegate, UITableViewDataSource {
    open lazy var tableView: UITableView = {
        var tempTableView = UITableView(frame: self.tableViewFrame(), style: self.tableViewStyle())
        tempTableView.backgroundColor = self.view.backgroundColor
        tempTableView.delegate = self
        tempTableView.dataSource = self
        tempTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tempTableView.estimatedRowHeight = 66
        tempTableView.rowHeight = UITableView.automaticDimension
        tempTableView.translatesAutoresizingMaskIntoConstraints = false
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
        didSet {
            self.tableView.mj_footer?.isHidden = !loadMoreEnable
        }
    }

    /**
     是否可以下拉刷新
     */
    open var loadRefreshEnable: Bool = true {
        didSet {
            self.tableView.mj_header?.isHidden = !loadRefreshEnable
        }
    }

    /**
     是否禁用上拉刷新
     */
    open var forbidLoadMore: Bool = false {
        didSet {
            self.tableView.mj_footer?.isHidden = forbidLoadMore
        }
    }

    /**
     是否禁用下拉刷新
     */
    open var forbidRefresh: Bool = false {
        didSet {
            self.tableView.mj_header?.isHidden = forbidRefresh
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
        initFreshView()
        initTableView()
        initTableViewData()
    }

    /**
     初始化UI控件
     */
    open func initFreshView() {
        // 下拉刷新
        tableView.mj_header = freshHeader
        // 上拉加载更多
        tableView.mj_footer = freshFooter
    }

    /**
     子类可以重写，以初始化tabeView
     */
    open func initTableView() {
        view.addSubview(tableView)
        tableView.tableFooterView = UIView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        if #available(iOS 11.0, *) {
            self.tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        } else {
            tableView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
            tableView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.bottomAnchor).isActive = true
        }
    }

    /**
     初始化默认值
     */
    open func initTableViewData() {
        loadRefreshEnable = true
        loadMoreEnable = true
        forbidLoadMore = false
        page = 1
        limit = 10
        registerCell()
    }

    /**
     注册cell
     */
    open func registerCell() {}

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    open func tableViewStyle() -> UITableView.Style {
        return UITableView.Style.plain
    }

    // MARK: - 表格的frame

    open func tableViewFrame() -> CGRect {
        return view.bounds
    }

    override open func onDataUpdated() {
        super.onDataUpdated()
        createDataSource()
        handleWhenLessOnePage()
        handleWhenNoneData()
        setPullEndStatus()
    }

    override open func onLoadFailed() {
        super.onLoadFailed()
        setPullFailedStatus()
    }

    // MARK: - 上下拉刷新数据相关

    /**
     下拉刷新
     */
    @objc open func beginPullDownRefreshing() {
        if canPullDownRefreshed() {
            beforePullDownRefreshing()
            refreshForNewData()
        }
    }

    open func canPullDownRefreshed() -> Bool {
        return loadRefreshEnable
    }

    // 初始化：是否上拉更多
    open func canPullUpLoadMore() -> Bool {
        return loadMoreEnable
    }

    /**
     在下拉刷新之前可以处理的事
     */
    open func beforePullDownRefreshing() {}

    /**
     上拉刷新
     */
    @objc open func beginPullUpLoading() {
        beforePullUpLoading()
        isLoading = true
        isPullingUp = true
        pullLoadType = .pullUpLoadMore
        page += 1
        doRequest()
    }

    /**
     在上拉刷新之前可以处理的事
     */
    open func beforePullUpLoading() {}

    /**
     更新了新数据
     */
    open func refreshForNewData() {
        isLoading = true
        pullLoadType = .pullDownRefresh
        page = 1
        // 下拉刷新先清空旧数据
        items?.removeAll()
        doRequest()
    }

    /**
     直接调用自动下拉刷新
     */
    open func autoPullDown() {
        refreshForNewData()
    }

    /**
     停止刷新
     */
    open func endRefreshing() {
        if pullLoadType == .pullDownRefresh {
            endRefresh()
        } else if pullLoadType == .pullUpLoadMore {
            endLoadMore()
        }
    }

    /**
     停止上拉更多
     */
    open func endLoadMore() {
        tableView.mj_footer?.endRefreshing()
        isLoading = false
        pullLoadType = .pullDefault
        isPullingUp = false
    }

    /**
     停止下拉更多
     */
    @objc open func endRefresh() {
        tableView.mj_header?.endRefreshing()
        isLoading = false
        if pullLoadType != .pullUpLoadMore {
            pullLoadType = .pullDefault
        }
    }

    open func setPullEndStatus() {
        if pullLoadType == .pullUpLoadMore {
            endLoadMore()
        } else {
            perform(#selector(endRefresh), with: nil, afterDelay: 0.62)
        }
    }

    open func setPullFailedStatus() {
        setPullEndStatus()
    }

    /**
     *   每页item数少于limit处理方法
     */
    open func handleWhenLessOnePage() {
        if !forbidLoadMore {
            var isLoadMore = true
            if let tempItemsCount = items?.count {
                if (tempItemsCount < limit && page == 1) || tempItemsCount <= 0 {
                    isLoadMore = false
                }
            }

            if (newItemsCount < limit && page >= 2) || newItemsCount <= 0 {
                isLoadMore = false
            }

            loadMoreEnable = isLoadMore
        }
    }

    /**
     *   如果无数据则进行处理
     */
    open func handleWhenNoneData() {
        if page == 1 {
            if let tempCount = items?.count {
                if tempCount <= 0 {
                    // 没有数据
                    showEmpty(show: true)
                }
            } else {
                showEmpty(show: false)
            }
        } else {
            showEmpty(show: false)
        }
    }

    // MARK: - tableView相关

    /**
     *   子类重写，以设置tableView数据源
     */
    open func createDataSource() {}

    // MARK: - 网络请求相关

    /**
     在网络请求之前可以做的处理
     */
    override open func beforeDoRequest() {
        params[pageParameterName()] = page
        params[limitParameterName()] = limit
        baseRequest.parameter = params
    }

    // 分页参数
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
        endRefreshing()
        super.didFinishLoad(success: success, failure: failure)
    }

    /**
     数据请求失败
     */
    override open func didFailLoadWithError(failure: Any?) {
        if pullLoadType == .pullUpLoadMore {
            page -= 1
        }
        endRefreshing()
        super.didFailLoadWithError(failure: failure)
    }

    /**
     * 显示正在加载,如果是表格下拉或上拉刷新则不显示加载动画,直接用表格的刷新动画(头部或尾部菊花转圈动画)
     */
    override open func showLoading(show: Bool) {
        if show {
            if pullLoadType == .pullDefault {
                super.showLoading(show: show)
            }
        } else {
            super.showLoading(show: show)
        }
    }
}

// MARK: - tableView dataSource

public extension PJBaseCustomTableViewController {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        guard let count = items?.count else {
            return 0
        }
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt _: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell") else {
            return UITableViewCell()
        }
        return cell
    }
}
