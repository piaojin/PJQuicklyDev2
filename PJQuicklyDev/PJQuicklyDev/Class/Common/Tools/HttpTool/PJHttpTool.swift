//
import Alamofire
//  PJHttpTool.swift
//  Swift3Learn
//
//  Created by 飘金 on 2017/4/10.
//  Copyright © 2017年 飘金. All rights reserved.
//
// 网络请求类
import Foundation

/// 请求的结果是要转成class的模型
public typealias PJSuccess<T: PJRequest> = (_ data: T.Response?, _ response: Any?) -> Void
/// 请求的结果是要转成struct的模型
public typealias PJSuccessForStruct<T: PJRequest> = (_ data: T.Response?, _ response: Any?) -> Void
public typealias PJFatalError = (_ error: Error?) -> Void

/// 服务器返回的数据类型
public enum PJResponseDataType: Int {
    case json = 0 // 服务返回的数据是json
    case string // 服务器返回的数据是字符串
    case data // 返回的是data
}

/// 网络请求协议
public protocol PJClient {
    func send<T: PJRequest>(_ r: T, success: @escaping PJSuccess<T>, fatalError: @escaping PJFatalError)
    func sendRequestForStruct<T: PJRequest>(_ r: T, success: @escaping PJSuccessForStruct<T>, fatalError: @escaping PJFatalError)
}

/// 模型解析协议
public protocol PJDecodable {
    /// PJDecodable 用于解析class类型的模型，由于class不能继承static 静态方法，故使用普通成员方法
    func parse(jsonString: String) -> Self?
    /// PJDecodable 用于解析struct类型的模型
    static func parseStruct(jsonString: String) -> Self?
}

/// 网络请求配置协议
public protocol PJRequest {
    associatedtype Response: PJDecodable
    var path: String { set get }
    var parameter: [String: Any]? { set get }
    var headers: HTTPHeaders { set get }
    var httpMethod: HTTPMethod { set get }
    var host: String { set get }
    var responseDataType: PJResponseDataType { set get }
    /// 要转换的目标数据模型
    var responseClass: AnyClass { set get }
    var encoding: ParameterEncoding { set get }
    var interceptor: RequestInterceptor? { set get }
    var requestModifier: Session.RequestModifier? { set get }
}

/// 默认网络请求配置，用于网络请求返回数据转成class的模型
public struct PJBaseRequest<T: PJBaseModel>: PJRequest {
    public var host: String = PJConst.PJBaseUrl
    public var responseDataType: PJResponseDataType = .json
    public var headers: HTTPHeaders = [:]
    public var httpMethod: HTTPMethod = .get
    public var path: String = ""
    public var parameter: [String: Any]?
    /// 如果需要改变类型，可以用子类重写改类型
    public typealias Response = T
    public var responseClass: AnyClass = T.classForCoder()
    public var encoding: ParameterEncoding = URLEncoding.default
    public var requestModifier: Session.RequestModifier?
    public var interceptor: RequestInterceptor?

    /// responseClass:用于指定请求结果要转换的目标数据模型
    public init(path: String, responseClass: AnyClass) {
        self.path = path
        self.responseClass = responseClass
    }

    public init(path: String) {
        self.path = path
    }
}

/// 默认网络请求配置，用于网络请求返回数据转成struct的模型
public struct PJBaseStrcutRequest<T: PJDecodable>: PJRequest {
    public var host: String = PJConst.PJBaseUrl
    public var responseDataType: PJResponseDataType = .json
    public var headers: HTTPHeaders = [:]
    public var httpMethod: HTTPMethod = .get
    public var path: String = ""
    public var parameter: [String: Any]?
    /// 如果需要改变类型，可以用子类重写改类型
    public typealias Response = T
    public var responseClass: AnyClass = PJBaseModel.classForCoder()
    public var encoding: ParameterEncoding = URLEncoding.default
    public var interceptor: RequestInterceptor?
    public var requestModifier: Session.RequestModifier?

    public init(path: String) {
        self.path = path
    }
}

/// 默认的网络请求实现结构体
public struct PJHttpRequestClient: PJClient {
    /// 用于网络请求的数据要转成struct类型的模型
    public func sendRequestForStruct<T: PJRequest>(_ r: T, success: @escaping PJSuccessForStruct<T>, fatalError: @escaping PJFatalError) {
        send(r, success: { (_, response) -> Void in
            if let response = response as? AFDataResponse<Any>, let data = response.data, let jsonString = String(data: data, encoding: String.Encoding.utf8) {
                let object = T.Response.parseStruct(jsonString: jsonString)
                success(object, response)
            } else {
                success(T.Response.parseStruct(jsonString: ""), response)
            }
        }) { (error) -> Void in
            fatalError(error)
        }
    }

    /// 用于网络请求的数据要转成class类型的模型
    public func send<T: PJRequest>(_ r: T, success: @escaping PJSuccess<T>, fatalError: @escaping PJFatalError) {
        let url = r.host.appending(r.path)

        let request: DataRequest = AF.request(url, method: r.httpMethod, parameters: r.parameter, encoding: r.encoding, headers: r.headers, interceptor: r.interceptor, requestModifier: r.requestModifier)

        switch r.responseDataType {
        case .json:
            request.responseJSON { (response: AFDataResponse<Any>) in
                self.responseHandle(r, response: response, success: success, fatalError: fatalError)
            }
        case .string:
            request.responseString { (response: AFDataResponse<String>) in
                self.responseHandle(r, response: response, success: success, fatalError: fatalError)
            }
        case .data:
            request.responseData { (response: AFDataResponse<Data>) in
                self.responseHandle(r, response: response, success: success, fatalError: fatalError)
            }
        }
    }

    /// 解析服务器返回的数据
    public func responseHandle<T: PJRequest, P>(_ r: T, response: AFDataResponse<P>, success: @escaping PJSuccess<T>, fatalError: @escaping PJFatalError) {
        switch response.result {
        case let .success(value):
            if let data = response.data, let jsonString = String(data: data, encoding: String.Encoding.utf8) {
                PJPrintLog("请求成功结果JSON: \(jsonString)")
                let className: String = NSStringFromClass(r.responseClass)
                if let classType = NSClassFromString(className) as? PJBaseModel.Type {
                    let model = classType.init()
                    let object = model.parse(jsonString: jsonString)
                    success(object as? T.Response, response)
                } else {
                    success(nil, response)
                }
            } else {
                PJPrintLog("请求成功结果\(String(describing: value))")
                success(nil, response)
            }
        case let .failure(error):
            PJPrintLog("请求失败结果error = \(String(describing: error))")
            fatalError(error)
        }
    }
}
