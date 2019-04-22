//
//  MapViewController+PlaceSearch.swift
//  MyMap
//
//  Created by 68lion on 4/18/19.
//  Copyright © 2019 68lion. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps

extension  MapViewController{
    
    
    
    func nearbyPlacesURL(for location: CLLocation, from distance:CLLocationDistance) -> URL {
        var entityName=""
        switch segmentControl.selectedSegmentIndex{
        case 0:
            entityName="bank"
        case 1:
            entityName="library"
        case 2:
            entityName="mosque"
        default:
            entityName=""
        }
        
        let urlString = String(format:"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=%f&type=%@&key=%@", location.coordinate.latitude, location.coordinate.longitude, distance, entityName, apiKey)
        print(urlString)
        let url = URL(string: urlString)
        
        return url!
    }
    
    func performGoogleRequest(with url: URL) -> String? {
        do {
            let str=try String(contentsOf: url, encoding: .utf8)
            print(str)
            saveData(str: str, inFile: jsonFilePath)
            return str
        } catch {
            print("Download Error: \(error)")
            return nil
        }
    }

    func parse(json:Data)->[String:Any]?{

        do {
            return try JSONSerialization.jsonObject(with: json, options:[]) as? [String:Any]
        } catch  {
            print("JSON ERROR: \(error)")
            return nil
        }
    }

    func parse(dictionary:[String:Any], index:Int)->[NearbyPlace]{

        guard let array=dictionary["results"] as? [Any]
            else {
                print("Expected 'array' results")
                return []
        }
    
        var entityName=""
        switch index{
        case 0:
            entityName="bank"
        case 1:
            entityName="library"
        case 2:
            entityName="mosque"
        default:
            entityName=""
        }
        for resultDict in array {

            if let resultDict=resultDict as? [String:Any]{
                var nearbyPlace : NearbyPlace?
                nearbyPlace=parse(data: resultDict, with: entityName)
                if let result=nearbyPlace{
                    nearbyPlaces.append(result)
                }
            }}
        return nearbyPlaces
    }

    func parse(data dictionary:[String:Any], with segmentName:String) -> NearbyPlace {
            let nearbyPlace = NearbyPlace()
        if let locationDictionary=dictionary["geometry"] as? [String:Any]{
        let coordinates=nearbyPlace.parseToCoordinate(locationDictionary)
                        nearbyPlace.latitude=coordinates[0]
                        nearbyPlace.longitude=coordinates[1]
            
        }
            nearbyPlace.icon=nearbyPlace.parseToImage(iconURLStr: dictionary["icon"] as! String)
            nearbyPlace.id=dictionary["id"] as! String
            nearbyPlace.name=dictionary["name"] as! String
        
            let addressCodes=nearbyPlace.parseToAddCode(dictionary["plus_code"] as! [String:String])
            nearbyPlace.compoundCode=addressCodes[0]
            nearbyPlace.globalCode=addressCodes[1]
        
            if let types=dictionary["types"] as? [String]{
                for type in types{
                            if type==segmentName{
                                nearbyPlace.type=type
                                break
                            }
                        }
                    }
            return nearbyPlace
                }
    
    func showNetworkError(){
        let message:UIAlertController={
            let alert = UIAlertController(
                title: "Whoops... ",
                message: "There was an error reading from the Google Map. please try again.",
                preferredStyle: .alert)
            let action=UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            return alert
        }()
        present(message, animated: true, completion: nil)
    }
    
    func performNearbyPlacesSearch(url:URL, for location:CLLocation, from distance:CLLocationDistance){
        
            print("************* mostafa *********")
            dataTask?.cancel()
            nearbyPlaces = []
            
            let urlSession = URLSession.shared
        
            dataTask=urlSession.dataTask(with: url, completionHandler: {
                
                data,response,error in
                if let error=error as? NSError, error.code == -999{
                    print("Failure! \(error) ")
                    return
                }
                else if let httpResponse=response as? HTTPURLResponse,
                    httpResponse.statusCode==200
                {
                    print("Success!")
                    if let data=data,
                        let jsonDictionary = self.parse(json: data){
                        DispatchQueue.main.async {
                            self.isLoading=false
                            let index=self.segmentControl.selectedSegmentIndex
                            self.nearbyPlaces = self.parse(dictionary: jsonDictionary, index: index)
                            print("\(self.nearbyPlaces.count)")
                            for nearbyPlace in self.nearbyPlaces{
                                self.allNearbyPlaces.append(nearbyPlace)
                                let marker = GMSMarker()
                                marker.position = CLLocationCoordinate2D(latitude: nearbyPlace.latitude, longitude: nearbyPlace.longitude)
                                print(marker.position.latitude)
                                print(marker.position.longitude)
                                let subStrings=nearbyPlace.compoundCode.split(separator: ",")
                                marker.title = String(subStrings[0])
                                marker.snippet = String(subStrings[1])
                                marker.icon=#imageLiteral(resourceName: "map-pin")
                                marker.map=self.myMapView
                                
                            }
                        }
                        
                        if let jsonString = self.performGoogleRequest(with: url){
                            saveData(str: jsonString, inFile: jsonFilePath)
                        }
                        
                        return
                    }
                    
                }
                else{ print("Failure! \(response!)")}
                
                DispatchQueue.main.async {
                    self.isLoading=false
                    self.showNetworkError()
                }
            }
            )
            dataTask?.resume()
    }
         }
    
