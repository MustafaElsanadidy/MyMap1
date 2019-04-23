//
//  AppDelegate.swift
//  MyMap
//
//  Created by 68lion on 4/15/19.
//  Copyright © 2019 68lion. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces


let apiKey="AIzaSyAGV-RXflHFnF1BhsveeRl4HyblVvWAVUA"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        GMSServices.provideAPIKey(apiKey)
        GMSPlacesClient.provideAPIKey(apiKey)

        self.window = UIWindow(frame: UIScreen.main.bounds)
        if let window = self.window {
            window.backgroundColor = UIColor.white
            
            let nav = UINavigationController()
            let mainView = MapViewController()
            nav.viewControllers = [mainView]
            window.rootViewController = nav
            window.makeKeyAndVisible()
        }
        listenForCurrentLocationNotifications()
        return true
    }
    
    func listenForCurrentLocationNotifications() {
        
        NotificationCenter.default.addObserver(
            forName: currentLocationNotification,
            object: nil, queue: OperationQueue.main, using: { notification in
                
                let alert = UIAlertController(
                    title: "EXCELLENT!",
                    message:
                    "you are close to your distenation.\n you are about one kilometre from your location",
                    preferredStyle: .alert)
                
                let action = UIAlertAction(title: "OK", style: .default)
                alert.addAction(action)
                
                self.viewControllerForShowingAlert().present(alert, animated: true,
                                                             completion: nil)
        })
    }
    
    func viewControllerForShowingAlert() -> UIViewController {
        let rootViewController = self.window!.rootViewController!
        if let presentedViewController =
            rootViewController.presentedViewController {
            return presentedViewController
        } else {
            return rootViewController
        }
    }
    func applicationWillResignActive(_ application: UIApplication) {
       
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
       
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        }

    func applicationWillTerminate(_ application: UIApplication) {
        
    }




}
