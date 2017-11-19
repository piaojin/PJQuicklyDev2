//
//  ExpressModel2.swift
//  PJQuicklyDev
//
//  Created by Zoey Weng on 2017/11/18.
//  Copyright © 2017年 飘金. All rights reserved.
//

import UIKit
import HandyJSON

struct ExpressModel2: HandyJSON, PJDecodable {
    
    var message : String?
    var nu : String?
    var condition : String?
    var com : String?
    var status : String?
    var state : String?
    var data : [ExpressItemModel]?
    
    func parse(jsonString: String) -> ExpressModel2? {
        return nil
    }
    
    static func parseStruct(jsonString: String) -> ExpressModel2? {
        if let object = ExpressModel2.deserialize(from: jsonString) {
            return object
        }
        return nil
    }
}
