//
//  MapViewController.swift
//  MyMap2
//
//  Created by 68lion on 4/17/19.
//  Copyright © 2019 68lion. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class MapViewController: UIViewController, GMSMapViewDelegate{
    
    let locationManager = CLLocationManager()
    
    var location: CLLocation?
    var updatingLocation = false
    var addressStatus=""
    var lastLocationError: Error?
    
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: Error?
    
    var timer: Timer?
    
    var nearbyPlaces=[NearbyPlace]()
    var allNearbyPlaces=[NearbyPlace]()
    var randomNearbyPlaces=[NearbyPlace]()
    var hasSearched = false
    var isLoading=false
    var dataTask:URLSessionDataTask?
    
    var dataTask2:URLSessionDataTask?
    
    var customMarkerWidth=50
    var customMarkerHeight=50
    var endLocation=CLLocation(latitude: -33.86, longitude: 151.20)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Home"
        self.view.backgroundColor = UIColor.white
        locationManager.delegate = self
        location=CLLocation(latitude: -33.86, longitude: 151.20)
        
        setupViews()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Loading Views on simulater
    
    func setupViews() {
        view.addSubview(myMapView)
        myMapView.topAnchor.constraint(equalTo: view.topAnchor).isActive=true
        myMapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive=true
        myMapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive=true
        myMapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 60).isActive=true
        
        self.view.addSubview(segmentControl)
        segmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive=true
        segmentControl.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive=true
        segmentControl.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive=true
        segmentControl.heightAnchor.constraint(equalToConstant: 35).isActive=true
        
        self.view.addSubview(btnMyLocation)
        btnMyLocation.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive=true
        btnMyLocation.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive=true
        btnMyLocation.widthAnchor.constraint(equalToConstant: 50).isActive=true
        btnMyLocation.heightAnchor.constraint(equalTo: btnMyLocation.widthAnchor).isActive=true
        
        self.view.addSubview(btnMyDirect)
        btnMyDirect.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive=true
        btnMyDirect.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive=true
        btnMyDirect.widthAnchor.constraint(equalToConstant: 50).isActive=true
        btnMyDirect.heightAnchor.constraint(equalTo: btnMyDirect.widthAnchor).isActive=true
        
        
        self.view.addSubview(btnRandomNearbyPlaces)
        btnRandomNearbyPlaces.bottomAnchor.constraint(equalTo: btnMyDirect.topAnchor, constant: -10).isActive=true
        btnRandomNearbyPlaces.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive=true
        btnRandomNearbyPlaces.widthAnchor.constraint(equalToConstant: 50).isActive=true
        btnRandomNearbyPlaces.heightAnchor.constraint(equalTo: btnMyDirect.widthAnchor).isActive=true
        
    }
    
    
    //MARK: - Main Views
    
    let btnMyLocation: UIButton = {
        let btn=UIButton()
        btn.backgroundColor = UIColor.white
        btn.setImage(#imageLiteral(resourceName: "gps-fixed-indicator-6 "), for: .normal)
        btn.layer.cornerRadius = 25
        btn.clipsToBounds=true
        btn.tintColor = UIColor.gray
        btn.imageView?.tintColor=UIColor.gray
        btn.addTarget(self, action: #selector(btnMyLocationAction), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints=false
        return btn
    }()
    
    let btnMyDirect: UIButton = {
        let btn=UIButton()
        btn.backgroundColor = UIColor.white
        btn.setImage(#imageLiteral(resourceName: "images"), for: .normal)
        btn.layer.cornerRadius = 25
        btn.clipsToBounds=true
        btn.tintColor = UIColor.gray
        btn.imageView?.tintColor=UIColor.gray
        btn.addTarget(self, action: #selector(btnMyDirectAction), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints=false
        return btn
    }()
    
    
    var myMapView: GMSMapView = {
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
        
        mapView.translatesAutoresizingMaskIntoConstraints=false
        return mapView
    }()
    
    let segmentControl:UISegmentedControl={
        let sc=UISegmentedControl(frame: .zero)
        sc.backgroundColor = UIColor.white
        sc.clipsToBounds=true
        
        
        sc.translatesAutoresizingMaskIntoConstraints=false
        sc.insertSegment(withTitle: "Banks", at: 0, animated: true)
        sc.insertSegment(withTitle: "librarys", at: 1, animated: true)
        sc.insertSegment(withTitle: "mosques", at: 2, animated: true)
        sc.tintColor = UIColor.gray
        sc.addTarget(self, action: #selector(segmentChange), for: .valueChanged)
        return sc
    }()
    
    let btnRandomNearbyPlaces: UIButton = {
        let btn=UIButton()
        btn.backgroundColor = UIColor.white
        btn.setImage(#imageLiteral(resourceName: "icon_png"), for: .normal)
        btn.layer.cornerRadius = 25
        btn.clipsToBounds=true
        btn.tintColor = UIColor.gray
        btn.imageView?.tintColor=UIColor.gray
        btn.addTarget(self, action: #selector(showPartyMarkers), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints=false
        return btn
    }()
    
    //MARK: - Views' target actions
    
    @objc func showPartyMarkers() {
        
                myMapView.clear()
                randomNearbyPlaces.removeAll()
        
                for i in 0..<10 {
                    let randNum=Int(arc4random_uniform(UInt32(allNearbyPlaces.count)))
                    let marker=GMSMarker()
                    let nearbyPlace=allNearbyPlaces[randNum]
                    if var image=UIImage(named: "icon_png"){
                    if nearbyPlace.type=="bank"{
                        image=#imageLiteral(resourceName: "fotomurales-signo-de-dolar-de-oro-en-blanco.jpg")
                    }else if nearbyPlace.type=="mosque"{
                        image=#imageLiteral(resourceName: "240_F_155730985_zmUoiLCMciRtuq9cAj3H5FPv0enFvRql")
                    }else if nearbyPlace.type=="library"{
                        image=#imageLiteral(resourceName: "101178981-burn-book-logo-icon-design")
                    }
                        let customMarker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: customMarkerWidth, height: customMarkerHeight), image: image, borderColor: UIColor.darkGray, tag: i)
                        marker.iconView=customMarker
                    }
                        randomNearbyPlaces.append(nearbyPlace)
                        marker.position = CLLocationCoordinate2D(latitude: nearbyPlace.latitude, longitude: nearbyPlace.longitude)
                        marker.map = self.myMapView
                    if i==10{
                        myMapView.isMyLocationEnabled=true
                        myMapView.settings.myLocationButton=true
                    }
                }
            }
    
   
    @objc func btnMyDirectAction(){
        if let location=location
        {
//            for nearbyLocation in randomNearbyPlaces{
//            let nearbyCoordinates=CLLocationCoordinate2D(latitude: nearbyLocation.latitude,
//                                                             longitude: nearbyLocation.longitude)
             let nearbyCoordinates=CLLocationCoordinate2D(latitude: 51.5089927,
                                                         longitude: -0.1375314)
                getPolylineRoute(from: location.coordinate, to: nearbyCoordinates)
         }
    }
    
    @objc func segmentChange(_ sender:UISegmentedControl){
        if let location = location {
            let url=self.nearbyPlacesURL(for: location, from: 5000)
            performNearbyPlacesSearch(url: url, for: location, from: 5000)
        }
    }
}

