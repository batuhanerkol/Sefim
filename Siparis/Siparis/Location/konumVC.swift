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

var globalBusinessNameTextFieldKonumVC = ""

class konumVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
   
    var selectedName = ""
    var chosenLatitude = ""
    var chosenLongitude = ""
    var screenPassword = ""
    
    var objectIdArray = [String]()
    var objectId = ""
    
    var passwordTextField: UITextField?
    
    @IBOutlet weak var businessNameLabel: UILabel!
    @IBOutlet weak var deleteLocationButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    
    var chosenbusinessArray = [String]()
    var chosenLatitudeArray = [String]()
    var chosenLongitudeArray = [String]()
    
    var manager = CLLocationManager()
    var requestCLLocation = CLLocation()
    
     var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // interner kontrolü
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
        updateUserInterface()
      
        mapView.delegate = self
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        
        self.navigationItem.hidesBackButton = true
        
        
     
        // loading sembolu
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorView.Style.gray
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()

        
            }
    override func viewWillAppear(_ animated: Bool) {
        
        if businessNameLabel.text == ""{
            self.addButton.isHidden = false
        }else{
            self.addButton.isHidden = true
        }
        
        enteringPassword()
        updateUserInterface()
    }
    
  
    func updateUserInterface() {
        guard let status = Network.reachability?.status else { return }
        switch status {
        case .unreachable:
            let alert = UIAlertController(title: "İnternet Bağlantınız Bulunmuyor.", message: "Lütfen Kontrol Edin", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)

            
            self.addButton.isEnabled = false
            self.deleteLocationButton.isEnabled = false
    
        case .wifi:
          getLocationData()
              self.addButton.isEnabled = true
            self.deleteLocationButton.isEnabled = true
        case .wwan:
            getLocationData()
              self.addButton.isEnabled = true
            self.deleteLocationButton.isEnabled = true
        }
    }
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
    
    // işletme sahibi hariç kişiler diğer ekranlarda değişiklik yapmasın diye
    func enteringPassword(){
        
        let alertController = UIAlertController(title: "Şifre Girin", message: "", preferredStyle: .
            alert)
        let action = UIAlertAction(title: "Tamam", style: .default) { (action) in
            
            
            
            let query = PFQuery(className: "BusinessInformation")
            query.whereKey("businessUserName", equalTo: "\(PFUser.current()!.username!)")
            
            query.findObjectsInBackground { (objects, error) in
                if error != nil{
                    let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
                else{
                    
                    self.screenPassword = ""
                    
                    for object in objects!{
                        
                        self.screenPassword = (object.object(forKey: "EkranSifresi") as! String)
                        
                    }
                    
                    if alertController.textFields?.first?.text! == self.screenPassword{
                        print("Şifreler eşleşiyor")
                    }
                    else{
                        
                        self.viewWillAppear(false)
                    }
                    
                }
            }
        }
        
        alertController.addTextField { (passwordTextField) in
            print(passwordTextField.text!)
        }
        alertController.textFields?.first?.isSecureTextEntry = true
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    
    @IBAction func AddLocationPressed(_ sender: Any) {

            performSegue(withIdentifier: "konumVCToAddLocationVC", sender: nil)
    }
    
    
    // mevcut konumu sıfırlamak için
    @IBAction func cleanButtonPressed(_ sender: Any) {
        if businessNameLabel.text != ""{
        
        let alertController = UIAlertController(title: "EMİN MİSİNİZ ?", message: "", preferredStyle: .alert)
        
        // Evet e basılırsa olacaklar
        let okAction = UIAlertAction(title: "Evet", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.deleteWithObjectId()
            
        }
            // hayır a basılırsa olacaklar
        let cancelAction = UIAlertAction(title: "Hayır", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
        }
        
        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
        
        }else{
            let alert = UIAlertController(title: "Lütfen Konum Ekleyin", message: "", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
// işletme bilgilerine göre, mevcut işletmenin mevcut konumunun kayıtlı olduğu object id ile, longitude-latitude sıfırlamak
    func deleteWithObjectId(){
        let query = PFQuery(className: "BusinessInformation")
        query.whereKey("businessUserName", equalTo: (PFUser.current()?.username)!)
        
        query.findObjectsInBackground { (objects, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                self.objectIdArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    self.objectIdArray.append(object.objectId!)
                    
                    self.objectId = "\(self.objectIdArray.last!)"
                }
                
                let query = PFQuery(className: "BusinessInformation")
                query.whereKey("businessUserName", equalTo: "\(PFUser.current()!.username!)")
                
                query.getObjectInBackground(withId: self.objectId) { (object, error) in
                    if error != nil{
                        let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                        alert.addAction(okButton)
                        self.present(alert, animated: true, completion: nil)
                    }
                    else{
                        object!["latitude"] = ""
                        object!["longitude"] = ""
                        
                        object?.saveInBackground()
                        
                       self.longitudeLabel.text = ""
                       self.latitudeLabel.text = ""
                        
                        self.addButton.isHidden = false
                    }
                }
            }
        }
    }
    // bilgilerinin kullanımı
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

    // eğer kayıtlı konum varsa o konum bilgilerini ekranda gösterebilmek için
    func getLocationData(){
        
        let query = PFQuery(className: "BusinessInformation")
          query.whereKey("businessUserName", equalTo: "\(PFUser.current()!.username!)")
       
          query.findObjectsInBackground { (objects, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
                
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
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
                globalBusinessNameTextFieldKonumVC = self.businessNameLabel.text!
                
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
        
    }

    
    }

