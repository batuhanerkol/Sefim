//
//  AddFoodTitleVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 8.09.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse

class AddFoodTitleVC: UIViewController {
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
self.addButton.isHidden = false
    }

    @IBAction func addButtonPressed(_ sender: Any) {
        self.addButton.isHidden = true
            if textField.text != "" {
                
                let foodTitle = PFObject(className: "FoodTitle")
                foodTitle["foodTitle"] = textField.text!
                foodTitle["foodTitleOwner"] = PFUser.current()!.username!
                
                foodTitle.saveInBackground { (success, error) in
                    
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                print("success")
                self.performSegue(withIdentifier: "AddFoodTitleVCToMenuTVC", sender: nil)
            }
                }
                
            }
            else{
                let alert = UIAlertController(title: "HATA", message: "Lütfen Başlık Giriniz", preferredStyle: UIAlertControllerStyle.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
        
        
        
        }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    }
    


