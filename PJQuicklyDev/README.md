# 之前在网上看到一个OC封装的父类,即把网络请求,网络出错处理,没有数据处理,tableView的上下拉刷新,tableView的dataSource和delegate,cell的初始化,高度的计算,分页等都封装到父类.方便开发使用,无需每次都敲一遍.
## 这边我自己用Swift3.1又实现了一遍(其中有封装的比较简单的父类,也有封装比较全的父类)并且将其进行了改进(个人认为是改进),方便开发使用,去除了重复的代码与工作.
# **开始使用吧(这边以使用封装好的表格父类为例,例子中数据来源是快递的查询API,需要传递快递的编号,写得时候我的那个快递还没到,以后可能数据信息会失效,故自己把快的编号换成一个你自己的淘宝刚下单的宝贝快的编号(postid),对应的快递公司的编号(type)也要修改)[免费的快递查询API地址点击这里](http://www.bejson.com/knownjson/webInterface/)**
# 第一步创建start
### 创建一个实现遵循父协议PJBaseTableViewDataSourceAndDelegate的类PJTableViewDemoDataSource,父协议PJBaseTableViewDataSourceAndDelegate遵循NSObject,UITableViewDataSource,UITableViewDelegate,PJBaseTableViewDataSourceDelegate协议,其中PJBaseTableViewDataSourceDelegate协议的定义如下:

```
protocol  PJBaseTableViewDataSourceDelegate{
    
    /**
     * 子类必须实现协议,以告诉表格每个model所对应的cell是哪个
     */
    func tableView(tableView: UITableView, cellClassForObject object: AnyObject?) -> AnyClass
    
    /**
     *若为多组需要子类重写
     */
    func tableView(tableView: UITableView, indexPathForObject object: AnyObject) -> NSIndexPath?
    
    func tableView(tableView: UITableView, objectForRowAtIndexPath indexPath: IndexPath) -> AnyObject?
    
    /// MARK: 子类可以重写以获取到刚初始化的cell,可在此时做一些额外的操作
    func pj_tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, cell: UITableViewCell,object:AnyObject?)
}
```

### PJTableViewDemoDataSource类必须实现:
```
// MARK: /***********必须重写以告诉表格什么数据模型对应什么cell*************/
    override func tableView(tableView: UITableView, cellClassForObject object: AnyObject?) -> AnyClass {
        if let _ = object?.isKind(of: 数据模型类型){
            return 返回对应cell类型
        }
        return super.tableView(tableView: tableView, cellClassForObject: object)
    }
```

### 创建一个控制器继承表格父类
```
class PJTableViewDemoController: PJBaseTableViewController(**表格父类**)
```
### 定一个PJTableViewDemoDataSource属性:
```
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

```
# 到这边创建工作end

# 第二步使用start
### 在PJTableViewDemoController类中实现以下方法:
```
/**
 *   子类重写
 */
extension PJTableViewDemoController{
    
    /**
     *   网络请求完成
     */
    override func requestDidFinishLoad(success: AnyObject?, failure: AnyObject?) {
        if let response = success{
            let expressModel : ExpressModel = ExpressModel.mj_object(withKeyValues: response)
            self.updateView(expressModel: expressModel)
        }
    }
 
    func updateView(expressModel : ExpressModel){
        // TODO: - 注意此处添加网络返回的数据到表格代理数据源中
        self.pjTableViewDemoDataSource.addItems(items: expressModel.data)
        // TODO: - 更新表格显示self.createDataSource(),该调用会在父类进行,子类无需再次手动调用
    }
    
    /**
     *   网络请求失败
     */
    override func requestDidFailLoadWithError(failure: AnyObject?) {
        
    }
    
    /**
     *   以设置tableView数据源
     */
    override func createDataSource(){
        self.dataSourceAndDelegate = self.pjTableViewDemoDataSource
    }
    
    // MARK: 网络请求地址
    override func getRequestUrl() -> String{
        return "http://www.kuaidi100.com/query"
    }
    
    // MARK: 网络请求参数
    override func getParams() -> [String:Any]{
        return ["type":"shentong","postid":"3330209976637"]
    }
}

```
### 方法是以重写的方式,故需要重写的可以重写,无需的即不必重写
# 到这里只需要self.doRequest()(在viewDidLoad中调用即可)就完成一个从网络加载数据并且显示在tableView的操作,并且已经封装好上下拉刷新,分页等.end

## **!!!!!!备注**:关于cell高度的计算分为自动计算与手动计算,默认自动计算,自动计算时-->注意label如果是有换行的需要设置preferredMaxLayoutWidth属性,否则在iOS10等系统上label无法自动换行<--,这边的自动计算高度用的是[FDTemplateLayoutCel](https://github.com/forkingdog/UITableView-FDTemplateLayoutCell)(自动布局模式,当然可以自行添加frame计算模式),相关代码:
```
/**
     计算cell高度的方式,自动计算(利用FDTemplateLayoutCell库)和手动frame计算,默认自动计算,如果是手动计算则cell子类需要重写class func tableView(tableView: UITableView, rowHeightForObject model: AnyObject?,indexPath:IndexPath) -> CGFloat
     **注意label如果是有换行的需要设置preferredMaxLayoutWidth属性,否则在iOS10等系统上label无法自动换行**
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //自动计算cell高度(带有缓存)
        if self.isAutoCalculate{
            return tableView.fd_heightForCell(withIdentifier: cellID, cacheBy: indexPath) { [weak self] (cell : Any?) in
                guard let tempCell = cell as? PJBaseTableViewCell else{
                    return
                }
                //自动计算cell高度
                tempCell.setModel(model: self?.tableView(tableView: tableView, objectForRowAtIndexPath: indexPath))
            }
        }else{
            return self.getHeightForRow(tableView: tableView, atIndexPath: indexPath)
        }
    }
    
    /**
     获取cell的高度
     */
    func getHeightForRow(tableView:UITableView, atIndexPath indexPath:IndexPath) -> CGFloat{
        let object = self.tableView(tableView: tableView, objectForRowAtIndexPath: indexPath)
        let cls : AnyClass = self.tableView(tableView: tableView, cellClassForObject: object)
        if let tempCls = cls as? PJBaseTableViewCell.Type{
            return tempCls.tableView(tableView: tableView, rowHeightForObject: object,indexPath:indexPath)
        }else{
            return 44.0;
        }
 }
```
###### 福建代码注释写得最烂的男人😜(有问题联系804488815@qq.com)



