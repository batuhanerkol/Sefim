//
//  SingInVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 3.09.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse

class SingInVC: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var userNameText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
        updateUserInterface()
        
        self.userNameText.delegate = self
        self.passwordText.delegate = self
        
        self.navigationItem.setHidesBackButton(true, animated:true)
        
    }
    func updateUserInterface() {
        guard let status = Network.reachability?.status else { return }
        switch status {
        case .unreachable:
            let alert = UIAlertController(title: "İnternet Bağlantınız Bulunmuyor.", message: "Lütfen Kontrol Edin", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
            self.signInButton.isEnabled = false
            self.signUpButton.isEnabled = false

        case .wifi:
            self.signInButton.isEnabled = true
            self.signUpButton.isEnabled = true
        case .wwan:
            self.signInButton.isEnabled = true
            self.signUpButton.isEnabled = true
        }
    }
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
    
    
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    @IBAction func signInClicked(_ sender: Any) {
        
        if userNameText.text != "" && passwordText.text != ""{
           
                PFUser.logInWithUsername(inBackground: self.userNameText.text!, password: self.passwordText.text!) { (user, error) in
                if error != nil{
                    let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    UserDefaults.standard.set(self.userNameText.text!, forKey: "userName")
                    UserDefaults.standard.synchronize()
                    
                    let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    delegate.rememberUser()
                }
            }
        }
        else{
            let alert = UIAlertController(title: "HATA", message: "Kullanıcı Adı veya Şifre Eksik", preferredStyle: UIAlertControllerStyle.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
    dismissKeyboard()
    }
    
    @IBAction func signupClicked(_ sender: Any) {
       
        performSegue(withIdentifier: "SignInVCtoSignUpVC", sender: nil)
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
