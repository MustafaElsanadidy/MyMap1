//
//  CLLocation+ScheduledNotification.swift
//  MyMap
//
//  Created by 68lion on 4/21/19.
//  Copyright © 2019 68lion. All rights reserved.
//

import Foundation
import CoreLocation
import UserNotifications

extension CLLocation{
    
    func registerNotification(){
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) {
            granted, error in
            if granted{
                print("we have perrmission")
            }else{
                print("permission denied")
            }
        }
    }
    
    func removeNotification() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["LocalNotification"])
    }
    
    
       func scheduleNotification() {
            removeNotification()
            // 1
            let content = UNMutableNotificationContent()
            content.title = "EXECELLENT!:"
            content.body = "you are close to your distenation.\n you are about one kilometre from your location"
            content.sound = UNNotificationSound.default()
            // 2
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
                // 3
            let request = UNNotificationRequest(identifier: "LocalNotification", content: content, trigger: trigger)
            let center = UNUserNotificationCenter.current()
            center.add(request)
            print("Scheduled notification \(request)")
        }
    
    func findDistance(from nearbyPlace:NearbyPlace)->CLLocationDistance{
        
        let nearbyLocation=CLLocation(latitude: nearbyPlace.latitude, longitude: nearbyPlace.longitude)
        var locDistance=CLLocationDistance()
        locDistance=abs(nearbyLocation.distance(from: self))
        return locDistance
    }
    
    
    }

