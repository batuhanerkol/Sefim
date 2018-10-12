//
//  SignedUpVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 4.09.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse


class SignedUpVC: UIViewController, UITextFieldDelegate {
    

    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password1: UITextField!
    @IBOutlet weak var password2: UITextField!
    @IBOutlet weak var phoneNo: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userName.delegate = self
        self.password1.delegate = self
        self.password2.delegate = self
        self.phoneNo.delegate = self
        self.nameTextField.delegate = self
        self.lastNameTextField.delegate = self
        
        self.phoneNo.keyboardType = UIKeyboardType.decimalPad
       
    }
    
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
   
    @IBAction func SignedUpClicked(_ sender: Any) {
       
        let email = isValidEmail(testStr: userName.text!)
        if email == true {
    
        if phoneNo.text != "" && userName.text != "" && password1.text != "" && password1.text == password2.text{
            
            let userSignUp = PFUser()
            userSignUp.username = userName.text!
            userSignUp.password = password1.text!
            userSignUp["PhoneNumber"] = phoneNo.text!
            userSignUp.email = userName.text!
            userSignUp["name"] = nameTextField.text!
            userSignUp["lastname"] = lastNameTextField.text!
            userSignUp["UyelikTipi"] = ("İsyeriSahibi")
    
            
            userSignUp.signUpInBackground { (success, error) in
                
                if error != nil{
                    let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    print("kullanıcı oluşturuldu")
                    
                    self.performSegue(withIdentifier: "SignedUpToTabBar", sender: nil)
                    UserDefaults.standard.set(self.userName.text!, forKey: "userName")
                    UserDefaults.standard.synchronize()
                    
                    let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    delegate.rememberUser()
                    
                }
                
            }
    
            }
            
        
        else{
            let alert = UIAlertController(title: "HATA", message: "Lütfen Bütün Bilgileri Giriniz", preferredStyle: UIAlertControllerStyle.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
            
        else{
            
            let alert = UIAlertController(title: "HATA", message: "Bir E-mail Giriniz", preferredStyle: UIAlertControllerStyle.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
  
        
    }

    // hide keyboard when touches outside keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return(true)
    }

}
