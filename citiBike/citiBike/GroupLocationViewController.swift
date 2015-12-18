//
//  GroupLocationViewController.swift
//  citiBike
//
//  Created by 吴梦宇 on 12/17/15.
//  Copyright (c) 2015 ___mengyu wu___. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class GroupLocationViewController: UIViewController, CLLocationManagerDelegate, MGLMapViewDelegate{
    
    var groupLocationInfo:DDBTableRow?
    
    var mapView: MGLMapView!
    
    var corrdinats:[CLLocationCoordinate2D]=[]
    
    var timer = NSTimer()
    
    func updateLocation()
    {
        NSLog("hello World")
    }
    
    override func viewWillAppear(animated: Bool) {
        self.corrdinats.removeAll(keepCapacity: false)
        timer=NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "updateLocation", userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        timer.invalidate()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        var center=CLLocationCoordinate2D(latitude: 40.7326808,longitude: -73.9843407)
        var lat:Double = 40.7326808
        var log:Double = -73.9843407
        
        // Do any additional setup after loading the view.
        if var info=groupLocationInfo{
            println(self.groupLocationInfo?.GroupId)
            lat = Double(info.Lat!)
            log = Double(info.Log!)
            
            center=CLLocationCoordinate2D(latitude: lat,longitude: log)
            // Declare the annotation `point` and set its coordinates, title, and subtitle
        }
        
        
        
        // initialize the map view
        mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        
        // set the map's center coordinate
        
        mapView.setCenterCoordinate(center,
            zoomLevel: 15, animated: false)
        
        view.addSubview(mapView)
        
        mapView.delegate=self
        let point = MGLPointAnnotation()
        point.coordinate = center
        point.title = groupLocationInfo?.GroupTitle ?? ""
        var latLabel = round(lat*100)/100
        var logLabel = round(log*100)/100
        point.subtitle="\(latLabel) \(logLabel)"
        
        
        // Add annotation `point` to the map
        mapView.addAnnotation(point)
        corrdinats.append(center)
     
    }
    
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
