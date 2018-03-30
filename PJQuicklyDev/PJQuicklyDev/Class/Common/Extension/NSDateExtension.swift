//
//  NSDateExtension.swift
//  meiqu
//
//  Created by piaojin on 16/1/27.
//  Copyright © 2016年 piaojin. All rights reserved.
//

import Foundation
public extension Date {
    public static func isToday(str: String) -> Bool {
        let todayDate = Date()
        let sec = todayDate.timeIntervalSinceNow
        let date = Date(timeIntervalSinceNow: sec)
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        let todayStr = format.string(from: date)
        if str == todayStr {
            return true
        } else {
            return false
        }
    }
    
    public static func dateFromTimeInterval(timeInterval: String,formatter : String) -> String {
        if let time = TimeInterval(timeInterval) {
            let date = Date(timeIntervalSince1970: time)
            let format = DateFormatter()
            format.dateFormat = formatter
            return format.string(from: date)
        } else {
            return ""
        }
    }
}
