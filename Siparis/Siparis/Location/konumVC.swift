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
    
    var manager = CLLocationManager()
    var requestCLLocation = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        mapView.delegate = self
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        
        self.navigationItem.hidesBackButton = true
        
            }
    override func viewWillAppear(_ animated: Bool) {
             self.addButton.isHidden = true
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getLocationData()
    }
    
    @IBAction func AddLocationPressed(_ sender: Any) {

            performSegue(withIdentifier: "konumVCToAddLocationVC", sender: nil)
    }
    @IBAction func cleanButtonPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "EMİN MİSİNİZ ?", message: "Eğer Bilgilerinizi Sıfırlarsanız Bütün Bilgilerinizi En Baştan Girmeniz Gerekir (Menü, Logo vb.)", preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "Evet", style: UIAlertActionStyle.default) {
            UIAlertAction in
            
            self.addButton.isHidden = false
            self.deleteData()
            
        }
        let cancelAction = UIAlertAction(title: "Hayır", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
        }
        
        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
        
       
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
             self.manager.stopUpdatingLocation()
        }
         self.manager.stopUpdatingLocation()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView?.canShowCallout = true
            let button = UIButton(type:  .detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        }
            else{
                pinView?.annotation = annotation
            }

        return pinView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if self.chosenLatitude != "" && self.chosenLongitude != "" {
            self.requestCLLocation = CLLocation(latitude: Double(self.chosenLatitude)!, longitude: Double(self.chosenLongitude)!)

            CLGeocoder().reverseGeocodeLocation(requestCLLocation) { (placemarks, error)in
                if let placemark = placemarks {
                    if placemark.count > 0 {
                        let mkPlacemark = MKPlacemark(placemark: placemark[0])
                        let mapItem = MKMapItem(placemark: mkPlacemark)
                        mapItem.name = self.chosenbusinessArray.last!
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                        mapItem.openInMaps(launchOptions : launchOptions)
                    }
                }
            }
    }
    }

    func getLocationData(){
        
        let query = PFQuery(className: "BusinessInformation")
          query.whereKey("businessUserName", equalTo: "\(PFUser.current()!.username!)")
       
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
                self.chosenbusinessArray.removeAll(keepingCapacity: false)
                
                for object in objects!{
                    self.chosenLatitudeArray.append(object.object(forKey: "latitude") as! String)
                    self.chosenLongitudeArray.append(object.object(forKey: "longitude") as! String)
                    self.chosenbusinessArray.append(object.object(forKey: "businessName") as! String)
                    
                    
                    self.chosenLatitude = self.chosenLatitudeArray.last!
                    self.chosenLongitude = self.chosenLongitudeArray.last!
                    self.selectedName = self.chosenbusinessArray.last!
                    
                   
                
                    self.latitudeLabel.text = "\(self.chosenLatitudeArray.last!)"
                    self.longitudeLabel.text = "\(self.chosenLongitudeArray.last!)"
                    self.businessNameLabel.text = "\(self.chosenbusinessArray.last!)"
                    
                     self.manager.startUpdatingLocation()
                    
                    
                }
                
            }
        }
        
    }
    
    func deleteData(){
        let query = PFQuery(className: "BusinessInformation")
        query.whereKey("businessUserName", equalTo: "\(PFUser.current()!.username!)")
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
                self.chosenbusinessArray.removeAll(keepingCapacity: false)
                for object in objects! {
                    object.deleteInBackground()
                    
                    self.longitudeLabel.text = ""
                    self.latitudeLabel.text = ""
                    self.businessNameLabel.text = ""
                    
                    let annotation = MKPointAnnotation()
                     self.mapView.removeAnnotation(annotation)
                }
                
            }
        }
    }
    
  
    
    
    }

