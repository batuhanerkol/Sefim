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
    
    var imageArray = [PFFile]()
    
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var QRImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    self.textField.delegate = self
        
        textField.isHidden = true
        deleteButton.isHidden = true
        
        self.navigationItem.hidesBackButton = true
        
        
        
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
                    
                    self.textField.text = ""
                    // sildikten sonra qr kodu kaldırmanın yolunu bul
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

    func getQRData(){
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
                self.imageArray.removeAll(keepingCapacity: false)
                
                for object in objects!{
                    self.imageArray.append(object.object(forKey: "QRImage") as! PFFile)
                    self.imageArray.last?.getDataInBackground(block: { (data, error) in
                        if error != nil{
                            let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                            alert.addAction(okButton)
                            self.present(alert, animated: true, completion: nil)
                        }
                        else{
                            self.QRImageView.image = UIImage(data: (data)!)
                        }
                    })
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
