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
    var label = UILabel(frame: CGRectMake(0, 0, 300, 21))
    
    var groupTitleField: UITextField?
    var passwordField:UITextField?
    var locationInfo:DDBTableRow?
    
    //share location button
    @IBAction func shareLocation(sender: AnyObject) {
        println("share my location button pressed")
        let alert = UIAlertController(title: "Share Location", message: "Create A Group", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler(groupNameTextField)
        alert.addTextFieldWithConfigurationHandler(passwordTextField)
        // Create the actions
    
        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            NSLog("OK Pressed")
            
            if let title=self.groupTitleField?.text{
              self.createGroup(title, password: self.passwordField?.text)
            }else{
                println("Please enter group name!")
            }
           
           
        }
        var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        
        // Add the actions
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func createGroup(groupTitle:String, password:String?){
        var groupTableRow=DDBTableRow()
        groupTableRow!.GroupTitle=groupTitle
        groupTableRow!.GroupId = groupTitle
        if let pwd=password{
            groupTableRow!.Password=pwd
        }else{
            groupTableRow!.Password=""
        }
        self.insertTableRow(groupTableRow!)
    }
    
    
    func insertTableRow(tableRow: DDBTableRow) {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        
        dynamoDBObjectMapper.save(tableRow) .continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
            if (task.error == nil) {
                let alertController = UIAlertController(title: "Succeeded", message: "Successfully inserted the data into the table.", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel) { UIAlertAction-> Void in
                }
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                self.locationInfo=tableRow
                
            } else {
                print("Error: \(task.error)")
                
                let alertController = UIAlertController(title: "Failed to insert the data into the table.", message: task.error.description, preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel){ UIAlertAction -> Void in
                }
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            
            return nil
        })
    }
    
    func updateLocation(tableRow: DDBTableRow, lat:Double, log:Double){
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        println("update group:\(tableRow.GroupId)")
        tableRow.Lat=lat
        tableRow.Log=log
        
        dynamoDBObjectMapper .save(tableRow) .continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
            if (task.error == nil) {
                println("update Success")
              
            } else {
                print("Error: \(task.error)")
                
                let alertController = UIAlertController(title: "Failed to update the data into the table.", message: task.error.description, preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel){UIAlertAction -> Void in
                }
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            
            return nil
        })

    }

    
    
    func groupNameTextField(textField: UITextField!){
        // add the text field and make the result global
        textField.placeholder = "GroupName"
        groupTitleField=textField
        
    }
    
    func passwordTextField(textField: UITextField!){
        // add the text field and make the result global
        textField.placeholder = "Password"
        passwordField=textField
        
    }
    
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
        myLocations.removeAll(keepCapacity: false)
        theMap=MGLMapView(frame: view.bounds)
        theMap.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        
        // set the map's center coordinate
        theMap.setCenterCoordinate(CLLocationCoordinate2D(latitude: 40.7326808,
            longitude: -73.9843407),
            zoomLevel: 12, animated: false)
        theMap.delegate=self
        theMap.showsUserLocation=true
        
        
        label.center = CGPointMake(160, 300)
        label.textAlignment = NSTextAlignment.Center
        theMap.addSubview(label)
        view.addSubview(theMap)
        
        
    }
    
   
    
    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[AnyObject]) {
        
        
        myLocations.append(locations[0] as! CLLocation)
        
        if (myLocations.count > 1){
            var sourceIndex = myLocations.count - 1
            var destinationIndex = myLocations.count - 2
            
            let c1 = myLocations[sourceIndex].coordinate
            let c2 = myLocations[destinationIndex].coordinate
            var a = [c1, c2]
            
            self.currentLocation=myLocations[destinationIndex]
            println("\(self.currentLocation.coordinate.latitude)  \(self.currentLocation.coordinate.longitude)")
            var latLabel=Double(round(self.currentLocation.coordinate.latitude*100)/100)
            var logLabel=Double(round(self.currentLocation.coordinate.longitude*100)/100)
            var lat=Double(self.currentLocation.coordinate.latitude)
            var log=Double(self.currentLocation.coordinate.longitude)
            var speed=Int(self.currentLocation.speed)
            label.text="lat:\(latLabel) log:\(logLabel) speed:\(speed)"
            if let tableRow=self.locationInfo{
                 println("update location")
                 updateLocation(tableRow, lat:lat, log:log)
            }
           
            
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

