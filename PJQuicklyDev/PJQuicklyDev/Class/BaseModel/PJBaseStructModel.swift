//
//  PJBaseStructModel.swift
//  PJQuicklyDev
//
//  Created by Zoey Weng on 2017/11/18.
//  Copyright © 2017年 飘金. All rights reserved.
//

import UIKit
import ObjectMapper

struct PJBaseStructModel: Mappable, PJDecodable {
    
    var code: Int?
    var message: String?
    var data: Any?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        code    <- map["code"]
        message         <- map["message"]
        data      <- map["data"]
    }
    
    func parse(jsonString: String) -> PJBaseStructModel? {
        return nil
    }
    
    static func parseStruct(jsonString: String) -> PJBaseStructModel? {
        let object = PJBaseStructModel(JSONString: jsonString)
        return object
    }
}
