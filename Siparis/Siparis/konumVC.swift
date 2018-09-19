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

var globalBusinessName = ""
class konumVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var isletmeTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    var menager = CLLocationManager()
    
    var selectedPlace = ""
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
        
        getLocationData()
        
            }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        if self.chosenLongitude != "" && self.chosenLatitude != ""{
            let location = CLLocationCoordinate2D(latitude: Double(self.chosenLatitude)!, longitude: Double(self.chosenLongitude)!)
            
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location, span: span)
            
            self.mapView.setRegion(region, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = isletmeTextField.text!
            self.mapView.addAnnotation(annotation)
        }
        
    }
    
    @IBAction func AddLocationPressed(_ sender: Any) {
            performSegue(withIdentifier: "konumVCToAddLocationVC", sender: nil)
        globalBusinessName = isletmeTextField.text!
    }
    
    func getLocationData(){
        
        let query = PFQuery(className: "Locations")
          query.whereKey("businessLocationOwner", equalTo: "\(PFUser.current()!.username!)")
        query.whereKey("businessName", equalTo: selectedPlace)
        
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
                  
                    self.menager.startUpdatingLocation()

                    self.latitudeLabel.text = "\(self.chosenLatitudeArray.last!)"
                    self.longitudeLabel.text = "\(self.chosenLongitudeArray.last!)"
                    self.manager.startUpdatingLocation()
                }
                
            }
        }
    }
}
