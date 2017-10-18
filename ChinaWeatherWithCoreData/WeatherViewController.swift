//
//  WeatherViewController.swift
//  ChinaWeatherWithCoreData
//
//  Created by Ma Ding on 17/10/18.
//  Copyright © 2017年 Ma Ding. All rights reserved.
//

import Foundation
import UIKit

class weatherViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Properties
    var cityName: String?
    var weatherList: [[String:AnyObject]]?
    weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = cityName
    }
    
    
    
    // UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (weatherList?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath)
        let weatherInfo = weatherList?[indexPath.row]
        cell.detailTextLabel?.text = weatherInfo?["dt_txt"] as? String
        let tempDic = weatherInfo?["main"] as? [String: AnyObject]
        let temp = tempDic?["temp"] as! Double
        cell.textLabel?.text = "\(temp)℃"
        return cell
    }
}


