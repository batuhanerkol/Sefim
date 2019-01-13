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
            
            
            
            let query = PFQuery(className: "BusinessInformation")
            query.whereKey("businessUserName", equalTo: "\(PFUser.current()!.username!)")
            
            query.findObjectsInBackground { (objects, error) in
                if error != nil{
                    let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                
                }
                else{
                    
                    self.screenPassword = ""
                    
                    for object in objects!{
                        
                        self.screenPassword = (object.object(forKey: "EkranSifresi") as! String)
                        
                    }
                    
                    if alertController.textFields?.first?.text! == self.screenPassword{
                        print("Şifreler eşleşiyor")
                    }
                    else{
                        
                        self.viewWillAppear(false)
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
    
    }
    


