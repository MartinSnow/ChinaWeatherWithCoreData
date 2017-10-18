//
//  ChinaAddress.swift
//  ChinaWeatherWithCoreData
//
//  Created by Ma Ding on 17/10/18.
//  Copyright © 2017年 Ma Ding. All rights reserved.
//

import Foundation

class ChinaAddress {
    
    var address: [[String: AnyObject]]
    
    init(dictionary: [String: AnyObject]) {
        
        address = dictionary["address"] as! [[String: AnyObject]]
    }
}
