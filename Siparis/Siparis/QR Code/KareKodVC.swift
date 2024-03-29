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
    var screenPassword = ""
    
    var passwordTextField: UITextField?
    
    @IBOutlet weak var saveToParseButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var QRImageView: UIImageView!
    
      var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        // interner kontrolü
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
        updateUserInterface()
        
    
        // Qr kod
        QRImageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(KareKodVC.selectImage))
        QRImageView.addGestureRecognizer(gestureRecognizer)
        
        
        if QRImageView.image == nil{ // qr boş ise görünecek image
            self.QRImageView.image = UIImage(named: "QRIcınDokun.png")

        }
        
      
        // loading sembolu
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorView.Style.gray
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        

    }
    override func viewWillAppear(_ animated: Bool) {
        enteringPassword()
        updateUserInterface()
    }
    // İK sonrası yapılacaklar
    func updateUserInterface() {
        guard let status = Network.reachability?.status else { return }
        switch status {
        case .unreachable:
            let alert = UIAlertController(title: "İnternet Bağlantınız Bulunmuyor.", message: "Lütfen Kontrol Edin", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
         self.saveToParseButton.isEnabled = false
            
        case .wifi:
             getQRDataFromParse()
             getObjectId()
             self.saveToParseButton.isEnabled = true
            
        case .wwan:
           getQRDataFromParse()
           getObjectId()
             self.saveToParseButton.isEnabled = true
            
        }
    }
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
    // ekran şifresi
    func enteringPassword(){
        
        let alertController = UIAlertController(title: "Şifre Girin", message: "", preferredStyle: .
            alert)
        let action = UIAlertAction(title: "Tamam", style: .default) { (action) in
            
            self.activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            let query = PFQuery(className: "BusinessInformation")
            query.whereKey("businessUserName", equalTo: "\(PFUser.current()!.username!)")
            
            query.findObjectsInBackground { (objects, error) in
                if error != nil{
                    let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
                else{
                    
                    self.screenPassword = ""
                    
                    for object in objects!{
                        
                        self.screenPassword = (object.object(forKey: "EkranSifresi") as! String)
                        
                    }
                    
                    if alertController.textFields?.first?.text! == self.screenPassword{
                        print("Şifreler eşleşiyor")
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                    }
                    else{
                        
                        self.viewWillAppear(false)
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                    }
                    
                }
            }
        }
        
        alertController.addTextField { (passwordTextField) in
            print(passwordTextField.text!)
        }
        alertController.textFields?.first?.isSecureTextEntry = true
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    // faleriden Qr seçmek
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

   
    func getQRDataFromParse(){ // eğer kayıt edilmiş Qr varsa çekmek için
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
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
        
    }
    
    // qr ın kayıtlı olduğu satırın obejct Id si
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
    // Qr resmini kayır etmek
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

