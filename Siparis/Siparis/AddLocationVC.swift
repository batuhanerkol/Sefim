//
//  AddLocationVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 19.09.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import MapKit
import Parse
import CoreLocation

class AddLocationVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var chosenBusiness = ""
    var chosenLatitude = ""
    var chosenLongitude = ""
    
    var chosenLatitudeArray = [String]()
    var chosenLongitudeArray = [String]()
    
    var manager = CLLocationManager()
    var requestCLLocation = CLLocation()

  
    @IBOutlet weak var businessNameTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        self.manager.delegate = self
        self.manager.desiredAccuracy = kCLLocationAccuracyBest
        self.manager.requestWhenInUseAuthorization()
        self.manager.startUpdatingLocation()
        
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(AddLocationVC.chooseLocation(gestureRecognizer:)))
        recognizer.minimumPressDuration = 2
        mapView.addGestureRecognizer(recognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.chosenLatitude = ""
        self.chosenLongitude = ""
    }
    
    @objc func chooseLocation(gestureRecognizer: UIGestureRecognizer){
        
        if gestureRecognizer.state == UIGestureRecognizerState.began{
            
            let touches = gestureRecognizer.location(in: self.mapView)
            let coordinates = self.mapView.convert(touches, toCoordinateFrom: self.mapView)
            
            let annotation =  MKPointAnnotation()
            annotation.coordinate = coordinates
            annotation.title = businessNameTextField.text!
            
            self.mapView.addAnnotation(annotation)
            self.chosenLatitude = String(coordinates.latitude)
            self.chosenLongitude = String(coordinates.longitude)
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)

        let span = MKCoordinateSpan(latitudeDelta: 0.009, longitudeDelta: 0.009)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        self.mapView.showsUserLocation = true
        
         self.manager.stopUpdatingLocation()
    }
    
    @IBAction func addButtonClicked(_ sender: Any) {
        if businessNameTextField.text != "" {
       saveLocation()
        }
        else{
            let alert = UIAlertController(title: "HATA", message: "Lütfen İşletme İsmi Giriniz", preferredStyle: UIAlertControllerStyle.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
        self.performSegue(withIdentifier: "addLocationVCToKonumVC", sender: nil)
    }
    
    func saveLocation(){
        
        let object = PFObject(className: "Locations")
        
        object["businessLocationOwner"] = PFUser.current()!.username!
        object["latitude"] = self.chosenLatitude
        object["longitude"] = self.chosenLongitude
        object["businessName"] = businessNameTextField.text!
        
        object.saveInBackground { (success, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                print("Location success")
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
