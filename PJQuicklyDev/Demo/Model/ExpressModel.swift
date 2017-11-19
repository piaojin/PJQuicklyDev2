//
//  ExpressModel.swift
//  PJQuicklyDev
//
//  Created by 飘金 on 2017/4/13.
//  Copyright © 2017年 飘金. All rights reserved.
//

import UIKit
import ObjectMapper
/******{"message":"ok","nu":"434017443551","ischeck":"0","condition":"00","com":"zhongtong","status":"200","state":"0","data":[{"time":"2017-04-13 11:43:05","ftime":"2017-04-13 11:43:05","context":"[莆田秀屿二部] [莆田市] [莆田秀屿二部]的北高中通正在第1次派件 电话:18059440473 请保持电话畅通、耐心等待","location":""},{"time":"2017-04-13 11:37:18","ftime":"2017-04-13 11:37:18","context":"[莆田秀屿二部] [莆田市] 快件到达 [莆田秀屿二部]","location":""},{"time":"2017-04-13 06:07:11","ftime":"2017-04-13 06:07:11","context":"[莆田] [莆田市] 快件离开 [莆田]已发往[莆田秀屿二部]","location":""},{"time":"2017-04-13 03:27:34","ftime":"2017-04-13 03:27:34","context":"[莆田] [莆田市] 快件到达 [莆田]","location":""},{"time":"2017-04-12 20:57:01","ftime":"2017-04-12 20:57:01","context":"[泉州中转部] [泉州市] 快件离开 [泉州中转部]已发往[莆田]","location":""},{"time":"2017-04-12 20:40:22","ftime":"2017-04-12 20:40:22","context":"[泉州中转部] [泉州市] 快件到达 [泉州中转部]","location":""},{"time":"2017-04-11 23:07:55","ftime":"2017-04-11 23:07:55","context":"[合肥中转部] [合肥市] 快件离开 [合肥中转部]已发往[泉州中转部]","location":""},{"time":"2017-04-11 23:06:08","ftime":"2017-04-11 23:06:08","context":"[合肥] [合肥市] 快件到达 [合肥]","location":""},{"time":"2017-04-11 19:32:54","ftime":"2017-04-11 19:32:54","context":"[合肥蜀山四部] [合肥市] 快件离开 [合肥蜀山四部]已发往[泉州中转部]","location":""},{"time":"2017-04-11 18:02:56","ftime":"2017-04-11 18:02:56","context":"[合肥蜀山四部] [合肥市] [合肥蜀山四部]的钟先生已收件 电话:18134500700","location":""}]}*****/
class ExpressModel: PJBaseModel {
    var message : String?
    var nu : String?
    var condition : String?
    var com : String?
    var status : String?
    var state : String?
    var data : [ExpressItemModel]?
}

/*****{"time":"2017-04-11 18:02:56","ftime":"2017-04-11 18:02:56","context":"[合肥蜀山四部] [合肥市] [合肥蜀山四部]的钟先生已收件 电话:18134500700","location":""}*******/
class ExpressItemModel: PJBaseModel {
    var time : String?
    var ftime : String?
    var context : String?
    var location : String?
    /***cell的高度***/
    var rowH : CGFloat = 0
}
