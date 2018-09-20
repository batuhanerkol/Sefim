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
   
    var selectedName = ""
    var chosenLatitude = ""
    var chosenLongitude = ""
    
    @IBOutlet weak var businessNameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var chosenbusinessArray = [String]()
    var chosenLatitudeArray = [String]()
    var chosenLongitudeArray = [String]()
    
     var menager = CLLocationManager()
    var manager = CLLocationManager()
    var requestCLLocation = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        menager.delegate = self
        menager.desiredAccuracy = kCLLocationAccuracyBest
        menager.requestWhenInUseAuthorization()
        
        self.navigationItem.hidesBackButton = true
        
          getBusinessName()
         getLocationData()
      

            }
    override func viewWillAppear(_ animated: Bool) {
             self.addButton.isHidden = true
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if self.chosenLongitude != "" && self.chosenLatitude != ""{
            let location = CLLocationCoordinate2D(latitude: Double(self.chosenLatitude)!, longitude: Double(self.chosenLongitude)!)
            
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location, span: span)
            
            self.mapView.setRegion(region, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
           annotation.title = self.chosenbusinessArray.last
            self.mapView.addAnnotation(annotation)
        }
        
    }
    
    @IBAction func AddLocationPressed(_ sender: Any) {

            performSegue(withIdentifier: "konumVCToAddLocationVC", sender: nil)
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
             
                    
                    
                    self.chosenLatitude = self.chosenLatitudeArray.last!
                    self.chosenLongitude = self.chosenLongitudeArray.last!
                    self.manager.startUpdatingLocation()
                    
                    self.latitudeLabel.text = "\(self.chosenLatitudeArray.last!)"
                    self.longitudeLabel.text = "\(self.chosenLongitudeArray.last!)"
                    
                }
                
            }
        }
    }
    
    
    func getBusinessName(){
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
                self.chosenbusinessArray.removeAll(keepingCapacity: false)
                
                
                for object in objects!{
                    self.chosenbusinessArray.append(object.object(forKey: "businessName") as! String)
                    
                    
                    self.selectedName = self.chosenbusinessArray.last!
                    self.manager.startUpdatingLocation()
                    self.businessNameLabel.text = "\(self.chosenbusinessArray.last!)"
                }
                
            }
        }
    }
    
    func deleteData(){
        let query = PFQuery(className: "Locations")
        query.whereKey("businessLocationOwner", equalTo: "\(PFUser.current()!.username!)")
        query.findObjectsInBackground { (objects, error) in
            
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else {
                self.chosenLatitudeArray.removeAll(keepingCapacity: false)
                self.chosenLongitudeArray.removeAll(keepingCapacity: false)
                for object in objects! {
                    object.deleteInBackground()
                    
                    self.longitudeLabel.text = ""
                    self.latitudeLabel.text = ""
                    self.businessNameLabel.text = ""
                }
                
            }
        }
    }
    
    @IBAction func cleanButtonPressed(_ sender: Any) {
        self.addButton.isHidden = false
        deleteData()
    }
    
    
    }

