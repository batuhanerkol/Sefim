//
//  HammaddeEkleVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 23.12.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse

class HammaddeEkleVC: UIViewController  {

    @IBOutlet weak var hammaddeKgUcretiTextField: UITextField!
    @IBOutlet weak var hammaddeMiktariTextField: UITextField!
    @IBOutlet weak var hammaddeAdiTextField: UITextField!
    
    var businessName = ""
    var toplamUcret = 0
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // internet kontrolü
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
        updateUserInterface()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
         updateUserInterface()
    }
    // Ik sonrası yapılacaklar
    func updateUserInterface() {
        guard let status = Network.reachability?.status else { return }
        switch status {
        case .unreachable:
            let alert = UIAlertController(title: "İnternet Bağlantınız Bulunmuyor.", message: "Lütfen Kontrol Edin", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
            
        case .wifi:
            getBussinessNameData()
        case .wwan:
            getBussinessNameData()
        }
    }
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
    @IBAction func ekleButtonClicked(_ sender: Any) {
        
        // loading sembolu
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorView.Style.gray
        view.addSubview(activityIndicator)
        
        if hammaddeAdiTextField.text != "" && hammaddeMiktariTextField.text != "" && hammaddeKgUcretiTextField.text != "" {
            
            toplamUcret = (Int(hammaddeMiktariTextField.text!)! * Int(hammaddeKgUcretiTextField.text!)!) / 1000
            if toplamUcret != 0 {
            
            // loading sembolu
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorView.Style.gray
            view.addSubview(activityIndicator)
            
            let hammadde = PFObject(className: "HammaddeBilgileri")
            hammadde["HammaddeSahibi"] = PFUser.current()!.username!
            hammadde["HammaddeAdi"] = hammaddeAdiTextField.text
            hammadde["HammaddeUcreti"] = hammaddeKgUcretiTextField.text
            hammadde["HammaddeMiktariGr"] = hammaddeMiktariTextField.text
            hammadde["ToplamUcret"] = String(toplamUcret)
            hammadde["IsletmeAdi"] = businessName
            
            hammadde.saveInBackground { (success, error) in
                
                if error != nil{
                    let alert = UIAlertController(title: "Bir Hata Oluştu Lütfen Tekrar Deneyin", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
                else{
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    print("success")
                    
                    self.performSegue(withIdentifier: "backToHammadde", sender: nil)
         
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
    
        else{
            let alert = UIAlertController(title: "HATA", message: "Lütfen Bütün Bilgileri Giriniz", preferredStyle: UIAlertControllerStyle.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
            
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }

    func getBussinessNameData(){
        let query = PFQuery(className: "BusinessInformation")
        query.whereKey("businessUserName", equalTo: "\(PFUser.current()!.username!)")
        
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
                self.businessName =  ""
                for object in objects!{
                    self.businessName = (object.object(forKey: "businessName") as! String)
                    
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return(true)
    }
    
    
}
