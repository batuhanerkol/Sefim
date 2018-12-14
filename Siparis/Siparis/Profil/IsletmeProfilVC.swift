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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
        updateUserInterface()

    }
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
    


