//
//  MapViewController+CurrentLocation.swift
//  MyMap
//
//  Created by 68lion on 4/21/19.
//  Copyright © 2019 68lion. All rights reserved.
//

import Foundation
import  CoreLocation
import GoogleMaps

extension MapViewController: CLLocationManagerDelegate{
    
    
    @objc func btnMyLocationAction() {
        let authreq = CLLocationManager.authorizationStatus()
        if authreq == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        else
        {
            if authreq == .denied || authreq == .restricted {
                showLocationServiceDeniedAlert()
                return
            }
            
        }
        // 9
        if updatingLocation {
            stopLocationManager()
        } else {
            lastLocationError = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        
        if let location = location{
            
            print("************ \(location.coordinate.latitude) *********")
            myMapView.animate(toLocation: (location.coordinate))
            
            // Creates a marker in the center of the map.
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            
            if let placemark=placemark{
                marker.title = placemark.locality
                marker.snippet = placemark.country}
            marker.map = myMapView
            
        }
    }
    
    func showLocationServiceDeniedAlert(){
        
        let alert=UIAlertController(title: "Location Service Disables", message: "please enable location service for this app in settings", preferredStyle: .alert)
        let action=UIAlertAction(title: "ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError: \(error)")
        //MARK: 6
        if (error as NSError).code==CLError.locationUnknown.rawValue{
            return
        }
        lastLocationError=error
        location=nil
        stopLocationManager()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation=locations.last!
        print("didUpdateLocations: \(newLocation)")
        
        if newLocation.timestamp.timeIntervalSinceNow < -5{
            return
        }
        if newLocation.horizontalAccuracy<0
        {return}
        
        var distance=CLLocationDistance(DBL_MAX)
        if let location=location{
            distance=newLocation.distance(from: location)
            if distance>5
            {self.location=nil}
        }
        
        if location==nil || newLocation.horizontalAccuracy < location!.horizontalAccuracy{
            
            location=newLocation
            lastLocationError=nil
            
            if let location=location{
              for place in nearbyPlaces{
                if location.findDistance(from: place)==1000.0{
                    //push notification
                    NotificationCenter.default.post(name: currentLocationNotification, object: nil)
                    //local notification
                    location.registerNotification()
                    location.scheduleNotification()
                    break
                }
             }
        }
            
            if newLocation.horizontalAccuracy<=locationManager.desiredAccuracy{
                
                print("*** we're done!")
                stopLocationManager()
                if(distance>0)
                {
                    print("\(distance)")
                    performingReverseGeocoding=false }
            }
            
            if !performingReverseGeocoding{
                
                print(" yooo ")
                performingReverseGeocoding=true
                geocoder.reverseGeocodeLocation(newLocation, completionHandler: {
                    
                    placemarks,error in
                    if error==nil , let p=placemarks , !p.isEmpty{
                        
                        self.placemark=p.last!
                    }
                    else{
                        self.placemark=nil
                    }
                    
                    self.lastGeocodingError=error
                    self.performingReverseGeocoding=false
                })
            }
        }
        else if distance<1
        {
            //when the previous condition is false ,then location variable won't change it will still have old value and when we measure time difference will be always big
            let time=newLocation.timestamp.timeIntervalSince((location!.timestamp))
            if time>10
            {
                print("*** force done!  \(time)")
                stopLocationManager()
            }
        }
    }
    
    @objc func didTimeOut(){
        
        if location==nil{
            stopLocationManager()
            lastLocationError=NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
        }
    }
    
    func startLocationManager(){
        //MAR:12
        //we write If's condition because if the user disabled Location Services completely on her device , it doesn't matter that rest of code execute
        //if the user disabled Location Services completely on her device that won't result error(denied)
        
        if CLLocationManager.locationServicesEnabled() {
            timer=Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(didTimeOut), userInfo: nil, repeats: false)
            updatingLocation=true
            locationManager.delegate=self
            lastLocationError=nil
            locationManager.desiredAccuracy=kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    //MARK:7
    func stopLocationManager(){
        if let timer=timer{
            
            timer.invalidate()
        }
        updatingLocation=false
        locationManager.delegate=nil
        locationManager.stopUpdatingLocation()
    }
    
}
