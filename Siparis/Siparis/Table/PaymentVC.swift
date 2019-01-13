//
//  PaymentVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 11.12.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse

class PaymentVC: UIViewController {
    
    
    var date = ""
    var time = ""
    var objectId = ""
    var yemekTeslimEdildiArray = [String]()
    var objectIdArray = [String]()
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()

    @IBOutlet weak var creditButton: UIButton!
    @IBOutlet weak var cashButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //internet kontolü
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
        updateUserInterface()
        
        cashButton.isEnabled = false
        creditButton.isEnabled = false
        
        
        
        // loading sembolu
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorView.Style.gray
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
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
            self.creditButton.isEnabled = false
            self.cashButton.isEnabled = false
            
        case .wifi:
            
      getObjectId()
            self.creditButton.isEnabled = true
            self.cashButton.isEnabled = true
        case .wwan:
          getObjectId()
            self.creditButton.isEnabled = true
            self.cashButton.isEnabled = true
        }
    }
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
    
 
    func getObjectId(){
        let query = PFQuery(className: "VerilenSiparisler")
        query.whereKey("SiparisSahibi", equalTo: (PFUser.current()?.username)!)
        query.whereKey("IsletmeSahibi", equalTo: (PFUser.current()?.username)!)
        query.whereKey("MasaNo", equalTo: globalChosenTableNumberMasaVC)
        query.whereKey("HesapOdendi", notEqualTo: "Evet")
        
        query.findObjectsInBackground { (objects, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
                
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
            else{
                self.objectIdArray.removeAll(keepingCapacity: false)
                 self.yemekTeslimEdildiArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    self.objectIdArray.append(object.objectId! )
                    self.yemekTeslimEdildiArray.append(object.object(forKey: "YemekTeslimEdildi") as! String)
                    
                    self.objectId = "\(self.objectIdArray.last!)"
                }
                print("objectId:",self.objectId)
                self.cashButton.isEnabled = true
                self.creditButton.isEnabled = true
                
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
    }
    @IBAction func cashButtonPressed(_ sender: Any) {
        if objectIdArray.isEmpty == false && yemekTeslimEdildiArray.last! == "Evet"{
            let query = PFQuery(className: "VerilenSiparisler")
            
            query.getObjectInBackground(withId: objectId) { (objects, error) in
                if error != nil{
                    let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                }else {
                    
                    objects!["HesapIstendi"] = "Nakit"
                    objects!.saveInBackground()
                    
                    let alert = UIAlertController(title: "Hesap Ödendiye Tıklayabilirsiniz", message: "", preferredStyle: UIAlertController.Style.alert)
                    let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }else{
            let alert = UIAlertController(title: "Yemek Henüz Teslim Edilmedi", message: "", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)

        }
    }
    
    @IBAction func creditCardButtonPressed(_ sender: Any) {
        if objectIdArray.isEmpty == false && yemekTeslimEdildiArray.last! == "Evet"{
            let query = PFQuery(className: "VerilenSiparisler")
            
            query.getObjectInBackground(withId: objectId) { (objects, error) in
                if error != nil{
                    let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                }else {
                    
                    objects!["HesapIstendi"] = "KrediKarti"
                    objects!.saveInBackground()
                    
                    let alert = UIAlertController(title: "Hesap Ödendiye Tıklayabilirsiniz", message: "", preferredStyle: UIAlertController.Style.alert)
                    let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        else{
            let alert = UIAlertController(title: "Yemek Henüz Teslim Edilmedi", message: "", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)

        }
    }
    

}
