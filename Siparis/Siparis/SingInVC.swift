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
    
     var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var userNameText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
        updateUserInterface()
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorView.Style.gray
        view.addSubview(activityIndicator)
        
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
            
            activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
           
                PFUser.logInWithUsername(inBackground: self.userNameText.text!, password: self.passwordText.text!) { (user, error) in
                if error != nil{
                    let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
                else{
                    UserDefaults.standard.set(self.userNameText.text!, forKey: "userName")
                    UserDefaults.standard.synchronize()
                    
                    let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    delegate.rememberUser()
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
            }
        }
        else{
            let alert = UIAlertController(title: "HATA", message: "Kullanıcı Adı veya Şifre Eksik", preferredStyle: UIAlertControllerStyle.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
            
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    dismissKeyboard()
    }
    
    @IBAction func signupClicked(_ sender: Any) {
       
        performSegue(withIdentifier: "SignInVCtoSignUpVC", sender: nil)
}
    
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.view.endEditing(true)
//    }
//    
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        moveTextField(textField, moveDistance: -250, up: true)
//    }
//    
//    // Finish Editing The Text Field
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        moveTextField(textField, moveDistance: -250, up: false)
//    }
//    
//    // Hide the keyboard when the return key pressed
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
//    
    // Move the text field in a pretty animation!
//    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
//        let moveDuration = 0.3
//        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
//
//        UIView.beginAnimations("animateTextField", context: nil)
//        UIView.setAnimationBeginsFromCurrentState(true)
//        UIView.setAnimationDuration(moveDuration)
//        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
//        UIView.commitAnimations()
//    }
}
