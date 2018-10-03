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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

  findFood()
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
                    }
                        else{
                            self.foodImage.image = UIImage(data: (data)!)
                        }
                })
                
                }
}
}
}
}
