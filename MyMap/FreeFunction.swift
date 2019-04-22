//
//  FreeFunction.swift
//  MyMap
//
//  Created by 68lion on 4/18/19.
//  Copyright © 2019 68lion. All rights reserved.
//

import Foundation
import UserNotifications

// MARK: - UserNotifications
let currentLocationNotification = Notification.Name(
    rawValue: "DistanceInfoNotification")

func removeNotification(){
    let center = UNUserNotificationCenter.current()
    center.removeDeliveredNotifications(withIdentifiers: ["DistanceInfoNotification"])
}

// MARK: - tracking JSON Result in a file

let applicationDirectory:URL={
    let urlString2="file:///Users/68lion/Desktop/Raywenderlich The iOS Apprentice 5th Edition/MyMap"
    let escapedURLString=urlString2.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    let url=URL(string: escapedURLString)
    return url!
}()


let jsonFilePath:URL={
    return applicationDirectory.appendingPathComponent("1.txt.json")
}()

func saveData(str:String,inFile file:URL){
    
    try! str.write(to: file, atomically: true, encoding: .utf8)
}

func  loadDataFromFile() ->String{
    
    let path = jsonFilePath
    
    if let jsonString=try?String(contentsOf: path){
        
        return jsonString
    }
    return ""
}
