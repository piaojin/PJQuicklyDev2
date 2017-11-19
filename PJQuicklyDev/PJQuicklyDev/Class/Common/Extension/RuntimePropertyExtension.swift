//
//  RuntimeProperty.swift
//  PJQuicklyDev
//
//  Created by Zoey Weng on 2017/11/19.
//  Copyright © 2017年 飘金. All rights reserved.
//

import Foundation

extension NSObject{
    
    /**
     获取对象对于的属性值，无对于的属性则返回NIL
     
     - parameter property: 要获取值的属性
     
     - returns: 属性的值
     */
    func getValueOfProperty(property: String)-> Any? {
        let allPropertys = self.getAllPropertys()
        if allPropertys.contains(property) {
            return self.value(forKey: property)
        }else{
            return nil
        }
    }
    
    /**
     设置对象属性的值
     
     - parameter property: 属性
     - parameter value:    值
     
     - returns: 是否设置成功
     */
    func setValueOfProperty(property: String,value: Any) -> Bool {
        let allPropertys = self.getAllPropertys()
        if allPropertys.contains(property) {
            self.setValue(value, forKey: property)
            return true
        } else {
            return false
        }
    }
    
    /**
     获取对象的所有属性名称
     
     - returns: 属性名称数组
     */
    func getAllPropertys() -> [String] {
        var result = [String]()
//        let count = UnsafeMutablePointer<UInt32>.allocate(capacity: 0)
//        let buff = class_copyPropertyList(object_getClass(self), count)
//        let countInt = Int(count[0])
//
//        for index in 0..<countInt {
//            if let temp = buff?[index] {
//                let tempPro = property_getName(temp)
//                result.append(String(describing: tempPro))
//            }
//        }
        var outCount: UInt32 = 0
        //调用runtime 方法 class_copyPropertyList 获取类的公有属性列表
        let propertyList = class_copyPropertyList(self.classForCoder, &outCount)
        //遍历数组
        for i in 0..<Int(outCount) {
            guard let pty = propertyList?[i],
                let cName = property_getName(pty),
                let oName = String(utf8String: cName)
                else{
                    //如果 pty cName oName 不存在的话 继续遍历下一个
                    continue
            }
            print(oName)
            result.append(oName)
        }
        //因为propertyList数组是copy出来的,所以要释放数组
        free(propertyList)
        return result
    }
}
