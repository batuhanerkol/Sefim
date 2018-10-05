//
//  CreateQR.swift
//  Siparis
//
//  Created by Batuhan Erkol on 27.09.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse
import UIKit
import Photos

class CreateQR: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{

    @IBOutlet weak var saveToParseButton: UIButton!
    @IBOutlet weak var saveToPhotoButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       createButton.isHidden = false
    
    }
    @IBAction func createButtonClicked(_ sender: Any) {
        creatQRCode()
    }
    
    func creatQRCode(){
        if let QRString = PFUser.current()?.username {
            
            let data =  QRString.data(using: .ascii, allowLossyConversion: false)
            let filter = CIFilter(name: "CIQRCodeGenerator")
            filter?.setValue(data, forKey: "inputMessage")
            
            let ciImage = filter?.outputImage
            
            let transform = CGAffineTransform(scaleX: 35, y: 35)
            let transformImage = ciImage?.transformed(by: transform)
            
            let image = UIImage(ciImage: transformImage!)
            self.imageView.image = image
            
            self.createButton.isHidden = true
            
          
        }
    }
   
    
    @IBAction func saveToPhotoButtonPressed(_ sender: Any) {
        
        UIGraphicsBeginImageContext(imageView.frame.size)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let output = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        UIImageWriteToSavedPhotosAlbum(output!, nil, nil, nil)
        
        let alert = UIAlertController(title: "QR Fotoğraflara Kaydedildi", message: "", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alert.addAction(okayAction)
        self.present(alert, animated: true, completion: nil)
 
        saveToPhotoButton.isHidden = true
     
    }
   
    func uploadQRInformation(){
        
        
    }
    @IBAction func saveToParseButtonClicked(_ sender: Any) {
        
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        image.allowsEditing = false
        self.present(image, animated: true)
        
        saveToParseButton.isHidden = true
        
        let qrObject = PFObject(className: "QRInformation")
        qrObject["QROwner"] = PFUser.current()!.username!
        
        if let imageData = UIImageJPEGRepresentation(imageView.image!, 0.5){
            qrObject["QRImage"] = PFFile(name: "image.jpg", data: imageData)
        }
        qrObject.saveInBackground { (objects, error) in
            
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                
            }
            
        }
        
       
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            imageView.image = image
        }else{
            let alert = UIAlertController(title: "Lütfen Tekrar Deneyin", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
        self.dismiss(animated: true, completion: nil)
    }
}
