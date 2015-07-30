//
//  ViewController.swift
//  Seeker
//
//  Created by Henry Saniuk on 7/29/15.
//  Copyright (c) 2015 Henry Saniuk. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    let locManager = CLLocationManager()
    var userName = ""
    var seekers = [Seeker]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 41/255, green: 40/255, blue: 38/255, alpha: 1)
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as [NSObject : AnyObject]
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        // Core Location Manager asks for GPS location
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestAlwaysAuthorization()
        locManager.startMonitoringSignificantLocationChanges()
        locManager.startUpdatingLocation()
        mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
    }
    
    func mapView (mapView: MKMapView!,
        viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
            
            var pinView:MKPinAnnotationView = MKPinAnnotationView()
            pinView.annotation = annotation
            pinView.pinColor = MKPinAnnotationColor.Red
            pinView.animatesDrop = true
            pinView.canShowCallout = true
            
            return pinView
    }
    
    func mapView(mapView: MKMapView!,
        didSelectAnnotationView view: MKAnnotationView!){
            
            println("Selected annotation")
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locManager.stopUpdatingLocation()
        if ((error) != nil) {
            print(error)
        }
    }
    
    func putPinOnMap(coordinates:CLLocationCoordinate2D, player: Seeker) {
        
        var pointAnnotation:MKPointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = coordinates
        if player.isTagged{
            pointAnnotation.title = "It"
        }
        self.mapView?.addAnnotation(pointAnnotation)
        //self.mapView?.centerCoordinate = coordinates
        self.mapView?.selectAnnotation(pointAnnotation, animated: true)
        
    }
    
    func removeAllPins() {
        let annotationsToRemove = mapView.annotations.filter { $0 !== self.mapView.userLocation }
        mapView.removeAnnotations( annotationsToRemove )
    }
    
    func placeAllPins() {
        for player in seekers {
            var coordinates = CLLocationCoordinate2D(latitude: player.lat as
                CLLocationDegrees, longitude: player.long as CLLocationDegrees)
            putPinOnMap(coordinates, player: player)
        }
    }
    
    func updateLocationInAPI(coordinates:CLLocationCoordinate2D) {
        Alamofire.request(.POST, "http://seeker.henrysaniuk.com:9002/api/user/\(AuthenticationManager.sharedManager.userID)/location?longitude=\(coordinates.longitude)&latitude=\(coordinates.latitude)", parameters: ["get":true]).responseJSON { (_, _, data, _) in
        }
    }
    
    @IBAction func refreshPinsButton(sender: AnyObject) {
        refreshPins()
    }
    
    func refreshPins() {
        Alamofire.request(.GET, "http://seeker.henrysaniuk.com:9002/api/user/\(AuthenticationManager.sharedManager.userID)/others", parameters: ["get":true]).responseJSON { (_, _, data, _) in
            if let data: AnyObject = data {
                let json = JSON(data)
                let array = json.arrayValue
                self.seekers = array.map {
                    Seeker(json: $0)
                }
                self.removeAllPins()
                self.placeAllPins()
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locationArray = locations as NSArray
        var locationObj = locationArray.lastObject as! CLLocation
        var coord = locationObj.coordinate
        
        // Check if the user allowed authorization
        if   (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways)
        {
            updateLocationInAPI(manager.location.coordinate)
        }  else {
            println("Not authorized")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        if !AuthenticationManager.sharedManager.userIsLoggedIn {
            self.performSegueWithIdentifier("showLogin", sender: self)
        } else {
            Alamofire.request(.GET, "http://seeker.henrysaniuk.com:9002/api/user/\(AuthenticationManager.sharedManager.userID)/get", parameters: ["get":true]).responseJSON { (_, _, data, _) in
                let json = JSON(data!)
                self.userName = json["Name"].stringValue
                if json["isTagged"].boolValue {
                    self.title = "You're it!"
                } else {
                    self.title = "Don't get tagged!"
                }
                println(json)
                
            }
        }
    }
    
}

