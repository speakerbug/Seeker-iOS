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
        
    }
    
    func mapView (mapView: MKMapView!,
        viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
            
            if !(annotation is MKPointAnnotation)
            {
                return nil
            }
            
            let reuseId = "test"
            
            var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            
            if anView == nil
            {
                anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                anView.image = UIImage(named:"pin")
                anView.canShowCallout = true
            }
            else
            {
                anView.annotation = annotation
            }
            
            return anView
            
//            var pinView:MKPinAnnotationView = MKPinAnnotationView()
//            pinView.annotation = annotation
//            pinView.pinColor = MKPinAnnotationColor.Red
//            pinView.animatesDrop = true
//            pinView.canShowCallout = true
//            
//            return pinView
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
    
    func putPinOnMap(coordinates:CLLocationCoordinate2D) {
        
        var pointAnnotation:MKPointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = coordinates
        pointAnnotation.title = userName
        
        self.mapView?.addAnnotation(pointAnnotation)
        self.mapView?.centerCoordinate = coordinates
        self.mapView?.selectAnnotation(pointAnnotation, animated: true)
        
    }
    
    func removeAllPins() {
        let annotationsToRemove = mapView.annotations.filter { $0 !== self.mapView.userLocation }
        mapView.removeAnnotations( annotationsToRemove )
    }
    
    func updateLocationInAPI(coordinates:CLLocationCoordinate2D) {
        Alamofire.request(.POST, "http://seeker.henrysaniuk.com:9002/api/user/\(AuthenticationManager.sharedManager.userID)/location?longitude=\(coordinates.longitude)&latitude=\(coordinates.latitude)", parameters: ["get":true]).responseJSON { (_, _, data, _) in
            
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locationArray = locations as NSArray
        var locationObj = locationArray.lastObject as! CLLocation
        var coord = locationObj.coordinate
        
        // Check if the user allowed authorization
        if   (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways)
        {
//            removeAllPins()
//            updateLocationInAPI(manager.location.coordinate)
//            putPinOnMap(manager.location.coordinate)
            mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
            
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
                
                var span = MKCoordinateSpanMake(0.075, 0.075)
                var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: json["Location"]["Lat"].doubleValue, longitude: json["Location"]["Long"].doubleValue), span: span)
                self.mapView.setRegion(region, animated: true)
                
                println(json)
            }
        }
    }
    
}

