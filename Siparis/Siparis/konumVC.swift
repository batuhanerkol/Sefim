//
//  konumVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 3.09.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import MapKit
import Parse

class konumVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var isletmeTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    var menager = CLLocationManager()
    
    var chosenLatitude = ""
    var chosenLongitude = ""
    var chosenLatitudeArray = [String]()
    var chosenLongitudeArray = [String]()
    
    var manager = CLLocationManager()
    var requestCLLocation = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        menager.delegate = self
        menager.desiredAccuracy = kCLLocationAccuracyBest
        menager.requestWhenInUseAuthorization()
        menager.startUpdatingLocation()
        
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(konumVC.chooseLocation(gestureRecognizer:)))
        recognizer.minimumPressDuration = 3
        mapView.addGestureRecognizer(recognizer)
        
        getLocationData()
        
            }
 
    
    override func viewWillAppear(_ animated: Bool) {
     
        getLocationData()
    }
    
    
    @objc func chooseLocation(gestureRecognizer: UIGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began{
            let touches = gestureRecognizer.location(in: self.mapView)
            let coordinates = self.mapView.convert(touches, toCoordinateFrom: self.mapView)
            let annotation =  MKPointAnnotation()
            annotation.coordinate = coordinates
            annotation.title = isletmeTextField.text!
            self.mapView.addAnnotation(annotation)
            self.chosenLatitude = String(coordinates.latitude)
            self.chosenLongitude = String(coordinates.longitude)
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.009, longitudeDelta: 0.009)
        let region = MKCoordinateRegion(center: location, span: span);  mapView.setRegion(region, animated: true)
        
        
        
        if self.chosenLongitude != "" && self.chosenLatitude != ""{
            let location = CLLocationCoordinate2D(latitude: Double(self.chosenLatitude)!, longitude: Double(self.chosenLongitude)!)
            
            let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            let region = MKCoordinateRegion(center: location, span: span)
            
            self.mapView.setRegion(region, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = isletmeTextField.text!
            self.mapView.addAnnotation(annotation)
        }
        
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        let object = PFObject(className: "Locations")
        object["businessName"] = isletmeTextField.text!
        object["businessLocationOwner"] = PFUser.current()!.username!
        object["latitude"] = self.chosenLatitude
        object["longitude"] = self.chosenLongitude
        
        object.saveInBackground { (success, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                print("success")
            }
        }
    }
    
    func getLocationData(){
        let query = PFQuery(className: "Locations")
          query.whereKey("businessLocationOwner", equalTo: "\(PFUser.current()!.username!)")
        
        
        query.findObjectsInBackground { (objects, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                self.chosenLatitudeArray.removeAll(keepingCapacity: false)
                self.chosenLongitudeArray.removeAll(keepingCapacity: false)
                
                for object in objects!{
                    self.chosenLatitudeArray.append(object.object(forKey: "latitude") as! String)
                    self.chosenLongitudeArray.append(object.object(forKey: "longitude") as! String)
                    
                    self.latitudeLabel.text = "\(self.chosenLatitudeArray.last!)"
                    self.longitudeLabel.text = "\(self.chosenLongitudeArray.last!)"
                    self.manager.startUpdatingLocation()
                }
                
            }
        }
    }
}
