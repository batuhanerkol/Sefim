//
//  ChangeTableNumberVC.swift
//  SiparisKullanici
//
//  Created by Batuhan Erkol on 21.12.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse

class ChangeTableNumber: UIViewController {
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    var controlTableNumberArray = [String]()
    var currentTableNumberArray = [String]()
    var objectIdArraySiparisler = [String]()
    var objectIdVerilenSiparisler = ""
    var masaSayisi = ""
    
    var tableIndexNumber = 0
    

    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var tableNumberTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // internet kontrolü
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
        updateUserInterface()
        
        // loading sembolu
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorView.Style.gray
        view.addSubview(activityIndicator)
    }
    
    func updateUserInterface() {
        guard let status = Network.reachability?.status else { return }
        switch status {
        case .unreachable:
            let alert = UIAlertController(title: "İnternet Bağlantınız Bulunmuyor.", message: "Lütfen Kontrol Edin", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
            
        case .wifi:
            getTableNumber()
            getObjectId()
            controlTableNumber()
        case .wwan:
            getTableNumber()
            getObjectId()
            controlTableNumber()
        }
        
    }
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
    
    func getObjectId(){
        let query = PFQuery(className: "Siparisler")
        query.whereKey("SiparisSahibi", equalTo: (PFUser.current()?.username)!)
        query.whereKey("IsletmeSahibi", equalTo: (PFUser.current()?.username)!)
        query.whereKey("MasaNumarasi", equalTo: globalChosenTableNumberMasaVC)
        
        query.findObjectsInBackground { (objects, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                self.objectIdArraySiparisler.removeAll(keepingCapacity: false)
                self.controlTableNumberArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    self.objectIdArraySiparisler.append(object.objectId!)
                    self.controlTableNumberArray.append(object.object(forKey: "MasaNumarasi") as! String)
                    
                }
            }
        }
    }
    
    func getTableNumber(){ // işletmenin masa sayisina ulaşabilmek için
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
                self.masaSayisi = ""
                
                for object in objects! {
                    self.masaSayisi = (object.object(forKey: "MasaSayisi") as! String)
                }
            }
        }
    }
    
    func getObjectIdVerilenSiparisler(){ // objectId func dışına boş çıktıgı için change fonks burada çağırıldı
        let query = PFQuery(className: "VerilenSiparisler")
        query.whereKey("SiparisSahibi", equalTo: (PFUser.current()?.username)!)
        query.whereKey("IsletmeSahibi", equalTo: (PFUser.current()?.username)!)
        
        query.findObjectsInBackground { (objects, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                self.objectIdVerilenSiparisler = ""
                
                for object in objects! {
                    self.objectIdVerilenSiparisler = (object.objectId!)
                }
                self.changeGivenOrderTableNumber()
            }
        }
    }
    
   
    func controlTableNumber(){ // mevcut kullanıcının verdiği sipariş var mı kontrol etmek için
        let query = PFQuery(className: "Siparisler")
        query.whereKey("SiparisSahibi", equalTo: (PFUser.current()?.username)!)
        query.whereKeyExists("MasaNumarasi")
        
        query.findObjectsInBackground { (objects, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                self.currentTableNumberArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    
                    self.currentTableNumberArray.append(object.object(forKey: "MasaNumarasi") as! String)
                }
            }
        }
        
    }
    
    @IBAction func changeButtonPressed(_ sender: Any) {
        
        if Int(self.tableNumberTextField.text!)! <= Int(self.masaSayisi)!{
            
            if self.tableNumberTextField.text != "" && self.controlTableNumberArray.isEmpty == false && currentTableNumberArray.isEmpty == false{
                
                if self.controlTableNumberArray.contains(tableNumberTextField.text!){
                    
                    let alert = UIAlertController(title: "Masa Dolu", message: "", preferredStyle: UIAlertController.Style.alert)
                    let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                    
                    self.tableNumberTextField.text = ""
                }
                    
                else {
                    
                    if self.currentTableNumberArray.isEmpty == false{
                        
                        while self.tableIndexNumber < self.objectIdArraySiparisler.count{
                            changeTableNumber()
                            self.tableIndexNumber += 1
                            
                        }
                        
                        getObjectIdVerilenSiparisler()
                        
                        let alert = UIAlertController(title: "Masa Numarası Değiştirildi", message: "", preferredStyle: UIAlertController.Style.alert)
                        let okAction = UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default) {
                            UIAlertAction in
                            self.performSegue(withIdentifier: "backToTable", sender: nil)
                        }
                        
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                        
                        
                    }
                    else{
                        let alert = UIAlertController(title: "Masa Boş  ", message: "", preferredStyle: UIAlertController.Style.alert)
                        let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                        alert.addAction(okButton)
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                }
            }else{
                let alert = UIAlertController(title: "Lütfen Bir Masa Numarası Girin", message: "", preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
        }else{
            let alert = UIAlertController(title: "İşletmenin \(self.masaSayisi) Masası Bulunmaktadır", message: "", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func changeTableNumber(){ // siparislerdeki masa numarasını değişmek için
        
        let query = PFQuery(className: "Siparisler")
        query.whereKey("SiparisSahibi", equalTo: (PFUser.current()?.username)!)
        query.whereKeyExists("MasaNumarasi")
        query.getObjectInBackground(withId: objectIdArraySiparisler[tableIndexNumber]) { (objects, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }else {
                objects!["MasaNumarasi"] = self.tableNumberTextField.text!
                objects!.saveInBackground(block: { (success, error) in
                    if error != nil{
                        let alert = UIAlertController(title: "Bir Hata Oluştu Lütfen Tekrar Deneyin", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                        let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                        alert.addAction(okButton)
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }
        }
    }
    
    func changeGivenOrderTableNumber(){ // verilen Siparişlerde masa numarasını değişmek için
        
        if self.objectIdVerilenSiparisler != ""{
            
            let query = PFQuery(className: "VerilenSiparisler")
            query.whereKey("SiparisSahibi", equalTo: (PFUser.current()?.username)!)
            query.whereKey("HesapOdendi", equalTo: "")
            query.whereKeyExists("MasaNo")
            query.getObjectInBackground(withId: self.objectIdVerilenSiparisler) { (objects, error) in
                if error != nil{
                    let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                }else {
                    objects!["MasaNo"] = self.tableNumberTextField.text!
                    objects!.saveInBackground(block: { (success, error) in
                        if error != nil{
                            let alert = UIAlertController(title: "Bir Hata Oluştu Lütfen Tekrar Deneyin", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                            alert.addAction(okButton)
                            self.present(alert, animated: true, completion: nil)
                        }
                    })
                }
            }
        }
    }
    
}
