//
//  ProvinceNameViewController.swift
//  ChinaWeatherWithCoreData
//
//  Created by Ma Ding on 17/10/18.
//  Copyright © 2017年 Ma Ding. All rights reserved.
//

import Foundation
import UIKit

class provinceNameViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // properties
    var data: NSDictionary?
    var chinaAddress: ChinaAddress?
    
    var originalArray: [String] = []
    var searchingDataArray: [String] = []
    var searching = false //This for search is on or not that identifier
    
    
    // coredata context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.showsCancelButton = false
        
        data = NSDictionary(contentsOf: Bundle.main.url(forResource: "address", withExtension: "plist")!)
        chinaAddress = ChinaAddress(dictionary: data as! [String : AnyObject])
        
        for item in (chinaAddress?.address)! {
            let province = item["name"] as! String
            originalArray.append(province)
        }
        
        
    }

    @IBAction func historyButton(_ sender: AnyObject) {
        
        print("tap button")
        let searchedProvinceViewController = self.storyboard!.instantiateViewController(withIdentifier: "searchedProvinceViewController") as! searchedProvinceViewController
        searchedProvinceViewController.chinaAddress = chinaAddress
        
        self.navigationController?.pushViewController(searchedProvinceViewController, animated: true)
    }
    
    // UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching == true {
            return searchingDataArray.count
        } else {
            return originalArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "provinceCell", for: indexPath)
        if searching == true, (searchingDataArray.count > indexPath.row) {
            cell.textLabel?.text = searchingDataArray[indexPath.row]
        } else {
            cell.textLabel?.text = originalArray[indexPath.row]
        }
        return cell
    }
    
    // UITableViewDelegate
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
}

// Add a searchbar on the tableView
extension provinceNameViewController: UISearchBarDelegate {
    
    // How to add searchBar https://www.youtube.com/watch?v=MgNRMcCWJhU
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchingDataArray = originalArray.filter({ (text) -> Bool in
            let tmp: NSString = text as NSString
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        if searchingDataArray.count == 0 {
            searching = false
        } else {
            searching = true
        }
        tableView.reloadData()
    }
    
    //How to hide keyboard after searching https://www.youtube.com/watch?v=cQj744EsOcM
    // When search ends
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searching = false
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false // Hide cancel button when search ends
    }
    
    // When search begins
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searching = true
        searchBar.showsCancelButton = true // Show cancel button when search begins
    }
    
    // When you click on cancel
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false // Hide cancel button when click it
    }
    
    // When you click on search
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searching = false // I think it's the same of true
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false // Hide cancel button when click search button
    }
}

