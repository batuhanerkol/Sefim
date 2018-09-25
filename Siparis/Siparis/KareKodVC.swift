//
//  KareKodVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 3.09.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse

class KareKodVC: UIViewController , UITextFieldDelegate{
    
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var QRImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    self.textField.delegate = self
    }
    
    @IBAction func buttonClicked(_ sender: Any) {
        self.createButton.isHidden = true
        self.deleteButton.isHidden = false
         creatQRCode()
         uploadQRInformation()
        
       
    }
    
    @IBAction func deleteQRButton(_ sender: Any) {
        deleteData()
        self.textField.text = ""
    // sildikten sonra qr kodu kaldırmanın yolunu bul
        self.deleteButton.isHidden = true
       self.createButton.isHidden = false
    }
    
    func creatQRCode(){
        if let QRString = textField.text {
            
            let data =  QRString.data(using: .ascii, allowLossyConversion: false)
            let filter = CIFilter(name: "CIQRCodeGenerator")
            filter?.setValue(data, forKey: "inputMessage")
            
            let ciImage = filter?.outputImage
            
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let transformImage = ciImage?.transformed(by: transform)
            
            let image = UIImage(ciImage: transformImage!)
            QRImageView.image = image
            
            
    }
    }
    
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    
    func uploadQRInformation(){
        
            
            let qrObject = PFObject(className: "QRInformation")
            qrObject["QROwner"] = PFUser.current()!.username!
        
        if let imageData = UIImageJPEGRepresentation(QRImageView.image!, 0.3){
            qrObject["image"] = PFFile(name: "image.jpg", data: imageData)
        }
       
            qrObject.saveInBackground { (objects, error) in
                
                if error != nil{
                    let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    print("QR kayıt edildi")
                }
            
    }
    }
    
    func deleteData(){
        let query = PFQuery(className: "QRInformation")
        query.whereKey("QROwner", equalTo: "\(PFUser.current()!.username!)")
        
        
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
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return(true)
    }
}
