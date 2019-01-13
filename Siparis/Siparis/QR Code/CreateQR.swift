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
   
    // arşive kayıt
    @IBAction func saveToPhotoButtonPressed(_ sender: Any) {
        
        UIGraphicsBeginImageContext(imageView.frame.size)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let output = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        UIImageWriteToSavedPhotosAlbum(output!, nil, nil, nil)
        
        let alert = UIAlertController(title: "QR Fotoğraflara Kaydedildi", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Tamam", style: UIAlertActionStyle.default) {
            UIAlertAction in
            NSLog("OK Pressed")
            self.performSegue(withIdentifier: "CreateQRToKareKodVC", sender: nil)
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
 
        saveToPhotoButton.isHidden = true
        
     
    }
}
