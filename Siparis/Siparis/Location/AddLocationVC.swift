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

class AddLocationVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate,UITextFieldDelegate {
    
    var chosenBusiness = ""
    var chosenLatitude = ""
    var chosenLongitude = ""
    
    var chosenLatitudeDouble:Double = 0
    var chosenLongitudeDouble:Double = 0
    
    var chosenLatitudeArray = [String]()
    var chosenLongitudeArray = [String]()
    
    var manager = CLLocationManager()
    var requestCLLocation = CLLocation()

    @IBOutlet weak var businessNameTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.businessNameTextField.delegate = self

        mapView.delegate = self
        self.manager.delegate = self
        self.manager.desiredAccuracy = kCLLocationAccuracyBest
        self.manager.requestWhenInUseAuthorization()
        self.manager.startUpdatingLocation()
        
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(AddLocationVC.chooseLocation(gestureRecognizer:)))
        recognizer.minimumPressDuration = 1.5
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
            
            self.chosenLongitudeDouble = coordinates.longitude
            self.chosenLatitudeDouble = coordinates.latitude
            
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
            self.performSegue(withIdentifier: "addLocationVCToKonumVC", sender: nil)
        }
        else{
            let alert = UIAlertController(title: "HATA", message: "Lütfen İşletme İsmi Giriniz", preferredStyle: UIAlertControllerStyle.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func saveLocation(){
        let actualLocation = PFGeoPoint(latitude:self.chosenLatitudeDouble,longitude:self.chosenLongitudeDouble)
        let object = PFObject(className: "BusinessInformation")
        
        object["businessUserName"] = PFUser.current()!.username!
        object["latitude"] = self.chosenLatitude
        object["longitude"] = self.chosenLongitude
        object["Lokasyon"] = actualLocation
        object["businessName"] = businessNameTextField.text!
        object["LezzetPuan"] = ""
        object["HizmetPuan"] = ""
        
        object.saveInBackground { (success, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
             
            }
        }
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
  
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: -250, up: true)
    }
    
    // Finish Editing The Text Field
    func textFieldDidEndEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: -250, up: false)
    }
    
    // Hide the keyboard when the return key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Move the text field in a pretty animation!
    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
}
