//
//  KareKodVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 3.09.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse

class KareKodVC: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var imageArray = [PFFile]()
    
    var objectIdArray = [String]()
    var objectId = ""
    
    @IBOutlet weak var saveToParseButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var QRImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        
        getObjectId()
       
        
        QRImageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(KareKodVC.selectImage))
        QRImageView.addGestureRecognizer(gestureRecognizer)
        
        
        if QRImageView.image == nil{
            self.QRImageView.image = UIImage(named: "QRIcınDokun.png")
//            saveToParseButton.isHidden = false
//            createButton.isHidden = false
//            deleteButton.isHidden = true
//            textField.isHidden = true
        }

    }
    override func viewWillAppear(_ animated: Bool) {
         getQRDataFromParse()
    }
    @objc func selectImage() {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
        
        self.saveToParseButton.isHidden = false
        self.createButton.isHidden = false
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        QRImageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func buttonClicked(_ sender: Any) {
        self.createButton.isHidden = false
   
      
        
        performSegue(withIdentifier: "KareKodToCreateQR", sender: nil)
       
    }
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
   
   
    func getQRDataFromParse(){
        let query = PFQuery(className: "BusinessInformation")
        query.whereKey("businessUserName", equalTo: (PFUser.current()?.username)!)
        query.whereKeyExists("QRKod")
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
                       print("AAAAAA")
                    self.imageArray.append(object.object(forKey: "QRKod") as! PFFile)
                   
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
                        
                        }
                    })
                }
            }
        }
        
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
                    self.objectIdArray.append(object.objectId!)
                    
                    self.objectId = "\(self.objectIdArray.last!)"
                }
            }
        }
    }
    
    @IBAction func savetoParseButtonClicked(_ sender: Any) {
        
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
                
                if let imageData = UIImageJPEGRepresentation(self.QRImageView.image!, 0.5){
                    objects!["QRKod"] = PFFile(name: "qrimage.jpg", data: imageData)
                    objects!.saveInBackground()
                    
                    let alert = UIAlertController(title: "QR Kaydedildi", message: "", preferredStyle: UIAlertControllerStyle.alert)
                    let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                    
//                    self.saveToParseButton.isHidden = true
                 

                }
            }
        }
    }
    
   
    }

