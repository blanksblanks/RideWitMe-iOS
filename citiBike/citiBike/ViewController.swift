//
//  ViewController.swift
//  citiBike
//
//  Created by 吴梦宇 on 12/5/15.
//  Copyright (c) 2015 ___mengyu wu___. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate, MGLMapViewDelegate {

    var theMap: MGLMapView!
    private var myLocations = [CLLocation]()
    private var currentPositionAnnotation = MGLPointAnnotation()
    private var currentLocation = CLLocation()
    private var polylineAnnotation = MGLPointAnnotation()
    private var isFirstMessage = true
    var manager:CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        //Setup our location Manager
        manager = CLLocationManager()
        manager.delegate=self
        manager.desiredAccuracy=kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
       
        
        // Do any additional setup after loading the view, typically from a nib.
        //initalize the map view
        theMap=MGLMapView(frame: view.bounds)
        theMap.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        
        // set the map's center coordinate
        theMap.setCenterCoordinate(CLLocationCoordinate2D(latitude: 40.7326808,
            longitude: -73.9843407),
            zoomLevel: 12, animated: false)
        theMap.delegate=self
        theMap.showsUserLocation=true
        view.addSubview(theMap)
    }
    
    
    
    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[AnyObject]) {
        
        myLocations.append(locations[0] as! CLLocation)
       
        let spanX = 0.007
        let spanY = 0.007
//        var newRegion = MKCoordinateRegion(center: theMap.userLocation.coordinate, span: MKCoordinateSpanMake(spanX, spanY))
//        theMap.setRegion(newRegion, animated: true)
        
        if (myLocations.count > 1){
            var sourceIndex = myLocations.count - 1
            var destinationIndex = myLocations.count - 2
            
            let c1 = myLocations[sourceIndex].coordinate
            let c2 = myLocations[destinationIndex].coordinate
            var a = [c1, c2]
            
            self.currentLocation=myLocations[destinationIndex]
            
            var polyline = MGLPolyline(coordinates: &a, count: UInt(a.count))
            theMap.addAnnotation(polyline)
            self.updateMapFrame()
            
        }
    }
    
    
    func updateMapFrame() {
        self.theMap.centerCoordinate = self.currentLocation.coordinate
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

