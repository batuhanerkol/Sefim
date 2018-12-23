//
//  FoodInformationShowVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 8.09.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse

class FoodInformationShowVC: UIViewController {

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var foodText: UITextView!
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var foodLabel: UILabel!
    
    var selectedFood = ""
    var foodNameArray = [String]()
    var foodInformationArray = [String]()
    var foodPriceArray = [String]()
    var fooduuid = [String]()
    var imageArray = [PFFile]()
    
      var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
        updateUserInterface()
        
     
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
            
        case .wifi:
             findFood()
        case .wwan:
             findFood()
        }
    }
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
    
    func findFood(){
        let query = PFQuery(className: "FoodInformation")
        query.whereKey("foodName", equalTo: self.selectedFood)
        
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
                self.foodNameArray.removeAll(keepingCapacity: false)
                self.foodInformationArray.removeAll(keepingCapacity: false)
                self.foodPriceArray.removeAll(keepingCapacity: false)
                self.imageArray.removeAll(keepingCapacity: false)
                
                for object in objects!{
                      self.foodNameArray.append(object.object(forKey: "foodName") as! String)
                      self.foodInformationArray.append(object.object(forKey: "foodInformation") as! String)
                      self.foodPriceArray.append(object.object(forKey: "foodPrice") as! String)
                      self.imageArray.append(object.object(forKey: "image") as! PFFile)
                    
                    self.foodLabel.text = "\(self.foodNameArray.last!)"
                    self.foodText.text = "\(self.foodInformationArray.last!)"
                    self.priceLabel.text = "\(self.foodPriceArray.last!)"
                    
                    self.imageArray.last?.getDataInBackground(block: { (data, error) in
                        if error != nil{
                            let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                            alert.addAction(okButton)
                            self.present(alert, animated: true, completion: nil)
                            
                            self.activityIndicator.stopAnimating()
                            UIApplication.shared.endIgnoringInteractionEvents()
                    }
                        else{
                            self.foodImage.image = UIImage(data: (data)!)
                        }
                })
                
                }
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
}
}
}
}
