//
//  BilgilerimVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 6.10.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse

class BilgilerimVC: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var saveChangesButton: UIButton!
    @IBOutlet weak var changePasswordButton: UIButton!
    
    var nameArray = [String]()
    var surnameArray = [String]()
    var userNameArray = [String]()
    var phoneNumberArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        saveChangesButton.isHidden = true
        
        if usernameTextField.text == "" || nameTextField.text == "" || lastnameTextField.text == "" || phoneNumberTextField.text == ""{
            saveChangesButton.isHidden = false
        }
        
    getUserInfoFromParse()

    }
    func getUserInfoFromParse(){

        let query = PFQuery(className: "_User")
         query.whereKey("username", equalTo: "\(PFUser.current()!.username!)")

        query.findObjectsInBackground { (objects, error) in
            if error != nil {
                            let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                            alert.addAction(okButton)
                            self.present(alert, animated: true, completion: nil)
                            }
            else{
                self.nameArray.removeAll(keepingCapacity: false)
                self.surnameArray.removeAll(keepingCapacity: false)
                self.userNameArray.removeAll(keepingCapacity: false)
                self.phoneNumberArray.removeAll(keepingCapacity: false)

                for object in objects!{
                    self.nameArray.append(object.object(forKey: "name") as! String)
                    self.surnameArray.append(object.object(forKey: "lastname") as! String)
                    self.userNameArray.append(object.object(forKey: "username") as! String)
                     self.phoneNumberArray.append(object.object(forKey: "PhoneNumber") as! String)

                    self.nameTextField.text = "\(self.nameArray.last!)"
                    self.lastnameTextField.text = "\(self.surnameArray.last!)"
                    self.usernameTextField.text = "\(self.userNameArray.last!)"
                    self.phoneNumberTextField.text = "\(self.phoneNumberArray.last!)"
                }
        }
        }
    }

////        let userInfo = PFUser()
////        userInfo.username = usernameTextField.text!
////        userInfo.email = usernameTextField.text!
////        userInfo["PhoneNumber"] = phoneNumberTextField.text!
////        userInfo["name"] = nameTextField.text!
////        userInfo["lastname"] = surnameTextField.text!
////
////        userInfo.fetchInBackground { (objects, error) in
////            if error != nil {
////            let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
////            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
////            alert.addAction(okButton)
////            self.present(alert, animated: true, completion: nil)
////            }
////            else{
////                for object in objects! {
////                    self.nameArray.append(object.object(forKey: "name") as! String)
////                    self.surnameArray.append(object.object(forKey: "lastname") as! String)
////                    self.foodPriceArray.append(object.object(forKey: "foodPrice") as! String)
////                }
////            }
////        }
//
//    }
   
    @IBAction func saveChangesButtonPressed(_ sender: Any) {
    }
    @IBAction func changePassworButtonPressed(_ sender: Any) {
    }
    
}

