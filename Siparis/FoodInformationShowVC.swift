//
//  FoodInformationShowVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 8.09.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse

class FoodInformationShowVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var guncelleButton: UIButton!
    @IBOutlet weak var yemekAciklamasi: UITextField!
    @IBOutlet weak var ucretTextField: UITextField!
    @IBOutlet weak var menudeGorunsunLabel: UILabel!
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var foodLabel: UILabel!
    
    var selectedFood = ""
    var foodNameArray = [String]()
    var foodInformationArray = [String]()
    var foodPriceArray = [String]()
    var fooduuid = [String]()
    var imageArray = [PFFile]()
    var hammaddeGorunumu = ""
    
      var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // interner kontrolü
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
        updateUserInterface()
        
     
        // loading sembolu
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorView.Style.gray
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        ucretTextField.delegate = self
        yemekAciklamasi.delegate = self

    }
    override func viewWillAppear(_ animated: Bool) {
          updateUserInterface()
    }
    // İ.k Sonrası yapıalcaklar
    func updateUserInterface() {
        guard let status = Network.reachability?.status else { return }
        switch status {
        case .unreachable:
            let alert = UIAlertController(title: "İnternet Bağlantınız Bulunmuyor.", message: "Lütfen Kontrol Edin", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
            
        case .wifi:
             findFood()
              getObjectId()
        case .wwan:
             findFood()
            getObjectId()
        }
    }
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
    // selected food bilgisi table da secilen yemek ismi sonrası prepare for segue ile geliyor
    func findFood(){
        let query = PFQuery(className: "FoodInformation")
        query.whereKey("foodName", equalTo: self.selectedFood)
        
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
                self.foodNameArray.removeAll(keepingCapacity: false)
                self.foodInformationArray.removeAll(keepingCapacity: false)
                self.foodPriceArray.removeAll(keepingCapacity: false)
                self.imageArray.removeAll(keepingCapacity: false)
                self.hammaddeGorunumu = ""
                
                for object in objects!{
                      self.foodNameArray.append(object.object(forKey: "foodName") as! String)
                      self.foodInformationArray.append(object.object(forKey: "foodInformation") as! String)
                      self.foodPriceArray.append(object.object(forKey: "foodPrice") as! String)
                      self.imageArray.append(object.object(forKey: "image") as! PFFile)
                      self.hammaddeGorunumu = (object.object(forKey: "MenudeGorunsun") as! String)
                    
                    self.foodLabel.text = "\(self.foodNameArray.last!)"
                    self.yemekAciklamasi.text = "\(self.foodInformationArray.last!)"
                    self.ucretTextField.text = "\(self.foodPriceArray.last!)₺"
                    self.menudeGorunsunLabel.text = self.hammaddeGorunumu
                    
                    self.imageArray.last?.getDataInBackground(block: { (data, error) in
                        if error != nil{
                            let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                            alert.addAction(okButton)
                            self.present(alert, animated: true, completion: nil)
                            
                            self.activityIndicator.stopAnimating()
                            UIApplication.shared.endIgnoringInteractionEvents()
                    }
                        else{
                            self.foodImage.image = UIImage(data: (data)!)
                        }
                })
                
                }
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
}
}
}
    var objectId = ""
    
    func getObjectId(){
        let query = PFQuery(className: "FoodInformation")
        query.whereKey("foodNameOwner", equalTo: (PFUser.current()?.username)!)
        query.whereKey("foodName", equalTo: self.selectedFood)

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
                    self.objectId = (object.objectId!)
                }
            }
        }
    }
    @IBAction func showMenuButtonClicked(_ sender: Any) {
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let query = PFQuery(className: "FoodInformation")
        query.whereKey("foodNameOwner", equalTo: (PFUser.current()?.username)!)
        
        query.getObjectInBackground(withId: objectId) { (objects, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
                
            }else {
                
                objects!["MenudeGorunsun"] = "Evet"
                objects!.saveInBackground(block: { (success, error) in
                    
                    if error != nil{
                        let alert = UIAlertController(title: "Lütfen Tekrar Deneyin", message: "", preferredStyle: UIAlertController.Style.alert)
                        let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                        alert.addAction(okButton)
                        self.present(alert, animated: true, completion: nil)
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        
                    }else{
                        let alert = UIAlertController(title: "Ürün Menu de Gösteriliyor", message: "", preferredStyle: UIAlertController.Style.alert)
                        let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                        alert.addAction(okButton)
                        self.present(alert, animated: true, completion: nil)
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                    }
                })
                self.menudeGorunsunLabel.text = "Evet"
            }
            
        }
    }
    
    @IBAction func dontShowMenuButtonClicked(_ sender: Any) {
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let query = PFQuery(className: "FoodInformation")
        query.whereKey("foodNameOwner", equalTo: (PFUser.current()?.username)!)
        
        query.getObjectInBackground(withId: objectId) { (objects, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                
            }else {
                
                objects!["MenudeGorunsun"] = "Hayır"
                objects!.saveInBackground(block: { (success, error) in
                    
                    if error != nil{
                        let alert = UIAlertController(title: "Lütfen Tekrar Deneyin", message: "", preferredStyle: UIAlertController.Style.alert)
                        let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                        alert.addAction(okButton)
                        self.present(alert, animated: true, completion: nil)
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        
                    }else{
                        let alert = UIAlertController(title: "Ürün Menu de Gösterilmiyor", message: "", preferredStyle: UIAlertController.Style.alert)
                        let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                        alert.addAction(okButton)
                        self.present(alert, animated: true, completion: nil)
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                    }
                })
                self.menudeGorunsunLabel.text = "Hayır"
            }
            
        }
    }
    
    @IBAction func guncelleButtonPressed(_ sender: Any) {
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let query = PFQuery(className: "FoodInformation")
        query.whereKey("foodNameOwner", equalTo: (PFUser.current()?.username)!)
        
        query.getObjectInBackground(withId: objectId) { (objects, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                
            }else {
                
                objects!["foodPrice"] = self.ucretTextField.text
                objects!["foodInformation"] = self.yemekAciklamasi.text
                
                objects!.saveInBackground(block: { (success, error) in
                    
                    if error != nil{
                        let alert = UIAlertController(title: "Lütfen Tekrar Deneyin", message: "", preferredStyle: UIAlertController.Style.alert)
                        let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                        alert.addAction(okButton)
                        self.present(alert, animated: true, completion: nil)
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        
                    }else{
                        
                        let alert = UIAlertController(title: "Güncelleme Tamamlandı", message: "", preferredStyle: UIAlertController.Style.alert)
                        let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                        alert.addAction(okButton)
                        self.present(alert, animated: true, completion: nil)
                        
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                    }
                })
            }
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: -200, up: true)
    }
    
    // Finish Editing The Text Field
    func textFieldDidEndEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: -200, up: false)
    }
    
    // Hide the keyboard when the return key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Move the text field in a pretty animation!
    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
}
