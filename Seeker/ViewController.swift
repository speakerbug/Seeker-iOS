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
    @IBOutlet weak var stateLabel: UIImageView!
    @IBOutlet weak var vignette: UIImageView!
    @IBOutlet weak var scratches: UIImageView!
    let locManager = CLLocationManager()
    var userName = ""
    var isTagged = false
    var seekers = [Seeker]()
    var currentLocation = CLLocation(latitude: 0, longitude: 0)
    var timer:NSTimer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let aSelector : Selector = "refresh"
        timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: aSelector, userInfo: nil, repeats: true)
        
//        self.navigationController?.navigationBar.barTintColor = UIColor(red: 41/255, green: 40/255, blue: 38/255, alpha: 1)
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as [NSObject : AnyObject]
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        // Core Location Manager asks for GPS location
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locManager.requestAlwaysAuthorization()
        locManager.startMonitoringSignificantLocationChanges()
        locManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
        mapView.delegate = self
    }
    
    func mapView (mapView: MKMapView!,
        viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
            
            var pinView:MKPinAnnotationView = MKPinAnnotationView()
            pinView.annotation = annotation
            if (annotation.title! == "Current Location") {
                pinView.image = UIImage(named:"user_dot")
                //Set image below for the current user
//                if isTagged {
//                    pinView.image = UIImage(named:"self_zombie_icon")
//                } else {
//                    pinView.image = UIImage(named:"self_human_icon")
//                }
            } else if annotation.title! == "Tagger" {
                //set image below for zombies
                pinView.image = UIImage(named:"zombie_icon")
            } else {
                //set image below for humans
                pinView.image = UIImage(named:"human_icon")
            }
            //pinView.animatesDrop = true
            //pinView.canShowCallout = true
            return pinView
    }
    
    func mapView(mapView: MKMapView!,
        didSelectAnnotationView view: MKAnnotationView!){
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locManager.stopUpdatingLocation()
        if ((error) != nil) {
            print(error)
        }
    }
    
    func getCurrentLocation() -> CLLocation {
        return currentLocation
    }
    
    func putPinOnMap(coordinates:CLLocationCoordinate2D, player: Seeker) {
        
        var pointAnnotation:MKPointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = coordinates
        if player.isTagged{
            pointAnnotation.title = "Tagger"
        } else {
            pointAnnotation.title = player.name
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
            
            let newLocation: CLLocation = CLLocation(latitude: player.lat, longitude: player.long)
            let distance = getCurrentLocation().distanceFromLocation(newLocation)
            
            if distance <= 30 && isTagged && !player.isTagged {
                
                println(currentLocation)
                println(distance)
                
                //give user ability to tag the close user
                let optionMenu = UIAlertController(title: nil, message: "You are close enough to tag \(player.name)", preferredStyle: .ActionSheet)
                let tagAction = UIAlertAction(title: "Tag them!", style: .Default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    println("Just tagged \(player.name)")
                    self.tag(player)
                    
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
                    (alert: UIAlertAction!) -> Void in
                    println("Cancelled tag")
                })
                optionMenu.addAction(tagAction)
                optionMenu.addAction(cancelAction)
                
                optionMenu.popoverPresentationController?.sourceView = mapView
                
                self.presentViewController(optionMenu, animated: true, completion: nil)
                
            }
            
        }
    }
    
    func updateLocationInAPI(coordinates:CLLocationCoordinate2D) {
        
        currentLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        
        Alamofire.request(.POST, "http://seeker.henrysaniuk.com:9002/api/user/\(AuthenticationManager.sharedManager.userID)/location?longitude=\(coordinates.longitude)&latitude=\(coordinates.latitude)", parameters: ["get":true]).responseJSON { (_, _, data, _) in
        }
    }
    
    @IBAction func refreshPinsButton(sender: AnyObject) {
        refresh()
    }
    
    func refresh() {
        refreshPins()
        getSelf()
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
    
    func getSelf() {
        
        if AuthenticationManager.sharedManager.userIsLoggedIn {
            Alamofire.request(.GET, "http://seeker.henrysaniuk.com:9002/api/user/\(AuthenticationManager.sharedManager.userID)/get", parameters: ["get":true]).responseJSON { (_, _, data, _) in
                let json = JSON(data!)
                self.userName = json["Name"].stringValue
                self.isTagged = json["isTagged"].boolValue
                println(self.isTagged)
                if json["isTagged"].boolValue {
//                    self.title = "You're it!"
                    UIView.animateWithDuration(0.7, animations: {
                        self.vignette.alpha = 1
                        self.scratches.alpha = 0.9
                        self.stateLabel.image = UIImage(named:"infected")
                    })
                } else {
//                    self.title = "Don't get tagged!"
                    UIView.animateWithDuration(0.7, animations: {
                        self.vignette.alpha = 0
                        self.scratches.alpha = 0.65
                        self.stateLabel.image = UIImage(named:"survivor")
                    })
                }
            }
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if !AuthenticationManager.sharedManager.userIsLoggedIn {
            self.performSegueWithIdentifier("showLogin", sender: self)
        } else {
            getSelf()
        }
    }
    
    func tag(player: Seeker){
        Alamofire.request(.POST, "http://seeker.henrysaniuk.com:9002/api/user/\(player.id)/tag", parameters: ["get":true]).responseJSON { (_, _, data, _) in
        }
    }
}

