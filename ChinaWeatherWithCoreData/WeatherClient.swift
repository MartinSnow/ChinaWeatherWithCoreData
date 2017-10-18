//
//  WeatherClient.swift
//  ChinaWeatherWithCoreData
//
//  Created by Ma Ding on 17/10/18.
//  Copyright © 2017年 Ma Ding. All rights reserved.
//

import Foundation

class WeatherClient: NSObject {
    
    static var sharedInstance = WeatherClient()
    
    func getWeatherData(lat: Double, lon: Double, completionHandlerForPublicUserData: @escaping (_ result: [String: AnyObject]?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let request = NSMutableURLRequest(url: URL(string: "http://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&appid=fd9e214e9d86b16132947c62af0cbacb&units=metric")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            /*
             let range = Range(uncheckedBounds: (5, data!.count))
             let newData = data?.subdata(in: range)  subset response data! */
            //print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
            self.convertDataWithCompletionHandler(data!, completionHandlerForConvertData: completionHandlerForPublicUserData)
        }
        task.resume()
        return task
    }
    
    func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: [String: AnyObject]?, _ error: NSError?) -> Void) {
        var parsedResult: [String: AnyObject]?
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : AnyObject]
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        //print("parsedResult is \(parsedResult)")
        
        completionHandlerForConvertData(parsedResult, nil)
    }
}
