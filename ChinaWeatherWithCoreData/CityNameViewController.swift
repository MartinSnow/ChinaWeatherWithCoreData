//
//  CityNameViewController.swift
//  ChinaWeatherWithCoreData
//
//  Created by Ma Ding on 17/10/18.
//  Copyright © 2017年 Ma Ding. All rights reserved.
//

import Foundation
import UIKit

class cityNameViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var province: Province?
    var weatherList: [[String:AnyObject]]?
    var cityName: String?
    var searchedItemArray: [SearchedItem] = []
    var searchedCity: [String] = []
    let indicator = UIActivityIndicatorView()
    let specialCitites = ["北京","天津","上海","重庆","香港特别行政区","澳门特别行政区","台湾"]
    
    // coredata context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add an activity indicator
        view.addSubview(indicator)
        indicator.center = view.center
        indicator.hidesWhenStopped = true
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        
        getSearchedCity()
    }
    
    // UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("cell number is \((province?.cities.count)!)")
        return (province?.cities.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath)
        let cityCell = province?.cities[indexPath.row]
        cell.textLabel?.text = cityCell?["name"] as? String
        return cell
    }
    
    // UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //start indicator
        indicator.startAnimating()
        
        let cell = tableView.cellForRow(at: indexPath)
        self.cityName = cell?.textLabel?.text
        
        let cityName = cell?.textLabel?.text
        let provinceName = province?.name
        
        print("searchedCity is \(searchedCity)")
        print("cityName is \(cityName!)")
        print(!searchedCity.contains(cityName!))
        
        if !searchedCity.contains(cityName!) {
            let searchedItem = SearchedItem(context: context)
            // save cellName in coredata
            searchedItem.cityName = cityName
            searchedItem.provinceName = provinceName
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            print("save")
        }
        
        getCoordinator(provinceName: provinceName!, cityName: cityName!) {(lat, lon, error) in
            self.indicator.stopAnimating()
            if error != nil {
                print("There is no lat and lon")
            }
            self.getWeatherInformation(lat: lat!, lon: lon!)
        }
    }
}

// Get coordinator of the city
extension cityNameViewController {
    
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
    
}

extension cityNameViewController {
    
    func getWeatherInformation(lat: Double, lon: Double){
        
        self.indicator.startAnimating()
        
        WeatherClient.sharedInstance.getWeatherData(lat: lat, lon: lon){ (weatherData, error) in
            
            if error != nil {
                self.alert(message: "Can't get weather data")
                self.indicator.stopAnimating() // It takes too much to hide activity indicator
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
    
    func alert(message: String){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func getSearchedCity() {
        do {
            searchedItemArray = try context.fetch(SearchedItem.fetchRequest())
        } catch {
            print("Fetching failed")
        }
        
        for item in searchedItemArray {
            searchedCity.append(item.cityName!)
        }
    }
    
}
