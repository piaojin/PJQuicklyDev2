//
//  ExpressModel2.swift
//  PJQuicklyDev
//
//  Created by Zoey Weng on 2017/11/18.
//  Copyright © 2017年 飘金. All rights reserved.
//

import UIKit
import ObjectMapper

struct ExpressModel2: Mappable, PJDecodable {
    
    var message : String?
    var nu : String?
    var condition : String?
    var com : String?
    var status : String?
    var state : String?
    var data : [ExpressItemModel]?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        message    <- map["message"]
        nu    <- map["nu"]
        condition    <- map["condition"]
        com    <- map["com"]
        status    <- map["status"]
        state    <- map["state"]
        data    <- map["data"]
    }
    
    func parse(jsonString: String) -> ExpressModel2? {
        return nil
    }
    
    static func parseStruct(jsonString: String) -> ExpressModel2? {
        let object = ExpressModel2(JSONString: jsonString)
        return object
    }
}
