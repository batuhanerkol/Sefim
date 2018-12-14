//
//  FoodInformationVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 8.09.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse
class AddFoodInformationVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextFieldDelegate {

    var businessName = ""
    var nameArray = [String]()
    
    @IBOutlet weak var longTextField: UITextView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var selectedImage: UIImageView!
    
        var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
        updateUserInterface()

        self.priceTextField.delegate = self
        
          selectedImage.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddFoodInformationVC.selectImage))
            selectedImage.addGestureRecognizer(gestureRecognizer)
        
     
        // loading sembolu
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorView.Style.gray
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
    }
    override func viewWillAppear(_ animated: Bool) {
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
            self.confirmButton.isEnabled = false
            
        case .wifi:
             self.confirmButton.isEnabled = true
             getBussinessNameData()
        case .wwan:
             getBussinessNameData()
             self.confirmButton.isEnabled = true
        }
    }
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
    
    @objc func selectImage() {
        
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        selectedImage.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func confirmButtonPressed(_ sender: Any) {
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
            addFoodInfo()
     
    }
    
    func addFoodInfo(){
        if textField.text != "" && longTextField.text != "" && priceTextField.text != ""  {
            self.confirmButton.isHidden = true
            
            let foodInformation = PFObject(className: "FoodInformation")
            foodInformation["foodName"] = textField.text!
            foodInformation["foodInformation"] = longTextField.text!
            foodInformation["foodPrice"] = priceTextField.text!
            foodInformation["foodNameOwner"] = PFUser.current()!.username!
            foodInformation["foodTitle"] = selectecTitle
            let uuid = UUID().uuidString
            foodInformation["fooduuid"] = "\(uuid) \(PFUser.current()!.username!)"
            foodInformation["BusinessName"] = businessName
            
            if let imageData = UIImageJPEGRepresentation(selectedImage.image!, 0.5){
                foodInformation["image"] = PFFile(name: "image.jpg", data: imageData)
            }
            
            foodInformation.saveInBackground { (success, error) in
                
                if self.textField.text != "" && self.longTextField.text != "" && self.priceTextField.text != ""{
                    
                    if error != nil{
                        let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                        alert.addAction(okButton)
                        self.present(alert, animated: true, completion: nil)
                    }
                    else{
                        
                        print("success")
                        self.confirmButton.isHidden = false
                        self.priceTextField.text = ""
                        self.textField.text = ""
                        self.longTextField.text = ""
                        self.selectedImage.image = UIImage(named: "fotosecin.png")
                        
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        
                    }
                }
                else if self.textField.text == "" || self.longTextField.text == "" || self.priceTextField.text == ""{
                    let alert = UIAlertController(title: "HATA", message: "Lütfen Bilgileri Tam Giriniz", preferredStyle: UIAlertControllerStyle.alert)
                    let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                }
            }
        }
        else if self.textField.text == "" || self.longTextField.text == "" || self.priceTextField.text == ""{
            let alert = UIAlertController(title: "HATA", message: "Lütfen Bilgileri Tam Giriniz", preferredStyle: UIAlertControllerStyle.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
            
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
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
                
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
            else{
                self.nameArray.removeAll(keepingCapacity: false)
                for object in objects!{
                    self.nameArray.append(object.object(forKey: "businessName") as! String)
                    
                    self.businessName = "\(self.nameArray.last!)"
                }
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: -250, up: true)
    }
    
    // Finish Editing The Text Field
    func textFieldDidEndEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: -250, up: false)
    }
    
    // Hide the keyboard when the return key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Move the text field in a pretty animation!
    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    }
    


