//
//  MJBCommon.swift
//  MJBWorker
//
//  Created by piaojin on 16/9/23.
//  Copyright © 2016年 piaojin. All rights reserved.
//

import UIKit
//MARK: UIColor扩展
public extension UIColor{
    class func colorWithHex(rgbValue: Int32) -> UIColor {
        return UIColor.colorWithHex(rgbValue: rgbValue, alpha: 1.0)
    }
    
    class func colorWithHex(rgbValue: Int32, alpha: CGFloat) -> UIColor {
        return UIColor(red: ((CGFloat)((rgbValue & 0xFF0000) >> 16))/255.0, green: ((CGFloat)((rgbValue & 0xFF00) >> 8))/255.0, blue: ((CGFloat)(rgbValue & 0xFF))/255.0, alpha: alpha)
    }
    
    class func colorWithRGB(red: CGFloat, green: CGFloat, blue: CGFloat, alpha:CGFloat = 1.0) -> UIColor{
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
    
    //主色调
    class var mainColor: UIColor{
        return self.colorWithRGB(red: 127, green: 38, blue: 101, alpha: 1)
    }
    
    //随机色
    class var pj_RandomColor: UIColor{
        return self.colorWithRGB(red: CGFloat(arc4random_uniform(256)), green: CGFloat(arc4random_uniform(256)), blue: CGFloat(arc4random_uniform(256)), alpha: 1)
    }
}

//MARK: UIView扩展
public extension UIView {
    var pj_x : CGFloat{
        get{
            return self.frame.origin.x
        }
        set(x){
            self.frame = CGRect(x: x, y: self.frame.origin.y, width: self.frame.size.width, height: self.frame.size.height)
        }
    }
    
    var pj_y : CGFloat{
        get{
            return self.frame.origin.y
        }
        set(y){
            self.frame = CGRect(x: self.frame.origin.x, y: y, width: self.frame.size.width, height: self.frame.size.height)
        }
    }
    
    var pj_width : CGFloat{
        get{
            return self.frame.size.width
        }
        set(width){
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: width, height: self.frame.size.height)
        }
    }
    
    var pj_height : CGFloat{
        get{
            return self.frame.size.height
        }
        set(height){
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: height)
        }
    }
    
    var pj_minX : CGFloat{
        return self.frame.minX
    }
    
    var pj_minY : CGFloat{
        return self.frame.minY
    }
    
    var pj_maxX : CGFloat{
        return self.frame.maxX
    }
    
    var pj_maxY : CGFloat{
        return self.frame.maxY
    }
    
    var pj_centerX : CGFloat{
        get{
            return self.center.x
        }
        set(centerX){
            self.center = CGPoint(x: centerX, y: self.center.y)
        }
    }
    
    var pj_centerY : CGFloat{
        get{
            return self.center.x
        }
        set(centerY){
            self.center = CGPoint(x: self.center.x, y: centerY)
        }
    }
    
    var pj_cornerRadius : CGFloat{
        get{
            return self.layer.cornerRadius
        }
        set(cornerRadius){
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    func pj_setCircle(){
        self.layer.cornerRadius = self.pj_height / 2.0
        self.layer.masksToBounds = true
    }
}

// MARK: - storyboard 圆角直接设置
public extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}

// MARK: UIImage扩展
public extension UIImage {
    func compressImageToSize(newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(newSize)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

// 打印日志
public func PJPrintLog<T>(_ message: T, file: String = #file, method: String = #function, line: Int = #line) {
    #if PJDEBUG
        print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
    #endif
}
