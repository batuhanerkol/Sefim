//
//  AddFoodTitleVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 8.09.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse



class AddFoodTitleVC: UIViewController,UITextFieldDelegate {
    
    var nameArray = [String]()
    var businessName = ""
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textField.delegate = self
      self.addButton.isHidden = false
    }

    
    override func viewWillAppear(_ animated: Bool) {
        getBussinessNameData()
    }
    @IBAction func addButtonPressed(_ sender: Any) {
        self.addButton.isHidden = true
        if businessName != ""{
            addFoodTitle()
        }else{
            let alert = UIAlertController(title: "Lütfen Öncelikle Konum ve İsim Bilgilerini Girin", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
        }
    func addFoodTitle(){
        if textField.text != "" {
            
            let foodTitle = PFObject(className: "FoodTitle")
            foodTitle["foodTitle"] = textField.text!
            foodTitle["foodTitleOwner"] = PFUser.current()!.username!
            foodTitle["BusinessName"] = businessName
            
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
    func getBussinessNameData(){
        let query = PFQuery(className: "BusinessInformation")
        query.whereKey("businessUserName", equalTo: "\(PFUser.current()!.username!)")
        
        query.findObjectsInBackground { (objects, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                self.nameArray.removeAll(keepingCapacity: false)
                for object in objects!{
                    self.nameArray.append(object.object(forKey: "businessName") as! String)
                    
                   self.businessName = "\(self.nameArray.last!)"
                }
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return(true)
    }
    }
    


