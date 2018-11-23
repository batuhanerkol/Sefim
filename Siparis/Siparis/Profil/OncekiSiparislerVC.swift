//
//  OncekiSiparislerVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 20.11.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse

class OncekiSiparislerVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var foodName = ""
    var totalPrice = ""
    var masaSayisi = ""
    var foodNameArray = [String]()
    var totalPriceArray = [String]()
    var masaSayisiArray = [String]()
    

    @IBOutlet weak var previousOrderInfoTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        previousOrderInfoTable.dataSource = self
        previousOrderInfoTable.delegate = self
//        getPreviousFoodData()
    }
    
    func getPreviousFoodData(){
        
        let query = PFQuery(className: "VerilenSiparisler")
        query.whereKey("IsletmeSahibi", equalTo: (PFUser.current()?.username)!)
        query.whereKey("HesapOdendi", equalTo: "Evet")

        
        query.findObjectsInBackground { (objects, error) in
            
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{

                self.foodNameArray.removeAll(keepingCapacity: false)
                self.totalPriceArray.removeAll(keepingCapacity: false)
                self.masaSayisiArray.removeAll(keepingCapacity: false)

                for object in objects! {
                    
                    self.foodNameArray = object["SiparisAdi"] as! [String]
                    self.totalPriceArray.append(object.object(forKey: "ToplamFiyat") as! String)
                     self.masaSayisiArray.append(object.object(forKey: "MasaNo") as! String)
                    
                }
                
                self.foodName = self.foodNameArray.joined(separator: ",")
                self.totalPrice = "\(self.totalPriceArray.last!)"
                
                self.previousOrderInfoTable.reloadData()
            }
        }
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OncekiSiparisler", for: indexPath) as! OncekiSiparislerTVC
        cell.foodNameLabel.text = foodName
         cell.totalPriceLabel.text = totalPrice
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500
    }
    
}
