//
//  BusinessInformationVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 20.09.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse

class BusinessInformationVC: UIViewController {
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var businessTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    

   
    @IBAction func saveButtonPressed(_ sender: Any) {
        if nameTextField.text != "" && lastNameTextField.text != "" && businessTextField.text != "" {
            
            let user = PFObject(className: "User")
             user["name"] = nameTextField.text!
             user["lastName"] = lastNameTextField.text!
             user["businessName"] = businessTextField.text!
             user["username"] = PFUser.current()!.username!
            
            user.saveInBackground { (success, error) in
                if error != nil{
                    let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    print("bilgiler kayıt edildi")
                    
                }
                
            }
            }
            
        else{
            let alert = UIAlertController(title: "HATA", message: "Lütfen Bilgileri Tam Giriniz", preferredStyle: UIAlertControllerStyle.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
            
        }
        }
}
    

