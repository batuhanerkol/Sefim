//
//  FoodInformationVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 8.09.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse

class AddFoodInformationVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var longTextField: UITextView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var selectedImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
          selectedImage.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddFoodInformationVC.selectImage))
            selectedImage.addGestureRecognizer(gestureRecognizer)
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
        
        if textField.text != "" {
            let foodInformation = PFObject(className: "FoodTitle")
            foodInformation["foodName"] = textField.text!
            foodInformation["foodInformation"] = longTextField.text!
            foodInformation["foodPrice"] = priceTextField.text!
            foodInformation["foodNameOwner"] = PFUser.current()!.username!
            let uuid = UUID().uuidString
            foodInformation["fooduuid"] = "\(uuid) \(PFUser.current()!.username!)"
            
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
                    self.priceTextField.text = ""
                    self.textField.text = ""
                    self.longTextField.text = ""
                    self.selectedImage.image = UIImage(named: "fotosecin.jpg")
                }
            }
            }
        }
        else{
            let alert = UIAlertController(title: "HATA", message: "Lütfen Bilgileri Tam Giriniz", preferredStyle: UIAlertControllerStyle.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    }
    


