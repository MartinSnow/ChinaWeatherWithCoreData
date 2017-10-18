//
//  Province.swift
//  ChinaWeatherWithCoreData
//
//  Created by Ma Ding on 17/10/18.
//  Copyright © 2017年 Ma Ding. All rights reserved.
//

import Foundation

class Province {
    
    var name: String
    var cities: [[String: AnyObject]]
    
    init(dictionary: [String: AnyObject]) {
        name = dictionary["name"] as! String
        cities = dictionary["sub"] as! [[String: AnyObject]]
    }
    
}
