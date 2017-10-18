//
//  SearchedProvinceViewController.swift
//  ChinaWeatherWithCoreData
//
//  Created by Ma Ding on 17/10/18.
//  Copyright © 2017年 Ma Ding. All rights reserved.
//

import Foundation
import UIKit

class searchedProvinceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // properties
    var searchedProvinceArray: [SearchedProvince] = []
    var searchedArray: [String] = []
    var chinaAddress: ChinaAddress?
    
    // coredata context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        getData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = searchedArray[indexPath.row]
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cellName = tableView.cellForRow(at: indexPath)?.textLabel?.text
        
        // save cellName in coredata
        let searchedProvince = SearchedProvince(context: context)
        searchedProvince.name = cellName!
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        for item in (chinaAddress?.address)! {
            let itemName = item["name"] as! String
            if itemName == cellName {
                let province = Province(dictionary: item)
                let cityNameViewController = self.storyboard!.instantiateViewController(withIdentifier: "cityNameViewController") as! cityNameViewController
                cityNameViewController.province = province
                
                self.navigationController?.pushViewController(cityNameViewController, animated: true)
                break
            }
        }
    }
    
    func getData() {
        do {
            searchedProvinceArray = try context.fetch(SearchedProvince.fetchRequest())
        } catch {
            print("Fetching failed")
        }
        
        for item in searchedProvinceArray {
            if !searchedArray.contains(item.name!) {
                searchedArray.append(item.name!)
            }
        }
        print(searchedArray)
    }
}
