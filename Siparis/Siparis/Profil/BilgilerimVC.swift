//
//  BilgilerimVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 6.10.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse

class BilgilerimVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var saceLogoButton: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var saveChangesButton: UIButton!
    @IBOutlet weak var changePasswordButton: UIButton!
    
    var nameArray = [String]()
    var surnameArray = [String]()
    var userNameArray = [String]()
    var phoneNumberArray = [String]()
    var emailArray = [String]()
    var BusinessLogoNameArray = [PFFile]()
    var objectIdArray = [String]()
    
    var businessName = ""
    var objectId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoImageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddFoodInformationVC.selectImage))
        logoImageView.addGestureRecognizer(gestureRecognizer)
        
    saveChangesButton.isHidden = true

        if emailTextField.text == "" || nameTextField.text == "" || lastnameTextField.text == "" || phoneNumberTextField.text == ""{

        }
        getObjectId()
        whenTextFiledsChange()
        getUserInfoFromParse()
        getLogoFromParse()
    }
    
    func whenTextFiledsChange(){
        emailTextField.addTarget(self, action: #selector(BilgilerimVC.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        nameTextField.addTarget(self, action: #selector(BilgilerimVC.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        lastnameTextField.addTarget(self, action: #selector(BilgilerimVC.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        phoneNumberTextField.addTarget(self, action: #selector(BilgilerimVC.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
    }
    @objc func textFieldDidChange(_ textField: UITextField) {
        saveChangesButton.isHidden = false
    }
    func getObjectId(){
        let query = PFQuery(className: "BusinessInformation")
        query.whereKey("businessUserName", equalTo: (PFUser.current()?.username)!)
        query.whereKeyExists("businessName")
        
        query.findObjectsInBackground { (objects, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                self.objectIdArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    self.objectIdArray.append(object.objectId as! String)
                    
                    self.objectId = "\(self.objectIdArray.last!)"
                }
            }
        }
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
                self.emailArray.removeAll(keepingCapacity: false)

                for object in objects!{
                    self.nameArray.append(object.object(forKey: "name") as! String)
                    self.surnameArray.append(object.object(forKey: "lastname") as! String)
                    self.userNameArray.append(object.object(forKey: "username") as! String)
                    self.phoneNumberArray.append(object.object(forKey: "PhoneNumber") as! String)
                    self.emailArray.append(object.object(forKey: "email") as! String)

                    self.nameTextField.text = "\(self.nameArray.last!)"
                    self.lastnameTextField.text = "\(self.surnameArray.last!)"
                    self.usernameLabel.text = "\(self.userNameArray.last!)"
                    self.phoneNumberTextField.text = "\(self.phoneNumberArray.last!)"
                    self.emailTextField.text = "\(self.emailArray.last!)"
                    
                }
        }
        }
    }

    @IBAction func saveChangesButtonPressed(_ sender: Any) {
        let currentId = PFUser.current()?.objectId!
        let query = PFQuery(className: "_User")
       
        query.getObjectInBackground(withId: currentId!) { (object, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                object!["name"] = self.nameTextField.text!
                object!["lastname"] = self.lastnameTextField.text!
                object!["PhoneNumber"] = self.phoneNumberTextField.text!
                object!["email"] = self.emailTextField.text!
                object?.saveInBackground()
                self.saveChangesButton.isHidden = true
            }
        }
    
       
    }
//    @IBAction func ssaveLogoButtonPressed(_ sender: Any) {
//          self.deleteData()
//        let logo = PFObject(className: "BusinessInformation")
//
//        logo["businessUserName"] = "\(PFUser.current()!.username!)"
//
//        if let imageData = UIImageJPEGRepresentation(logoImageView.image!, 0.5){
//            logo["image"] = PFFile(name: "image.jpg", data: imageData)
//        }
//
//        logo.saveInBackground { (success, error) in
//
//            if error != nil{
//                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
//                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
//                alert.addAction(okButton)
//                self.present(alert, animated: true, completion: nil)
//            }
//            else{
//
//
//                let alert = UIAlertController(title: "Logo Kaydedildi", message: "", preferredStyle: UIAlertControllerStyle.alert)
//                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
//                alert.addAction(okButton)
//                self.present(alert, animated: true, completion: nil)
//
//            }
//        }
//    }
    
    @IBAction func saveLogoButtonPressed(_ sender: Any) {
        
        let query = PFQuery(className: "BusinessInformation")
        query.whereKey("businessUserName", equalTo: "\(PFUser.current()!.username!)")
        query.whereKeyExists("businessName")
        
        query.getObjectInBackground(withId: objectId) { (objects, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }else {
                print(self.objectId)
                if let imageData = UIImageJPEGRepresentation(self.logoImageView.image!, 0.5){
                    objects!["image"] = PFFile(name: "image.jpg", data: imageData)
                     objects!.saveInBackground()
                    
                    let alert = UIAlertController(title: "Logo Kaydedildi", message: "", preferredStyle: UIAlertControllerStyle.alert)
                    let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func getLogoFromParse(){
        let query = PFQuery(className: "BusinessInformation")
        query.whereKey("businessUserName", equalTo: (PFUser.current()?.username)!)
        query.whereKeyExists("image")
        query.findObjectsInBackground { (objects, error) in
            
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                self.BusinessLogoNameArray.removeAll(keepingCapacity: false)
                
                for object in objects!{
                    print("AAAAAA")
                    self.BusinessLogoNameArray.append(object.object(forKey: "image") as! PFFile)
                    
                    self.BusinessLogoNameArray.last?.getDataInBackground(block: { (data, error) in
                        if error != nil{
                            let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                            alert.addAction(okButton)
                            self.present(alert, animated: true, completion: nil)
                            self.logoImageView.image = UIImage(named: "QRIcınDokun.png")
                        }
                        else{
                            self.logoImageView.image = UIImage(data: (data)!)
    
                            
                        }
                    })
                }
            }
        }
        
    }
//    func getBussinessNameData(){
//        let query = PFQuery(className: "BusinessInformation")
//        query.whereKey("businessUserName", equalTo: "\(PFUser.current()!.username!)")
//
//        query.findObjectsInBackground { (objects, error) in
//            if error != nil{
//                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
//                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
//                alert.addAction(okButton)
//                self.present(alert, animated: true, completion: nil)
//            }
//            else{
//                self.BusinessLogoNameArray.removeAll(keepingCapacity: false)
//                for object in objects!{
//                    self.BusinessLogoNameArray.append(object.object(forKey: "businessName") as! String)
//
//                    self.businessName = "\(self.BusinessLogoNameArray.last!)"
//                }
//            }
//        }
//    }
    @objc func selectImage() {
        
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        logoImageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }

    func deleteData(){
        let query = PFQuery(className: "BusinessLOGO")
        query.whereKey("BusinessOwner", equalTo: "\(PFUser.current()!.username!)")
        
        query.findObjectsInBackground { (objects, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
              
                for object in objects! {
                    object.deleteInBackground()
                 
                  
                }
            }
            
        }
        
    }
    @IBAction func changePassworButtonPressed(_ sender: Any) {
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
}

