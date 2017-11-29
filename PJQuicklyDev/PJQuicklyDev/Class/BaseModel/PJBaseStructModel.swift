//
//  PJBaseStructModel.swift
//  PJQuicklyDev
//
//  Created by Zoey Weng on 2017/11/18.
//  Copyright © 2017年 飘金. All rights reserved.
//

import UIKit
import HandyJSON

struct PJBaseStructModel: HandyJSON, PJDecodable {
    
    var code: Int?
    var message: String?
    var data: Any?
    
    func parse(jsonString: String) -> PJBaseStructModel? {
        return nil
    }
    
    static func parseStruct(jsonString: String) -> PJBaseStructModel? {
        if let object = PJBaseStructModel.deserialize(from: jsonString) {
            return object
        }
        return nil
    }
}
