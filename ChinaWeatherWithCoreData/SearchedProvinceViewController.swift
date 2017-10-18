//
//  SearchedProvinceViewController.swift
//  ChinaWeatherWithCoreData
//
//  Created by Ma Ding on 17/10/18.
//  Copyright © 2017年 Ma Ding. All rights reserved.
//

import Foundation
import UIKit

class searchedProvinceViewController: cityNameViewController {
    
    // properties
    var searchedItemArray: [SearchedItem] = []
    var searchedCityArray: [String] = []
    var searchedDic: [String: String] = [:]
    var chinaAddress: ChinaAddress?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        getData()
        getCPDic()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedCityArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = searchedCityArray[indexPath.row]
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //start indicator
        indicator.startAnimating()
        
        let cell = tableView.cellForRow(at: indexPath)
        self.cityName = cell?.textLabel?.text
        
        getCoordinator(provinceName: searchedDic[cityName!]!, cityName: cityName!) {(lat, lon, error) in
            if error != nil {
                print("There is no lat and lon")
            }
            self.getWeatherInformation(lat: lat!, lon: lon!)
        }
    }
    
    func getData() {
        do {
            searchedItemArray = try context.fetch(SearchedItem.fetchRequest())
        } catch {
            print("Fetching failed")
        }
        
        for item in searchedItemArray {
            if !searchedCityArray.contains(item.cityName!) {
                searchedCityArray.append(item.cityName!)
            }
        }
        print(searchedCityArray)
    }
    
    func getCPDic() {
        do {
            searchedItemArray = try context.fetch(SearchedItem.fetchRequest())
        } catch {
            print("Fetching failed")
        }
        
        for item in searchedItemArray {
            searchedDic[item.cityName!] = item.provinceName
        }
    }
}
