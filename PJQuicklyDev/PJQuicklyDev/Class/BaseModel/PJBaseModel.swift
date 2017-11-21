//
//  PJBaseModel.swift
//  PJQuicklyDev
//
//  Created by piaojin on 2017/11/17.
//  Copyright © 2017年 飘金. All rights reserved.
//

import UIKit
import HandyJSON
/*
 *
 *假设服务器返的数据格式是{code:200, data: {字典}, message: "message"}
 *
*/
class PJBaseModel: NSObject, HandyJSON, PJDecodable, NSCoding {
    
    internal func encode(with aCoder: NSCoder) {
        var count :UInt32 = 0
        if let ivar = class_copyIvarList(self.classForCoder, &count) {
            for i in 0..<Int(count) {
                let iv = ivar[i]
                //获取成员变量的名称 -> c语言字符串
                if let cName = ivar_getName(iv) {
                    //转换成String字符串
                    guard let strName = String(cString: cName, encoding: String.Encoding.utf8) else{
                        //继续下一次遍历
                        continue
                    }
                    //利用kvc 取值
                    let value = self.value(forKey: strName)
                    aCoder.encode(value, forKey: strName)
                    print("\(strName)")
                }
            }
            // 释放c 语言对象
            free(ivar)
        }
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        super.init()
        var count :UInt32 = 0
        if let ivar = class_copyIvarList(self.classForCoder, &count) {
            for i in 0..<Int(count) {
                let iv = ivar[i]
                //获取成员变量的名称 -》 c语言字符串
                if let cName = ivar_getName(iv) {
                    //转换成String字符串
                    guard let strName = String(cString: cName, encoding: String.Encoding.utf8) else{
                        //继续下一次遍历
                        continue
                    }
                    //进行解档取值
                    let value = aDecoder.decodeObject(forKey: strName)
                    //利用kvc给属性赋值
                    setValue(value, forKeyPath: strName)
                    print("\(strName)")
                }
            }
            // 释放c 语言对象
            free(ivar)
        }
    }
    
    
//    var code: Int?
//    var message: String?
//    var data: Any?
    
    override required init() {
        super.init()
    }
}

extension PJBaseModel {
    
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
}
