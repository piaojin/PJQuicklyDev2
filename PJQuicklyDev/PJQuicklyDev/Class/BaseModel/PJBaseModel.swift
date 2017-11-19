//
//  PJBaseModel.swift
//  PJQuicklyDev
//
//  Created by piaojin on 2017/11/17.
//  Copyright © 2017年 飘金. All rights reserved.
//

import UIKit
import ObjectMapper
/*
 *
 *假设服务器返的数据格式是{code:200, data: {字典}, message: "message"}
 *
*/
class PJBaseModel: NSObject, Mappable, PJDecodable {
    
//    var code: Int?
//    var message: String?
//    var data: Any?
    
    required init?(map: Map) {
        
    }
    
    override required init() {
        super.init()
    }
    
    func mapping(map: Map) {
//        code    <- map["code"]
//        message         <- map["message"]
//        data      <- map["data"]
    }
}

extension PJBaseModel {
    
    func parse(jsonString: String) -> Self? {
        let type = type(of: self)
        let baseModel = type.init(JSONString: jsonString)
        return baseModel
    }
    
    static func parseStruct(jsonString: String) -> Self? {
        let type = self
        let baseModel = type.init(JSONString: jsonString)
        return baseModel
    }
}
