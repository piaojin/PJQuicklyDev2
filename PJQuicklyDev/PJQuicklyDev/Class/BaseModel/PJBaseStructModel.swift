//
//  PJBaseStructModel.swift
//  PJQuicklyDev
//
//  Created by Zoey Weng on 2017/11/18.
//  Copyright © 2017年 飘金. All rights reserved.
//

import UIKit
import HandyJSON

protocol StructEncodable {
    var encoded: StructDecodable? { get }
}

protocol StructDecodable {
    var decoded: StructEncodable? { get }
}

extension Sequence where Iterator.Element: StructEncodable {
    var encoded: [StructDecodable] {
        return self.filter({ $0.encoded != nil }).map({ $0.encoded! })
    }
}

extension Sequence where Iterator.Element: StructDecodable {
    var decoded: [StructEncodable] {
        return self.filter({ $0.decoded != nil }).map({ $0.decoded! })
    }
}

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

// MARK: struct的归档参考:https://gist.github.com/ryuichis/f98f0b725156e15638982458b4a6ba8f#file-session-swift
extension PJBaseStructModel {
    // MARK: struct归档辅助类
    @objc(prefix)class Coding: NSObject, NSCoding {
        let baseStructModel: PJBaseStructModel?
        
        init(baseStructModel: PJBaseStructModel) {
            self.baseStructModel = baseStructModel
            super.init()
        }
        
        ///编码
        func encode(with aCoder: NSCoder) {
            guard let baseStructModel = baseStructModel else {
                return
            }
            
            aCoder.encode(baseStructModel.code, forKey:"code")
            aCoder.encode(baseStructModel.message, forKey:"message")
            aCoder.encode(baseStructModel.data, forKey:"data")
        }
        
        ///解码
        required init?(coder aDecoder: NSCoder) {
            guard let code = aDecoder.decodeObject(forKey: "code") as? Int,
                let message = aDecoder.decodeObject(forKey: "message") as? String,
                let data = aDecoder.decodeObject(forKey: "data") else {
                    return nil
            }
            
            let decodedBaseStructModel = PJBaseStructModel(code: code, message: message, data: data)
            baseStructModel = decodedBaseStructModel
            super.init()
        }
    }
}

extension PJBaseStructModel: StructEncodable {
    var encoded: StructDecodable? {
        return PJBaseStructModel.Coding(baseStructModel: self)
    }
}

extension PJBaseStructModel.Coding: StructDecodable {
    var decoded: StructEncodable? {
        return self.baseStructModel
    }
}
