//
//  PJBaseViewController.swift
//  Swift3Learn
//
//  Created by 飘金 on 2017/4/11.
//  Copyright © 2017年 飘金. All rights reserved.
//

import UIKit

open class PJBaseViewController: UIViewController, PJBaseEmptyViewDelegate, PJBaseErrorViewDelegate, UIGestureRecognizerDelegate {
    
    //是否加载过空视图
    open var isAddEmptyView = false
    
    //是否加载过出错视图
    open var isAddErrorView = false
    
    //是否是首页
    open var isRootViewController = false
    
    //导航栏是否启用自定义返回按钮
    open var isUseCustomBack = true
    
    //导航栏返回按钮图片名字
    open var backButtonImageName: String = ""
    
    //用于各个控制器之间传值
    open var query: [String : Any]?
    
    //是否显示空视图
    open var isShowEmpty = false
    
    //是否显示错误视图
    open var isShowError = false
    
    //空视图子类可重写
    open lazy var emptyView: PJBaseEmptyView = {
        return self.getEmptyView()
    }()
    
    //出错视图子类可重写
    open lazy var errorView: PJBaseErrorView = {
        return self.getErrorView()
    }()
    
    /*
     * 控制器传值
     *
     */
    public convenience init(query: [String : Any]?) {
        self.init()
        self.query = query
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        if self.isRootViewController, self.isUseCustomBack {
            self.initNavigationController()
        }
        
        self.initView()
    }
    
    // MARK: 初始化UI控件
    open func initView(){
        PJPrintLog("子类重写initView以初始化UI控件")
    }
    
    // MARK: 初始化导航栏
    open func initNavigationController(){
        //解决右滑不能放回上一个控制器
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.isNavigationBarHidden = false
        let leftBarButtonItem = UIBarButtonItem(image: UIImage(named: self.backButtonImageName), style: UIBarButtonItemStyle.plain, target: self, action: #selector(back(animated:)))
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    // MARK: 返回方法,可自定义重写
    @objc open func back(animated: Bool) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: 显示正在加载
    open func showLoading(show: Bool) {
        if show {
            PJSVProgressHUD.show(withStatus: self.loadingText())
        } else {
            PJSVProgressHUD.dismiss()
        }
    }
    
    open func loadingText() -> String {
        return "加载中..."
    }
    
    // MARK: 子类可以重写，以改成需要的错误视图
    open func getErrorView() -> PJBaseErrorView{
        let tempErrorView = PJBaseErrorView(frame: self.errorViewFrame())
        tempErrorView.delegate = self
        tempErrorView.isHidden = true
        tempErrorView.backgroundColor = self.view.backgroundColor
        return tempErrorView
    }
    
    // MARK: 显示空页面
    open func showEmpty(show: Bool) {
        if self.isShowEmpty {
            if show {
                if !self.isAddEmptyView {
                    self.isAddEmptyView = true
                    self.view.addSubview(self.emptyView)
                }
                self.view.bringSubview(toFront: self.emptyView)
                self.emptyView.isHidden = false
            } else {
                self.emptyView.isHidden = true
            }
        }
    }
    
    // MARK: 子类可重写，修改空页面时的坐标
    open func emptyViewFrame() -> CGRect {
        return self.view.bounds
    }
    
    /**
     *   设置为空时的提示文字
     *
     */
    open func setEmptyText(text: String?) {
        self.emptyView.setEmptyText(text: text)
    }
    
    /**
     子类可以重写，以改成需要的空视图
     */
    open func getEmptyView() -> PJBaseEmptyView {
        let tempEmptyView = PJBaseEmptyView(frame: self.emptyViewFrame())
        tempEmptyView.delegate = self
        tempEmptyView.isHidden = true
        tempEmptyView.backgroundColor = self.view.backgroundColor
        return tempEmptyView
    }
    
    /**
     * 显示空页面
     */
    open func showError(show: Bool) {
        if self.isShowError {
            if show {
                if !self.isAddErrorView {
                    self.isAddErrorView = true
                    self.view.addSubview(self.errorView)
                }
                self.view.bringSubview(toFront: self.errorView)
                self.errorView.isHidden = false
            } else {
                self.errorView.isHidden = true
            }
        }
    }
    
    /**
     子类可重写，修改空页面时的坐标
     */
    open func errorViewFrame() -> CGRect {
        return self.view.bounds
    }
    
    /**
     *   设置出错时的提示文字
     *
     */
    open func setErrorText(text: String?) {
        self.errorView.setErrorText(text: text)
    }
    
    /**
     *   实现协议PJBaseEmptyViewDelegate
     */
    open func emptyClick() {
        
    }
    
    /**
     *   实现协议PJBaseErrorViewDelegate
     */
    open func errorClick() {
        
    }
    
    deinit {
        PJPrintLog("\(self.classForCoder) deinit")
    }
}
