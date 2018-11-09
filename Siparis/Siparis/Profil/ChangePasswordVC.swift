//
//  ChangePasswordVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 10.10.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse

class ChangePasswordVC: UIViewController {
   
    @IBOutlet weak var newPasswordAgainTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var oldPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
       
    
    }

    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let currentId = PFUser.current()?.objectId!
        let query = PFQuery(className: "_User")
        
        query.getObjectInBackground(withId: currentId!) { (object, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                if self.oldPasswordTextField.text! != PFUser.current()?.password{
                    if self.newPasswordTextField.text! == self.newPasswordAgainTextField.text{
                object!["password"] = self.newPasswordAgainTextField.text!
                object?.saveInBackground()
                let alert = UIAlertController(title: "Şifre Başarıyla Değiştirildi", message: "", preferredStyle: UIAlertControllerStyle.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
                }
                    else{
                        let alert = UIAlertController(title: "Yeni Şifre Eşleşmiyor", message: "", preferredStyle: UIAlertControllerStyle.alert)
                        let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                        alert.addAction(okButton)
                        self.present(alert, animated: true, completion: nil)
                    }
            }
                else{
                    let alert = UIAlertController(title: "Eski Şifre Hatalı", message: "", preferredStyle: UIAlertControllerStyle.alert)
                    let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
       
    }
    
  
}
