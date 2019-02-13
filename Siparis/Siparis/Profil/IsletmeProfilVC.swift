//
//  IsletmeProfilVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 3.09.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse

class IsletmeProfilVC: UIViewController {
    @IBOutlet weak var logOutButton: UIBarButtonItem!
    @IBOutlet weak var bussinessInfoButton: UIButton!
    
    var screenPassword = ""
     var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    var passwordTextField: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        // internet konrolü
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
        updateUserInterface()

    }
    override func viewWillAppear(_ animated: Bool) {
        enteringPassword()
    }
    // IK sornası yapılacaklar
    func updateUserInterface() {
        guard let status = Network.reachability?.status else { return }
        switch status {
        case .unreachable:
            let alert = UIAlertController(title: "İnternet Bağlantınız Bulunmuyor.", message: "Lütfen Kontrol Edin", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
            
    self.logOutButton.isEnabled = false

        case .wifi:
            print("WifiConnection")
  self.logOutButton.isEnabled = true
        case .wwan:
 print("wwanConnection")
             self.logOutButton.isEnabled = true
        }
    }
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
    
    // ekran şifresi
    func enteringPassword(){
        
        let alertController = UIAlertController(title: "Şifre Girin", message: "", preferredStyle: .
            alert)
        let action = UIAlertAction(title: "Tamam", style: .default) { (action) in
            
            self.activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            let query = PFQuery(className: "BusinessInformation")
            query.whereKey("businessUserName", equalTo: "\(PFUser.current()!.username!)")
            
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
                    
                    self.screenPassword = ""
                    
                    for object in objects!{
                        
                        self.screenPassword = (object.object(forKey: "EkranSifresi") as! String)
                        
                    }
                    
                    if alertController.textFields?.first?.text! == self.screenPassword{
                        print("Şifreler eşleşiyor")
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                    }
                    else{
                        
                        self.viewWillAppear(false)
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                    }
                    
                }
            }
        }
        
        alertController.addTextField { (passwordTextField) in
            print(passwordTextField.text!)
        }
        alertController.textFields?.first?.isSecureTextEntry = true
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func logoutClicked(_ sender: Any) {
        
        PFUser.logOutInBackground { (error) in
            if error != nil {
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else {
                UserDefaults.standard.removeObject(forKey: "userName")
                UserDefaults.standard.synchronize()
                
                let signedInVC = self.storyboard?.instantiateViewController(withIdentifier: "signIn") as! SingInVC
                let delegata : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                delegata.window?.rootViewController = signedInVC
                delegata.rememberUser()
            }
        }
        
        }
    @IBAction func businessInfoButtonPressed(_ sender: Any) {
       
    }
    @IBAction func sendEmailButton(_ sender: Any) {
        let email = "erkolbatuhan@yandex.com"
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func makeCallButtonClicked(_ sender: Any) {
        "+905385994665".makeAColl()
        
    }
}
extension String {
    
    enum RegularExpressions: String {
        case phone = "^\\s*(?:\\+?(\\d{1,3}))?([-. (]*(\\d{3})[-. )]*)?((\\d{3})[-. ]*(\\d{2,4})(?:[-.x ]*(\\d+))?)\\s*$"
    }
    
    func isValid(regex: RegularExpressions) -> Bool {
        return isValid(regex: regex.rawValue)
    }
    
    func isValid(regex: String) -> Bool {
        let matches = range(of: regex, options: .regularExpression)
        return matches != nil
    }
    
    func onlyDigits() -> String {
        let filtredUnicodeScalars = unicodeScalars.filter{CharacterSet.decimalDigits.contains($0)}
        return String(String.UnicodeScalarView(filtredUnicodeScalars))
    }
    
    func makeAColl() {
        if isValid(regex: .phone) {
            if let url = URL(string: "tel://\(self.onlyDigits())"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
}



