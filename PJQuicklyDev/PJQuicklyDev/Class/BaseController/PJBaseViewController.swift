//
//  PJBaseViewController.swift
//  Swift3Learn
//
//  Created by 飘金 on 2017/4/11.
//  Copyright © 2017年 飘金. All rights reserved.
//

import UIKit

class PJBaseViewController: UIViewController, PJBaseEmptyViewDelegate, PJBaseErrorViewDelegate, UIGestureRecognizerDelegate {
    
    //是否加载过空视图
    var isAddEmptyView = false
    //是否加载过出错视图
    var isAddErrorView = false
    
    var isRootViewController = false
    
    //用于各个控制器之间传值
    var query: [String : Any]?
    
    //空视图子类可重写
    lazy var emptyView: PJBaseEmptyView = {
        return self.getEmptyView()
    }()
    
    //出错视图子类可重写
    lazy var errorView: PJBaseErrorView = {
        return self.getErrorView()
    }()
    
    /*
     * 控制器传值
     *
     */
    convenience init(query: [String : Any]?) {
        self.init()
        self.query = query
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        if self.isRootViewController {
            self.initNavigationController()
        }
        
        self.initView()
    }
    
    // MARK: 初始化UI控件
    func initView(){
        PJPrintLog("子类重写initView以初始化UI控件")
    }
    
    // MARK: 初始化导航栏
    func initNavigationController(){
        //解决右滑不能放回上一个控制器
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.isNavigationBarHidden = false
        let leftBarButtonItem = UIBarButtonItem(image: UIImage(named: self.backButtonImageName()), style: UIBarButtonItemStyle.plain, target: self, action: #selector(back(animated:)))
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    //导航栏返回按钮图片名字
    func backButtonImageName() -> String {
        return ""
    }
    
    // MARK: 返回方法,可自定义重写
    @objc func back(animated: Bool) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: 显示正在加载
    func showLoading(show: Bool) {
        if show {
            PJSVProgressHUD.show(withStatus: self.loadingText())
        } else {
            PJSVProgressHUD.dismiss()
        }
    }
    
    func loadingText() -> String {
        return "加载中..."
    }
    
    // MARK: 子类可以重写，以改成需要的错误视图
    func getErrorView() -> PJBaseErrorView{
        let tempErrorView = PJBaseErrorView(frame: self.errorViewFrame())
        tempErrorView.delegate = self
        tempErrorView.isHidden = true
        tempErrorView.backgroundColor = self.view.backgroundColor
        return tempErrorView
    }
    
    // MARK: 显示空页面
    func showEmpty(show: Bool) {
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
    
    // MARK: 子类可重写，修改空页面时的坐标
    func emptyViewFrame() -> CGRect {
        return self.view.bounds
    }
    
    /**
     *   设置为空时的提示文字
     *
     */
    func setEmptyText(text: String?) {
        self.emptyView.setEmptyText(text: text)
    }
    
    /**
     子类可以重写，以改成需要的空视图
     */
    func getEmptyView() -> PJBaseEmptyView {
        let tempEmptyView = PJBaseEmptyView(frame: self.emptyViewFrame())
        tempEmptyView.delegate = self
        tempEmptyView.isHidden = true
        tempEmptyView.backgroundColor = self.view.backgroundColor
        return tempEmptyView
    }
    
    /**
     * 显示空页面
     */
    func showError(show: Bool) {
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
    
    /**
     子类可重写，修改空页面时的坐标
     */
    func errorViewFrame() -> CGRect {
        return self.view.bounds
    }
    
    /**
     *   设置出错时的提示文字
     *
     */
    func setErrorText(text: String?) {
        self.errorView.setErrorText(text: text)
    }
    
    /**
     *   实现协议PJBaseEmptyViewDelegate
     */
    func emptyClick() {
        
    }
    
    /**
     *   实现协议PJBaseErrorViewDelegate
     */
    func errorClick() {
        
    }
    
    deinit {
        PJPrintLog("\(self.classForCoder) deinit")
    }
}
