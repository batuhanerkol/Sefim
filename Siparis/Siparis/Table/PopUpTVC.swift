//
//  PopUpTVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 20.10.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse

class PopUpTVC: UITableViewCell {

    @IBOutlet weak var doneLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var foodNoteLabel: UILabel!
    @IBOutlet weak var foodPriceLabel: UILabel!
    @IBOutlet weak var foodNameLabel: UILabel!
    
    var orderHasGivenControlArray = [String]()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
 
         checkOrderHasGiven()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

     
       
    }
    func checkOrderHasGiven(){
        let query = PFQuery(className: "VerilenSiparisler")
        query.whereKey("IsletmeSahibi", equalTo: (PFUser.current()?.username)!)
        query.whereKey("MasaNo", equalTo: globalChosenTableNumberMasaVC)
        query.whereKey("HesapOdendi", equalTo: "")
        query.addDescendingOrder("createdAt")
        
        query.findObjectsInBackground { (objects, error) in
            
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
            }
            else{
                
                self.orderHasGivenControlArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    
                    self.orderHasGivenControlArray.append(object.object(forKey: "YemekTeslimEdildi") as! String)
                    
                }
                print("orderHasGivenControlArray:", self.orderHasGivenControlArray)
                
                if self.orderHasGivenControlArray.last == "Evet"{
                    self.doneLabel.isHidden = false
                }else{
                    self.doneLabel.isHidden = true
                }
            }
        }
        
    }
}
