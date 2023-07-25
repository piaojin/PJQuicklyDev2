> ### PJQuicklyDev2 快速开发框架的2.0版本，Swift5.0 Xcode14.2
#### 1.0版本如果有兴趣[请移步](https://github.com/piaojin/PJQuicklyDev),相关信息可以参考1.0版本。

#### 在看了🐱神的文章[面向协议编程与 Cocoa 的邂逅 (上)](https://onevcat.com/2016/11/pop-cocoa-1/)与[面向协议编程与 Cocoa 的邂逅 (下)](https://onevcat.com/2016/12/pop-cocoa-2/)
#### 感觉1.0版本的网络与数据解析耦合度太高了，不方便扩展。想要把🐱神的面向协议的思想应用起来，恰巧最近开始看Swift4.0于是就有了快速开发框架2.0版本。主要优化的底层点为网络请求与数据解析。还有tableView网络请求加载数据。

> ### 网络请求
#### 本次的网络请求重构的目的在于解耦，网络请求的方式get,post等等，网络请求的具体实现可以随意替换（即低耦合了）.

#### 如果定义一个网络发送协议，而让其他具体的类去遵循并且实现具体的网络请求功能:
```swift
///网络请求协议
protocol PJClient {
    func send<T: PJRequest>(_ r: T, success: @escaping PJSuccess, fatalError: @escaping PJFatalError)
    func sendRequestForStruct<T: PJRequest>(_ r: T, success: @escaping PJSuccessForStruct<T>, fatalError: @escaping PJFatalError)
}
```
#### 这样以后哦要替换底层网络具体实现时就很容易了，并且不会影响到现有的网络请求相关业务逻辑.

```swift
///默认的网络请求实现结构体
struct PJHttpRequestClient: PJClient {
    
    ///用于网络请求的数据要转成struct类型的模型
    func sendRequestForStruct<T: PJRequest>(_ r: T, success: @escaping PJSuccessForStruct<T>, fatalError: @escaping PJFatalError) {
        self.send(r, success: { (model, response) -> Void in
            if let response = response as? DataResponse<Any>, let data = response.data, let jsonString = String(data:data, encoding: String.Encoding.utf8) {
                let object = T.Response.parseStruct(jsonString: jsonString)
                success(object, response)
            } else {
                success(T.Response.parseStruct(jsonString: ""), response)
            }
        }) { (error) -> Void in
            fatalError(error)
        }
    }
    
    ///用于网络请求的数据要转成class类型的模型
    func send<T: PJRequest>(_ r: T, success: @escaping PJSuccess, fatalError: @escaping PJFatalError) {
        let url = r.host.appending(r.path)
        let request: DataRequest = Alamofire.request(url, method: r.httpMethod, parameters: r.parameter, encoding: URLEncoding.default, headers: r.headers)
        
        switch r.responseDataType {
        case .json:
            request.responseJSON(completionHandler: { (response : DataResponse<Any>) in
                self.responseHandle(r, response: response, success: success, fatalError: fatalError)
            })
            break
        case .string:
            request.responseString(completionHandler: { (response : DataResponse<String>)  in
                self.responseHandle(r, response: response, success: success, fatalError: fatalError)
            })
            break
        case .data:
            request.responseData(completionHandler: { (response : DataResponse<Data>) in
                self.responseHandle(r, response: response, success: success, fatalError: fatalError)
            })
            break
        }
    }
    
    /*****解析服务器返回的数据*****/
    func responseHandle<T: PJRequest, P>(_ r: T, response : DataResponse<P>, success: @escaping PJSuccess, fatalError: @escaping PJFatalError) {
        if response.result.isSuccess {
            
            if let data = response.data, let jsonString = String(data:data, encoding: String.Encoding.utf8) {
                PJPrintLog("请求成功结果JSON: \(jsonString)")
                let className:String = NSStringFromClass(r.responseClass)
                if let classType = NSClassFromString(className) as? PJBaseModel.Type {
                    let model = classType.init()
                    let object = model.parse(jsonString: jsonString)
                    success(object, response)
                } else {
                    success(response.result.value, response)
                }
            } else {
                PJPrintLog("请求成功结果\(String(describing: response.result.value))")
                success(response.result.value, response)
            }
        }else{
            PJPrintLog("请求失败结果error = \(String(describing: response.result.error))")
            fatalError(response.result.error)
        }
    }
}
```
`PJHttpRequestClient`是网络具体实现struct,其中
```swift
func send<T: PJRequest>(_ r: T, success: @escaping PJSuccess, fatalError: @escaping PJFatalError)
```
#### 是实现PJClient的协议的方法，网络调用时类似:
```swift
PJHttpRequestClient().send
```
#### `send`函数里面的具体网络实现可以修改，用原生也好，第三方也好，只要能达到网络请求的目的，随意替换，而不用去大改代码，这就是面向协议的好处。

#### 把网络请求相关的配置也抽象出来也是比较灵活的
```swift
///网络请求配置协议
protocol PJRequest {
    var path: String { get }
    var parameter: [String: Any] { get }
    var headers: HTTPHeaders { get }
    var httpMethod: HTTPMethod { get }
    var host: String { get }
    var responseDataType: PJResponseDataType { get }
    associatedtype Response: PJDecodable
    ///要转换的目标数据模型
    var responseClass: AnyClass { set get }
}

///默认网络请求配置，用于网络请求返回数据转成class的模型
struct PJBaseRequest<T: PJBaseModel>: PJRequest {
    var host: String = PJConst.PJBaseUrl
    var responseDataType: PJResponseDataType = .json
    var headers: HTTPHeaders = [:]
    var httpMethod: HTTPMethod = .get
    var path: String = ""
    var parameter: [String: Any] = [:]
    /// 如果需要改变类型，可以用子类重写改类型
    typealias Response = T
    var responseClass: AnyClass = T.classForCoder()
    
    ///responseClass:用于指定请求结果要转换的目标数据模型
    init(path: String, responseClass: AnyClass) {
        self.path = path
        self.responseClass = responseClass
    }
    
    init(path: String) {
        self.path = path
    }
}

///默认网络请求配置，用于网络请求返回数据转成struct的模型
struct PJBaseStrcutRequest<T: PJDecodable>: PJRequest {
    var host: String = PJConst.PJBaseUrl
    var responseDataType: PJResponseDataType = .json
    var headers: HTTPHeaders = [:]
    var httpMethod: HTTPMethod = .get
    var path: String = ""
    var parameter: [String: Any] = [:]
    /// 如果需要改变类型，可以用子类重写改类型
    typealias Response = T
    var responseClass: AnyClass = PJBaseModel.classForCoder()
    init(path: String) {
        self.path = path
    }
}
```
#### 这里针对不同的返回处理结果(model用class或struct分别实现了协议，后面数据解析会用到),网络的请求部分大概是这样。

> ### 数据解析
#### 显然数据解析也要达到解耦的目的，不管具体用第三方库还是自己一行一行写去解析数据,都是为了达到解析的目的，这样也采用协议，具体解析怎么实现可以随时替换，而不影响现有的解析好的。
```swift
///模型解析协议
protocol PJDecodable {
    /// PJDecodable 用于解析class类型的模型，由于class不能继承static 静态方法，故使用普通成员方法
    func parse(jsonString: String) -> Self?
    /// PJDecodable 用于解析struct类型的模型
    static func parseStruct(jsonString: String) -> Self?
}
```

#### 前面的`protocol PJRequest`有定义`associatedtype Response: PJDecodable`即是协议的泛型，表示网络请求返回后要解析转换后的目的模型。实现该协议时需要指定具体的目的类型`struct PJBaseRequest<T: PJBaseModel>: PJRequest`，这里我们希望代码可以复用故又加了一层泛型，这样`/// 如果需要改变类型，可以用子类重写改类型`typealias Response = T`,T即是目的解析类型，这样调用网络配置类时大概是这样:
```swift
PJBaseRequest<Model>(path: requestUrl)
```
#### 每个model类只要去实现协议，并且实现具体的数据解析操作
```swift
func parse(jsonString: String) -> Self? {
        let classType = type(of: self)
        if let baseModel = classType.deserialize(from: jsonString) {
            return baseModel
        }
        return nil
    }
    
    static func parseStruct(jsonString: String) -> Self? {
        let type = self
        if let baseModel = type.deserialize(from: jsonString) {
            return baseModel
        }
        return nil
    }
```
#### 这里数据解析使用`HandyJSON`,当然你大可以换其他的，因为很容易换。

> #### 这样一个完整的网络的请求，返回数据解析是这样:
```swift
///请求的数据转成class(ExpressModel)
var baseRequest = PJBaseRequest<ExpressModel>(path: self.requestUrl)
        baseRequest.headers = self.headers
        baseRequest.httpMethod = .get
        baseRequest.parameter = self.params
        PJHttpRequestClient().send(baseRequest, success: { (model, response) -> Void in
            if let model = model as? ExpressModel {               print("\(model)")
            }
        }) { (error) -> Void in
            return
        }
        
        ///请求的数据转成struct(ExpressModel2)
        var r = PJBaseStrcutRequest<ExpressModel2>(path: "query")
        r.parameter = self.getParams()
        PJHttpRequestClient().sendRequestForStruct(r, success: { (structModel, response) in
            if let model = structModel {
        print("\(model)")
            }
        }) { (error) in

        }
```
#### 其中`var baseRequest = PJBaseRequest<ExpressModel>`是网络请求配置，`ExpressModel`（可以替换成任意实现PJDecodable解析协议的类）是要解析转换的目的类型，这样网络请求完拿到的数据即是解析转换好的数据。`var r = PJBaseStrcutRequest<ExpressModel2>(path: "query")`是正对解析目的类型是struct的，ExpressModel2及时和目的struct，可以替换成任意实现PJDecodable解析协议的struct.网络请求与数据解析到此结束。

> ### tableView网络请求的封装

#### 发起网络请求，请求到数据，更新`dataSource`,`reload`,cell创建，设置好model,这大概是tableView显示的一贯流程，哪个地方要用到，就把代码复制一份过去。故我这边把这些可以复用的代码都封装到一个父类，需要用到tableView时，只要做一些必要配置一个网络请求你，数据解析，设置，显示的tableView便呈现在我们面前。

#### 具体的用法大概这样:
#### 前期必要设置
#### `dataSource`，实现`PJBaseTableViewDataSourceAndDelegate`协议，`PJBaseTableViewDataSourceAndDelegate`协议是对tableView的dataSource的抽出提取，以减小controller大小
```swift
class PJTableViewDemoDataSource: PJBaseTableViewDataSourceAndDelegate{
    // MARK: /***********必须重写以告诉表格什么数据模型对应什么cell*************/
    override func tableView(tableView: UITableView, cellClassForObject object: AnyObject?) -> AnyClass {
        if let _ = object?.isKind(of: ExpressItemModel.classForCoder()){
            return ExpressTableViewCell.classForCoder()
        }
        return super.tableView(tableView: tableView, cellClassForObject: object)
    }
}
```
#### 只要实现这么一个方法，在控制器中:
```swift
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
```
#### 一个带有分页，数据为空，数据显示，网络请求，数据解析，显示的tableView变完成了。
```swift
self.doRequest()
```
#### 发起网络请求，一个完整的tableview网络请求变搞定。当然可以定制，修改这边不一一列举。今天就到这里，大概是这样，代码和思路大量借鉴🐱神(福建文档写的最烂的男人😜(有问题联系804488815@qq.com))



