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
