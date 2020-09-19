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
open class PJBaseModel: NSObject, HandyJSON, PJDecodable {
    
//    var code: Int?
//    var message: String?
//    var data: Any?
    
    required override public init() {
        super.init()
    }
}

public extension PJBaseModel {
    
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
