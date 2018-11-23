//
//  DateTimeCell.swift
//  Siparis
//
//  Created by Batuhan Erkol on 23.11.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse

class DateTimeCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
   

    var priceArray = [String]()
    var foodNameArray = [String]()
    
    @IBOutlet weak var foodNamesTable: UITableView!
    @IBOutlet weak var sumPriceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        foodNamesTable.delegate  = self
        foodNamesTable.dataSource = self
        
        getFoodDateTimeData()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func getFoodDateTimeData(){
        
        let query = PFQuery(className: "VerilenSiparisler")
        query.whereKey("IsletmeSahibi", equalTo: (PFUser.current()?.username)!)
        query.whereKey("HesapOdendi", equalTo: "Evet")
        query.addDescendingOrder("createdAt")
        
        
        query.findObjectsInBackground { (objects, error) in
            
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
//                self.present(alert, animated: true, completion: nil)
            }
            else{
                
               
                self.foodNameArray.removeAll(keepingCapacity: false)
                self.priceArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    
                  self.foodNameArray = object["SiparisAdi"] as! [String]
                   self.priceArray = object["SiparisFiyati"] as! [String]
                    
                }
                print("foodname:", self.foodNameArray)
                self.foodNamesTable.reloadData()
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodNameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodAndPriceCell", for: indexPath) as! FoodAndPriceCell
        
        if indexPath.row < foodNameArray.count && indexPath.row < priceArray.count {
            
            cell.foodNameLabel.text = foodNameArray[indexPath.row]
            cell.priceLabel.text = priceArray[indexPath.row]
 
        }
        return cell
    }
    
}
