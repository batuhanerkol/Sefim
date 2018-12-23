//
//  EkranSifresiVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 20.12.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse
class EkranSifresiVC: UIViewController, UITextFieldDelegate {
    
    var objectId = ""

    @IBOutlet weak var screenPaswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        screenPaswordTextField.delegate = self
        
       getObjectId()
    }
    
    @IBAction func createButtonClicked(_ sender: Any) {

        if self.screenPaswordTextField.text! != ""{
                
                let query = PFQuery(className: "BusinessInformation")
                query.whereKey("businessUserName", equalTo: (PFUser.current()?.username)!)

                
                query.getObjectInBackground(withId: objectId) { (objects, error) in
                    if error != nil{
                        let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                        let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                        alert.addAction(okButton)
                        self.present(alert, animated: true, completion: nil)
                        
                    }else {
                        
                        objects!["EkranSifresi"] = self.screenPaswordTextField.text!
                        objects!.saveInBackground(block: { (success, error) in
                            if error != nil{
                                let alert = UIAlertController(title: "Lütfen Tekrar Deneyin", message: "", preferredStyle: UIAlertController.Style.alert)
                                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                                alert.addAction(okButton)
                                self.present(alert, animated: true, completion: nil)
                                
                            }else{
                                let alert = UIAlertController(title: "Ekran Şifresi Oluşturuldu", message: "", preferredStyle: UIAlertController.Style.alert)
                                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                                alert.addAction(okButton)
                                self.present(alert, animated: true, completion: nil)
                            }
                        })
                     
                    }
                    
                }
            
        }
        else{
            let alert = UIAlertController(title: "Lütfen Şifre Girin", message: "", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
            
      
        }
    }
    
    
    func getObjectId(){
        
        let query = PFQuery(className: "BusinessInformation")
        query.whereKey("businessUserName", equalTo: (PFUser.current()?.username)!)
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
   
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let count = text.count + string.count - range.length
        return count <= 4
    }}
