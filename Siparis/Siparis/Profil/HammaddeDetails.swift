//
//  HammaddeDetails.swift
//  Siparis
//
//  Created by Batuhan Erkol on 23.12.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse

class HammaddeDetails: UIViewController {
    
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var hammaddeFiyatiTextField: UITextField!
    @IBOutlet weak var hammaddeMiktariTextFiedl: UITextField!
    @IBOutlet weak var hammaddeAdiTExtField: UITextField!
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    var hammaddeAdi = ""
    var hammaddeMiktari = ""
    var hammaddeFiyati = ""
    var toplamFiyat = ""
    var selectedHammadde = ""
    var objectId = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
        updateUserInterface()
        
        // loading sembolu
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorView.Style.gray
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    // IK sonrası yaılacaklar
    func updateUserInterface() {
        guard let status = Network.reachability?.status else { return }
        switch status {
        case .unreachable:
            let alert = UIAlertController(title: "İnternet Bağlantınız Bulunmuyor.", message: "Lütfen Kontrol Edin", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
            
        case .wifi:
            
            if PFUser.current()?.username != nil{
                getObjectId()
                getHammaddeInfo()
            }
        case .wwan:
            
            if PFUser.current()?.username != nil{
                getObjectId()
                getHammaddeInfo()
            }
        }
    }
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
    
    func getObjectId(){
        
        let query = PFQuery(className: "HammaddeBilgileri")
        query.whereKey("HammaddeSahibi", equalTo: (PFUser.current()?.username)!)
        query.whereKey("HammaddeAdi", equalTo: selectedHammadde)
        query.addDescendingOrder("createdAt")
        
        query.findObjectsInBackground { (objects, error) in
            
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                
                self.objectId = ""
                
                for object in objects! {
                    
                    self.objectId = (object.objectId! as String)
                    
                }
                
                
            }
            
            
        }
    }
    
    
    func getHammaddeInfo(){
        if selectedHammadde != ""{
        let query = PFQuery(className: "HammaddeBilgileri")
        query.whereKey("HammaddeSahibi", equalTo: "\(PFUser.current()!.username!)")
        query.whereKey("HammaddeAdi", equalTo: selectedHammadde)
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
                self.hammaddeAdi = ""
                self.hammaddeFiyati = ""
                self.hammaddeMiktari = ""
                self.toplamFiyat = ""
                for object in objects! {
                    self.hammaddeAdi = (object.object(forKey: "HammaddeAdi") as! String)
                     self.hammaddeMiktari = (object.object(forKey: "HammaddeMiktariGr") as! String)
                     self.hammaddeFiyati = (object.object(forKey: "HammaddeUcreti") as! String)
                    self.toplamFiyat = (object.object(forKey: "ToplamUcret") as! String)
                   
                }
                
                self.hammaddeAdiTExtField.text = self.hammaddeAdi
                self.hammaddeMiktariTextFiedl.text = self.hammaddeMiktari
                self.hammaddeFiyatiTextField.text = self.hammaddeFiyati
                self.totalPriceLabel.text = self.toplamFiyat
    
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                
            }
        }
    }
        else{
            let alert = UIAlertController(title: "Bir Hata Oluştu Lütfen Tekrar Deneyin", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
            
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
    
    @IBAction func guncelleButtonPressed(_ sender: Any) {
        
      var toplamUcret = 0
        
        if hammaddeAdiTExtField.text != "" && hammaddeFiyatiTextField.text != "" && hammaddeMiktariTextFiedl.text != "" {
            
            toplamUcret = (Int(self.hammaddeFiyatiTextField.text!)! * Int(hammaddeMiktariTextFiedl.text!)!) / 1000
            
        let query = PFQuery(className: "HammaddeBilgileri")
        query.whereKey("HammaddeSahibi", equalTo: "\(PFUser.current()!.username!)")
        query.whereKey("HammaddeAdi", equalTo: selectedHammadde)
        
        query.getObjectInBackground(withId: objectId) { (objects, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
                
            }else {
                
                 objects!["HammaddeAdi"] = self.hammaddeAdiTExtField.text!
                 objects!["HammaddeMiktariGr"] = self.hammaddeMiktariTextFiedl.text!
                 objects!["HammaddeUcreti"] = self.hammaddeFiyatiTextField.text!
                 objects!["ToplamUcret"] = toplamUcret
                
                
                objects!.saveInBackground(block: { (success, error) in
                    if error != nil{
                        let alert = UIAlertController(title: "Lütfen Tekrar Deneyin", message: "", preferredStyle: UIAlertController.Style.alert)
                        let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                        alert.addAction(okButton)
                        self.present(alert, animated: true, completion: nil)
                        
                    }else{
                        let alert = UIAlertController(title: "Güncelleme Gerçekleşti", message: "", preferredStyle: UIAlertController.Style.alert)
                        let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                        alert.addAction(okButton)
                        self.present(alert, animated: true, completion: nil)
                    }
                })
                
            }
    }
    
}
        else{
            let alert = UIAlertController(title: "Lütfen Bilgileri Tam Girin", message: "", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
