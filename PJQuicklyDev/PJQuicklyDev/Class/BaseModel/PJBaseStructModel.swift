//
//  PJBaseStructModel.swift
//  PJQuicklyDev
//
//  Created by Zoey Weng on 2017/11/18.
//  Copyright © 2017年 飘金. All rights reserved.
//

import HandyJSON
import UIKit

public struct PJBaseStructModel: HandyJSON, PJDecodable {
    public var code: Int?
    public var message: String?
    public var data: Any?

    public init() {}

    public func parse(jsonString _: String) -> PJBaseStructModel? {
        return nil
    }

    public static func parseStruct(jsonString: String) -> PJBaseStructModel? {
        if let object = PJBaseStructModel.deserialize(from: jsonString) {
            return object
        }
        return nil
    }
}
