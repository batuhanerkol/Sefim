//
//  KareKodVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 3.09.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse

class KareKodVC: UIViewController , UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var imageArray = [PFFile]()
    
    
    @IBOutlet weak var saveToParseButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var QRImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    self.textField.delegate = self
        
        QRImageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(KareKodVC.selectImage))
        QRImageView.addGestureRecognizer(gestureRecognizer)
        
        getQRDataFromParse()
        createButton.isHidden = true
        saveToParseButton.isHidden = true
        
        
        if QRImageView.image == nil{
            self.QRImageView.image = UIImage(named: "QRIcınDokun.png")
            saveToParseButton.isHidden = false
            createButton.isHidden = false
            deleteButton.isHidden = true
            textField.isHidden = true
        }
        

    }
    @objc func selectImage() {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
        
        self.saveToParseButton.isHidden = false
        self.createButton.isHidden = true
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        QRImageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func buttonClicked(_ sender: Any) {
        self.createButton.isHidden = true
        self.deleteButton.isHidden = false
          textField.isHidden = false
        
        performSegue(withIdentifier: "KareKodToCreateQR", sender: nil)
       
    }
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    @IBAction func deleteQRButton(_ sender: Any) {
        
        let email = isValidEmail(testStr: textField.text!)
        if email == true {
            if textField.text == PFUser.current()!.username!{
        let query = PFQuery(className: "QRInformation")
        query.whereKey("QROwner", equalTo: "\(PFUser.current()!.username!)")
        query.whereKey("QROwner", equalTo: textField.text!)
        
        query.findObjectsInBackground { (objects, error) in
            
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: "Lütfen Kullanıcı Adı Mail Adresini Giriniz", preferredStyle: UIAlertControllerStyle.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
                
                
            else{
                
                if self.textField.text != ""{
                    self.QRImageView.image = UIImage(named: "QRIcınDokun.png")
                    self.textField.text = ""
                    self.textField.isHidden = true
                    
                    
                    self.deleteButton.isHidden = true
                    self.createButton.isHidden = false
                    for object in objects! {
                        object.deleteInBackground()
                        
                        self.textField.isHidden = true
                        
                    }
                }
                
                else{
                    let alert = UIAlertController(title: "SİlMEK İÇİN E-MAİL ADRESİ GİRİNİZ", message: "", preferredStyle: UIAlertControllerStyle.alert)
                    let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                }
                
               
            }
            
        }
        
        }
            else{
                let alert = UIAlertController(title: "Kullanıcı adı mailinizi giriniz", message: "", preferredStyle: UIAlertControllerStyle.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            }
        
        
        else{
            let alert = UIAlertController(title: "BİR E-MAİL ADRESİ GİRİNİZ", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
        }

   
    func getQRDataFromParse(){
        let query = PFQuery(className: "QRInformation")
        query.whereKey("QROwner", equalTo: (PFUser.current()?.username)!)
        query.findObjectsInBackground { (objects, error) in
            
            if error != nil{
            let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
            }
            else{
                 self.imageArray.removeAll(keepingCapacity: false)
                
                for object in objects!{
                    self.imageArray.append(object.object(forKey: "qrimage") as! PFFile)
                    self.imageArray.last?.getDataInBackground(block: { (data, error) in
                        if error != nil{
                            let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                            alert.addAction(okButton)
                            self.present(alert, animated: true, completion: nil)
                            self.QRImageView.image = UIImage(named: "QRIcınDokun.png")
                        }
                        else{
                            self.QRImageView.image = UIImage(data: (data)!)
                            
                            self.createButton.isHidden = true
                            self.saveToParseButton.isHidden = true
                            self.textField.isHidden = false
                            self.deleteButton.isHidden = false
                        }
                    })
                }
            }
        }
        
    }
    @IBAction func savetoParseButtonClicked(_ sender: Any) {
       
         let QRObject = PFObject(className: "QRInformation")
         QRObject["QROwner"] = PFUser.current()!.username!
        
        if let imageData = UIImageJPEGRepresentation(QRImageView.image!, 0.5){
        QRObject["qrimage"] = PFFile(name: "qrimage.jpg", data: imageData)
        
        }
        QRObject.saveInBackground { (objects, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                let alert = UIAlertController(title: "QR Veri Tabanına Kaydedildi", message: "", preferredStyle: UIAlertControllerStyle.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
                
                self.saveToParseButton.isHidden = true
                self.deleteButton.isHidden = false
                self.textField.isHidden = false
                
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

