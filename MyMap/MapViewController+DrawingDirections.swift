//
//  MapViewController+DrawingDirections.swift
//  MyMap
//
//  Created by 68lion on 4/21/19.
//  Copyright © 2019 68lion. All rights reserved.
//

import GoogleMaps
import CoreLocation

extension MapViewController{
   
    func routeURL(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) -> URL{
        
        let apiKey2="AIzaSyDD0Q2SYAdofDZh1HGgIo11HitwCYaD8Ps"
        let urlString=String(format: "https://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=true&mode=driving&key=%@", source.latitude, source.longitude, destination.latitude, destination.longitude, apiKey)
        print(urlString)
        let url = URL(string: urlString)
        
        return url!
    }
    
    func getPolylineRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D){
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let url=routeURL(from: source, to: destination)
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            else {
                do {
                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]{
                        
                        guard let routes = json["routes"] as? NSArray else {
                            DispatchQueue.main.async {
                                print("yoooooo*************")
                                self.showNetworkError()
                            }
                            return
                        }
                        
                        if (routes.count > 0) {
                            let overview_polyline = routes[0] as? NSDictionary
                            let dictPolyline = overview_polyline?["overview_polyline"] as? NSDictionary
                            
                            let points = dictPolyline?.object(forKey: "points") as? String
                            
                           
                            
                            DispatchQueue.main.async {
                                self.showPath(polyStr: points!)
                                let bounds = GMSCoordinateBounds(coordinate: source, coordinate: destination)
                                let update = GMSCameraUpdate.fit(bounds, with: UIEdgeInsetsMake(170, 30, 30, 30))
                                self.myMapView.moveCamera(update)
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                print("*****************")
                                self.showNetworkError()
                            }
                        }
                    }
                }
                catch {
                    print("error in JSONSerialization")
                    DispatchQueue.main.async {
                        self.showNetworkError()
                    }
                }
            }
        })
        task.resume()
    }
    
    func showPath(polyStr :String){
        let path = GMSPath(fromEncodedPath: polyStr)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 3.0
        polyline.strokeColor = UIColor.red
        polyline.map = self.myMapView
    }
}

//    func drawPath(from startLocation:CLLocation,to endLocation:CLLocation){
//
//        let url=routeURL(from: startLocation, to: endLocation)
//
//        dataTask2?.cancel()
//        let urlSession = URLSession.shared
//
//        dataTask2=urlSession.dataTask(with: url, completionHandler: {
//
//            data,response,error in
//            if let error=error as? NSError, error.code == -999{
//                print("Failure! \(error) stephen king")
//                return
//            }
//            else if let httpResponse=response as? HTTPURLResponse,
//                httpResponse.statusCode==200
//            {
//                print("Success!")
//                if let data=data,
//                    let jsonDictionary = self.parse(json: data){
//
//                    if let routes=jsonDictionary["routes"] as? [Any]{
//                        DispatchQueue.main.async {
//                            for route in routes{
//                                if let route=route as? [String:Any]{
//                                    let routeOverviewPolyline=route["overview_polyline"] as! [String:String]
//                                    if let points=routeOverviewPolyline["points"]{
//                                        let path=GMSPath(fromEncodedPath: points)
//                                        let polyline=GMSPolyline(path: path)
//                                        polyline.strokeWidth=4
//                                        polyline.strokeColor=UIColor.red
//                                        polyline.map=self.myMapView
//                                    }
//                                }
//                            }
//                        }
//                    }
//                    return
//                }
//                else{ print("Failure! \(response!)")}
//
//                DispatchQueue.main.async {
//                    self.showNetworkError()
//                }
//            }
//        })
//    }

