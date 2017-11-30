//
//  PJHttpTool.swift
//  Swift3Learn
//
//  Created by 飘金 on 2017/4/10.
//  Copyright © 2017年 飘金. All rights reserved.
//
//网络请求类
import Foundation
import Alamofire

///请求的结果是要转成class的模型
typealias PJSuccess<T: PJRequest> = (_ data: T.Response?, _ response : Any?) -> Void
///请求的结果是要转成struct的模型
typealias PJSuccessForStruct<T: PJRequest> = (_ data: T.Response?, _ response : Any?) -> Void
typealias PJFatalError = (_ error : Any?) -> Void

///服务器返回的数据类型
enum PJResponseDataType : Int{
    case json = 0//服务返回的数据是json
    case string //服务器返回的数据是字符串
    case data//返回的是data
}

///网络请求协议
protocol PJClient {
    func send<T: PJRequest>(_ r: T, success: @escaping PJSuccess<T>, fatalError: @escaping PJFatalError)
    func sendRequestForStruct<T: PJRequest>(_ r: T, success: @escaping PJSuccessForStruct<T>, fatalError: @escaping PJFatalError)
}

///模型解析协议
protocol PJDecodable {
    /// PJDecodable 用于解析class类型的模型，由于class不能继承static 静态方法，故使用普通成员方法
    func parse(jsonString: String) -> Self?
    /// PJDecodable 用于解析struct类型的模型
    static func parseStruct(jsonString: String) -> Self?
}

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
    func send<T: PJRequest>(_ r: T, success: @escaping PJSuccess<T>, fatalError: @escaping PJFatalError) {
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
    func responseHandle<T: PJRequest, P>(_ r: T, response : DataResponse<P>, success: @escaping PJSuccess<T>, fatalError: @escaping PJFatalError) {
        if response.result.isSuccess {
            
            if let data = response.data, let jsonString = String(data:data, encoding: String.Encoding.utf8) {
                PJPrintLog("请求成功结果JSON: \(jsonString)")
                let className:String = NSStringFromClass(r.responseClass)
                if let classType = NSClassFromString(className) as? PJBaseModel.Type {
                    let model = classType.init()
                    let object = model.parse(jsonString: jsonString)
                    success(object as? T.Response, response)
                } else {
                    success(nil, response)
                }
            } else {
                PJPrintLog("请求成功结果\(String(describing: response.result.value))")
                success(nil, response)
            }
        }else{
            PJPrintLog("请求失败结果error = \(String(describing: response.result.error))")
            fatalError(response.result.error)
        }
    }
}

