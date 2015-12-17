//
//  ViewController.swift
//  citiBike
//
//  Created by 吴梦宇 on 12/5/15.
//  Copyright (c) 2015 ___mengyu wu___. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MGLMapViewDelegate {

    var mapView: MGLMapView!
    var manager: CLLocationManager!

    private var myLocations = [CLLocation]()
    private var currentPositionAnnotation = MGLPointAnnotation()
    private var currentLocation = CLLocation()
    private var polylineAnnotation = MGLPointAnnotation()
    private var isFirstMessage = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        // Setup location manager
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        
        // Do additional setup after loading the view, typically from a nib.
        myLocations.removeAll(keepCapacity: false)
        mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        
        // Set the map's center coordinate to New York, New York
        mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: 40.7326808,
            longitude: -73.9843407),
            zoomLevel: 12, animated: false)
        
        // Set the delegate property of our map view to self after instantiating it
        mapView.delegate = self
        mapView.showsUserLocation = true
        view.addSubview(mapView)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations:[AnyObject]) {
        
        myLocations.append(locations[0] as! CLLocation)
        
        if (myLocations.count > 1) {
            var sourceIndex = myLocations.count - 1
            var destinationIndex = myLocations.count - 2
            
            let c1 = myLocations[sourceIndex].coordinate
            let c2 = myLocations[destinationIndex].coordinate
            var a = [c1, c2]
            
            self.currentLocation=myLocations[destinationIndex]
            
            var polyline = MGLPolyline(coordinates: &a, count: UInt(a.count))
            mapView.addAnnotation(polyline)
            self.updateMapFrame()
            
        }
    }
    
    func updateMapFrame() {
        self.mapView.centerCoordinate = self.currentLocation.coordinate
    }

    func mapView(mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        // Set the alpha for all shape annotations to 1 (full opacity)
        return 1
    }
    
    func mapView(mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        // Set the line width for polyline annotations
        return 3.0
    }
    
    func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        // Give our polyline a unique color by checking for its `title` property
        return UIColor.blueColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

