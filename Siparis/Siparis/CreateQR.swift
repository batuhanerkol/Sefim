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

class CreateQR: UIViewController{

    @IBOutlet weak var saveToPhotoButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       createButton.isHidden = false
    
    }
    @IBAction func createButtonClicked(_ sender: Any) {
        creatQRCode()
        uploadQRInformation()
        
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
    func uploadQRInformation(){
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
                print("QR kayıt edildi")
            }
            
        }
        
       
    }
    
    func saveToPhotoLibrary(){
        
        do {
            let imageUrl = URL(string: PFUser.current()!.username!)
            let imageData = try Data(contentsOf: imageUrl!)
            let image = UIImage(data: imageData)
            
            let imagePngData = UIImagePNGRepresentation(image!)
            let savedImage = UIImage(data: imagePngData!)
            UIImageWriteToSavedPhotosAlbum(savedImage!, nil, nil, nil)
        }
        catch{
            print(error)
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

     
    }
  
    
}
