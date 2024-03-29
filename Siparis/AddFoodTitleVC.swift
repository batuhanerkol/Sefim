//
//  AddFoodTitleVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 8.09.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse



class AddFoodTitleVC: UIViewController,UITextFieldDelegate {
    
    var nameArray = [String]()
    var businessName = ""
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    
      var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // internet kontrolü
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
        updateUserInterface()
        
        self.textField.delegate = self
      self.addButton.isHidden = false
        
     
    }

    
    override func viewWillAppear(_ animated: Bool) {
        updateUserInterface()
        
    }
    
    // İ.K Sonrası yapılacaklar
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
            self.addButton.isEnabled = true
            
            getBussinessNameData()
        case .wwan:
            self.addButton.isEnabled = true
            
            getBussinessNameData()
        }
    }
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
    
    
    @IBAction func addButtonPressed(_ sender: Any) {
        
        self.addButton.isHidden = true
        
        if businessName != ""{
            addFoodTitle()
        }else{
            let alert = UIAlertController(title: "Lütfen Öncelikle Konum ve İsim Bilgilerini Girin", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
            
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
        }
    
    
    func addFoodTitle(){
        if textField.text != "" {
            
            // loading sembolu
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorView.Style.gray
            view.addSubview(activityIndicator)
            
            let foodTitle = PFObject(className: "FoodTitle")
            foodTitle["foodTitle"] = textField.text!
            foodTitle["foodTitleOwner"] = PFUser.current()!.username!
            foodTitle["BusinessName"] = businessName
            foodTitle["HesapOnaylandi"] = ""
            
            foodTitle.saveInBackground { (success, error) in
                
                if error != nil{
                    let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
                else{
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()

                    self.performSegue(withIdentifier: "AddFoodTitleVCToMenuTVC", sender: nil)
                }
            }
            
        }
        else{
            let alert = UIAlertController(title: "HATA", message: "Lütfen Başlık Giriniz", preferredStyle: UIAlertControllerStyle.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
            
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
    
    // yemek baslıgı kayıt ederken, yemeği kayıt eden işletme ismini de kayıt edebilmek için bu bilgi çekildi
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
                self.nameArray.removeAll(keepingCapacity: false)
                for object in objects!{
                    self.nameArray.append(object.object(forKey: "businessName") as! String)
                    
                   self.businessName = "\(self.nameArray.last!)"
                }
            }
        }
    }
    
    
// ekrana dokunulduğunda klavyeyi kapatmak
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return(true)
    }
    }
    


