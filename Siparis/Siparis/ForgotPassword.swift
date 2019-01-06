//
//  ForgotPassword.swift
//  Siparis
//
//  Created by Batuhan Erkol on 20.12.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse

class ForgotPassword: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

     
    }
    @IBAction func okButtonPressed(_ sender: Any) {
        if emailTextField.text != ""{
            
            PFUser.requestPasswordResetForEmail(inBackground: emailTextField.text!) { (success, error) in
                if error != nil{
                    let alert = UIAlertController(title: "Beklenmeyen Bir Problem Oluştu Lütfen Tekrar Deneyin", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    let alert = UIAlertController(title: "\(self.emailTextField.text!) Adresine Yeni Şifre Maili Gönderildi", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                    
                    self.performSegue(withIdentifier: "backToLoginVC", sender: nil)
                }
            }
            
        }
        else{
            let alert = UIAlertController(title: "Lütfen Bir E-Mail Girin", message: "", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    

    @IBAction func cancelButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "backToLoginVC", sender: nil)
    }
    
}
