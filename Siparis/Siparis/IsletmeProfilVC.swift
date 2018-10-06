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
    @IBOutlet weak var bussinessInfoButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

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
            
            }
        }
        
        }
    @IBAction func businessInfoButtonPressed(_ sender: Any) {
       
    }
    
    }
    


