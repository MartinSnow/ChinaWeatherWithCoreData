//
//  SearchedProvinceViewController.swift
//  ChinaWeatherWithCoreData
//
//  Created by Ma Ding on 17/10/18.
//  Copyright © 2017年 Ma Ding. All rights reserved.
//

import Foundation
import UIKit

class searchedProvinceViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // properties
    var searchedItemArray: [SearchedItem] = []
    var searchedCityArray: [String] = []
    var searchedDic: [String: String] = [:]
    var chinaAddress: ChinaAddress?
    var cityName: String?
    var weatherList: [[String:AnyObject]]?
    let indicator = UIActivityIndicatorView()
    let specialCitites = ["北京","天津","上海","重庆","香港特别行政区","澳门特别行政区","台湾"]
    
    // coredata context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //add an activity indicator
        view.addSubview(indicator)
        indicator.center = view.center
        indicator.hidesWhenStopped = true
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        
        getData()
        getCPDic()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedItemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = searchedItemArray[indexPath.row].cityName
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //start indicator
        indicator.startAnimating()
        
        let cell = tableView.cellForRow(at: indexPath)
        self.cityName = cell?.textLabel?.text
        print(self.cityName)
        
        getCoordinator(provinceName: searchedDic[cityName!]!, cityName: cityName!) {(lat, lon, error) in
            if error != nil {
                print("There is no lat and lon")
            }
            self.getWeatherInformation(lat: lat!, lon: lon!)
        }
    }
 
    // Delete searched Item
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = searchedItemArray[indexPath.row]
            context.delete(item)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            getData()
        }
        tableView.reloadData()
    }
    
    func getData() {
        do {
            searchedItemArray = try context.fetch(SearchedItem.fetchRequest())
        } catch {
            print("Fetching failed")
        }
        print("searchedItemArray is \(searchedItemArray)")
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
    
    func getWeatherInformation(lat: Double, lon: Double){
        
        WeatherClient.sharedInstance.getWeatherData(lat: lat, lon: lon){ (weatherData, error) in
            
            if error != nil {
                self.alert(message: "Can't get weather data")
                return
            }
            DispatchQueue.main.async{
                
                if let list = weatherData!["list"] as? [[String: AnyObject]] {
                    self.weatherList = list
                }
                
                //stop indicator
                self.indicator.stopAnimating()
                
                let weatherViewController = self.storyboard?.instantiateViewController(withIdentifier: "weatherViewController") as! weatherViewController
                weatherViewController.cityName = self.cityName
                weatherViewController.weatherList = self.weatherList
                self.navigationController?.pushViewController(weatherViewController, animated: true)
            }
            
        }
    }
    
    func getCoordinator(provinceName: String, cityName: String, completionHandlerForCoordinator: @escaping (_ lat: Double?, _ lon: Double?, _ error: NSError?) -> Void){
        
        if !specialCitites.contains(provinceName) {
            let path = Bundle.main.path(forResource: provinceName, ofType: "json")
            let pathURL = URL(fileURLWithPath: path!)
            let data = NSData(contentsOf: pathURL)
            
            WeatherClient.sharedInstance.convertDataWithCompletionHandler(data as! Data){(parsedResult, error) in
                
                if error != nil {
                    print("Fail to get parsedResult")
                    return
                }
                
                DispatchQueue.main.async{
                    if let features = parsedResult?["features"] as? [[String: AnyObject]] {
                        for feature in features {
                            if let properties = feature["properties"] as? [String: AnyObject] {
                                if let name = properties["name"] as? String {
                                    if name == cityName {
                                        let coordinator = properties["cp"] as? [Double]
                                        //print("\(cityName), \(coordinator)")
                                        completionHandlerForCoordinator(coordinator?[1], coordinator?[0], nil)
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else {
            switch provinceName {
            case "北京":
                let coordinator = [117.0923,40.5121]
                completionHandlerForCoordinator(coordinator[1], coordinator[0], nil)
            //print("\(provinceName), \(coordinator)")
            case "天津":
                let coordinator = [117.4672,40.004]
                completionHandlerForCoordinator(coordinator[1], coordinator[0], nil)
            //print("\(provinceName), \(coordinator)")
            case "上海":
                let coordinator = [121.4333,31.1607]
                completionHandlerForCoordinator(coordinator[1], coordinator[0], nil)
            //print("\(provinceName), \(coordinator)")
            case "重庆":
                let coordinator = [108.8196,28.8666]
                completionHandlerForCoordinator(coordinator[1], coordinator[0], nil)
                print("\(provinceName), \(coordinator)")
            case "香港特别行政区":
                let coordinator = [114.1657, 22.2793]
                completionHandlerForCoordinator(coordinator[1], coordinator[0], nil)
            //print("\(provinceName), \(coordinator)")
            case "澳门特别行政区":
                let coordinator = [113.5586, 22.1630]
                completionHandlerForCoordinator(coordinator[1], coordinator[0], nil)
            //print("\(provinceName), \(coordinator)")
            case "台湾":
                let coordinator = [121.0193, 23.4366]
                completionHandlerForCoordinator(coordinator[1], coordinator[0], nil)
            //print("\(provinceName), \(coordinator)")
            default:
                return
            }
        }
        
    }
    
    func alert(message: String){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}
