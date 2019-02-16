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
    
    var objectIdArray = [String]()
    var objectId = ""
    
    var lokasyonKontrol = ""
    
    var manager = CLLocationManager()
    var requestCLLocation = CLLocation()

    @IBOutlet weak var businessNameTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //internet kontrolü
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
       updateUserInterface()
        
        self.businessNameTextField.delegate = self

        mapView.delegate = self
        self.manager.delegate = self
        self.manager.desiredAccuracy = kCLLocationAccuracyBest
        self.manager.requestWhenInUseAuthorization()
        self.manager.startUpdatingLocation()
        
        // ekrana 1.5 saniye basılı tutulduğunda pin eklemek için
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(AddLocationVC.chooseLocation(gestureRecognizer:)))
        recognizer.minimumPressDuration = 1.5
        mapView.addGestureRecognizer(recognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.chosenLatitude = ""
        self.chosenLongitude = ""
        whenTextFiledsChange()
       
        if globalBusinessNameTextFieldKonumVC != ""{
            businessNameTextField.isUserInteractionEnabled = false
        }
        updateUserInterface()
    }
    // i.k sonrası yapıalcaklar
    func updateUserInterface() {
        guard let status = Network.reachability?.status else { return }
        switch status {
        case .unreachable:
            let alert = UIAlertController(title: "İnternet Bağlantınız Bulunmuyor.", message: "Lütfen Kontrol Edin", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
            
            
            self.addButton.isEnabled = false
            
        case .wifi:
         print("wifiConnection")
             self.addButton.isEnabled = true
        
            getObjectId()
            
        case .wwan:
          print("wwanConnection")
             self.addButton.isEnabled = true
         
            getObjectId()
        }
    }
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
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
    // kişinin bulunduğu konumu göstermek
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)

        let span = MKCoordinateSpan(latitudeDelta: 0.009, longitudeDelta: 0.009)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        self.mapView.showsUserLocation = true
        
         self.manager.stopUpdatingLocation()
    }
    
    
    
    
    // seçilen pin in konumunu kaytı etmek
    // mevcut lokasyon bilgilerini güncellemek
    @IBAction func addButtonClicked(_ sender: Any) {
       
        if globalBusinessNameTextFieldKonumVC != ""{
            
            if self.chosenLatitude != "" && self.chosenLongitude != ""{
                 let actualLocation = PFGeoPoint(latitude:self.chosenLatitudeDouble,longitude:self.chosenLongitudeDouble)
                
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
                        object!["latitude"] =  self.chosenLatitude
                        object!["longitude"] = self.chosenLongitude
                        object!["Lokasyon"] = actualLocation
                        object!["businessName"] = self.businessNameTextField.text!
                        
                        object?.saveInBackground()
                        
                        self.performSegue(withIdentifier: "addLocationVCToKonumVC", sender: nil)

                    }
                }
            }else{
                let alert = UIAlertController(title: "Lütfen Konum Seçin", message: "", preferredStyle: UIAlertControllerStyle.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            
        }else{
            if businessNameTextField.text != "" {// eğer önceden kayıt edilmiş lokasyon yok ise burada tanımlanıyor 
                saveLocation()
               
            }
            else{
                let alert = UIAlertController(title: "HATA", message: "Lütfen İşletme İsmi Giriniz", preferredStyle: UIAlertControllerStyle.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            
        }
       
    }
    var bosFoto = UIImage(named: "bos.png")
    func saveLocation(){
        let actualLocation = PFGeoPoint(latitude:self.chosenLatitudeDouble,longitude:self.chosenLongitudeDouble)
        let object = PFObject(className: "BusinessInformation")
        
        object["businessUserName"] = PFUser.current()!.username!
        object["latitude"] = self.chosenLatitude
        object["longitude"] = self.chosenLongitude
        object["Lokasyon"] = actualLocation
        object["businessName"] = businessNameTextField.text!
        object["LezzetPuan"] = "0"
        object["HizmetPuan"] = "0"
        object["MasaSayisi"] = "0"
        object["HesapOnaylandi"] = ""
        object["EkranSifresi"] = ""
        
        if let imageData = UIImageJPEGRepresentation(self.bosFoto!, 0.5){
            object["image"] = PFFile(name: "image.jpg", data: imageData)
        }
        
        object.saveInBackground { (success, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
              self.performSegue(withIdentifier: "addLocationVCToKonumVC", sender: nil)
            }
        }
        
    }
    // işletmenin "busineesİnformation" parse classındaki bilgilerinin kayıtlı olduğu satırın obejct Id si
    func getObjectId(){
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
                self.lokasyonKontrol = ""
                
                for object in objects! {
                    self.objectIdArray.append(object.objectId!)
                    self.lokasyonKontrol = object.object(forKey: "longitude") as! String
                    self.businessNameTextField.text! = object.object(forKey: "businessName") as! String
                    
                    self.objectId = "\(self.objectIdArray.last!)"
                }
                print("objectId", self.objectId)
            }
        }
    }
   var i = 0
    func whenTextFiledsChange(){
        businessNameTextField.addTarget(self, action: #selector(AddLocationVC.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        
    }
    @objc func textFieldDidChange(_ textField: UITextField) {
        if self.i == 0{
        let alert = UIAlertController(title: "DİKKAT!", message: "İşletme İsmi Kayıt Edildikten Sonra Değiştirilemez, Lütfen Doğru Yazıldığından Emin Olduktan Sonra Kayıt Edin", preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
            i += 1
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
