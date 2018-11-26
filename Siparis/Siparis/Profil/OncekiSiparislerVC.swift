//
//  OncekiSiparislerVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 20.11.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse
var globalDateOncekiSparisler = ""
var globalTimeOncekiSiparisler = ""

class OncekiSiparislerVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var dateArray = [String]()
    var timeArray = [String]()
    var totalPriceArray = [String]()
    var paymentArray = [String]()
    

    @IBOutlet weak var previousOrderInfoTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        previousOrderInfoTable.dataSource = self
        previousOrderInfoTable.delegate = self
       getFoodDateTimeData()
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
                self.present(alert, animated: true, completion: nil)
            }
            else{

                self.dateArray.removeAll(keepingCapacity: false)
                self.timeArray.removeAll(keepingCapacity: false)
                self.totalPriceArray.removeAll(keepingCapacity: false)
                self.paymentArray.removeAll(keepingCapacity: false)

                for object in objects! {
                    
                    self.dateArray.append(object.object(forKey: "Date") as! String)
                    self.timeArray.append(object.object(forKey: "Time") as! String)
                    self.totalPriceArray.append(object.object(forKey: "ToplamFiyat") as! String)
                    self.paymentArray.append(object.object(forKey: "HesapIstendi") as! String)
                    
                }
                self.previousOrderInfoTable.reloadData()
            }
        }
    }
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        globalDateOncekiSparisler = dateArray[indexPath.row]
        globalTimeOncekiSiparisler = timeArray[indexPath.row]
        
        performSegue(withIdentifier: "foodDetails", sender: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dateArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DateTimeCell", for: indexPath) as! DateTimeCell
        
   if indexPath.row < dateArray.count && indexPath.row < timeArray.count {
    
            cell.dateLabel.text = dateArray[indexPath.row]
            cell.timeLabel.text = timeArray[indexPath.row]
            cell.sumPriceLabel.text = totalPriceArray[indexPath.row]
            cell.paymentLabel.text = paymentArray[indexPath.row]
 
        }
          return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}
