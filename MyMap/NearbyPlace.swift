//
//   SearchResult.swift
//  MyMap
//
//  Created by 68lion on 4/19/19.
//  Copyright © 2019 68lion. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class NearbyPlace{
    
    var latitude : CLLocationDegrees = -33.86
    var longitude : CLLocationDegrees = 151.20
    var icon=#imageLiteral(resourceName: "angry")
    var id = ""
    var name = ""
    var compoundCode=""
    var globalCode = ""
    var type = ""
    var vicinity = ""
    
    func parseToCoordinate(_ dictionary:[String:Any]) -> [Double]{
        
        var coordinates=[Double]()
        
        if let dicy=dictionary["location"] as? [String:Double]{
           
            if let latitude1=dicy["lat"]{
                let latitudeStr=String(format: "%.8f", latitude1)
                if let latitude=Double(latitudeStr){
                    coordinates.append(latitude)
                    }
                 }
            if let longitude1=dicy["lng"]{
                let longitudeStr=String(format: "%.8f", longitude1)
                if let longitude=Double(longitudeStr){
                    coordinates.append(longitude)
                    }
                }
        }
        return coordinates
        
        }
    
    
    func parseToAddCode(_ dicy:[String:String]) -> [String]{
        
        var addressCodes=[String]()
            if let compound_code=dicy["compound_code"]{
                addressCodes.append(compound_code)}
            if let global_code=dicy["global_code"]{
                addressCodes.append(global_code)}
        print(addressCodes[0])
        return addressCodes
    }
    
    
    func parseToImage( iconURLStr:String) -> UIImage{

        var iconImage=UIImage(named: "")
        if let url=URL(string: iconURLStr){
            if let result = try? Data(contentsOf: url){
        if let image=UIImage(data: result){
            iconImage = image
                }
            }
        }
        return iconImage!
    }
    
}
