//
//  PreviousOrdersInformationVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 26.11.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse

class PreviousOrdersInformationVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var foodNameArray = [String]()
    var foodPriceArray = [String]()
    var yorumArray = [String]()
    var hizmetArray = [String]()
    var lezzetArray = [String]()
  
    @IBOutlet weak var yorumLabel: UILabel!
    @IBOutlet weak var deliciousLabel: UILabel!
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var foodNameTable: UITableView!
    
       var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
        updateUserInterface()
        
        foodNameTable.dataSource = self
        foodNameTable.delegate = self
        
    
     
        // loading sembolu
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorView.Style.gray
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
 
       
    }
    // Ik sonrası işlemler
    func updateUserInterface() {
        guard let status = Network.reachability?.status else { return }
        switch status {
        case .unreachable:
            let alert = UIAlertController(title: "İnternet Bağlantınız Bulunmuyor.", message: "Lütfen Kontrol Edin", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
            
        case .wifi:
            getFoodInfo()
        case .wwan:
              getFoodInfo()
        }
    }
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
    func getFoodInfo(){
        
        let query = PFQuery(className: "VerilenSiparisler")
        query.whereKey("IsletmeSahibi", equalTo: (PFUser.current()?.username)!)
        query.whereKey("HesapOdendi", equalTo: "Evet")
        query.whereKey("Date", equalTo: globalDateOncekiSparisler)
        query.whereKey("Time", equalTo: globalTimeOncekiSiparisler)
        query.whereKey("ToplamFiyat", equalTo: globaTotalPriceOncekiSiparisler)
        query.addDescendingOrder("createdAt")
        
        
        query.findObjectsInBackground { (objects, error) in
            
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                
               
                self.foodNameArray.removeAll(keepingCapacity: false)
                self.foodPriceArray.removeAll(keepingCapacity: false)
                self.yorumArray.removeAll(keepingCapacity: false)
                self.hizmetArray.removeAll(keepingCapacity: false)
                self.lezzetArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    
                    self.foodNameArray = object["SiparisAdi"] as! [String]
                    self.foodPriceArray = object["SiparisFiyati"] as! [String]
                    self.yorumArray.append(object.object(forKey: "YapilanYorum") as! String)
                    self.hizmetArray.append(object.object(forKey: "HizmetBegenilmeDurumu") as! String)
                    self.lezzetArray.append(object.object(forKey: "LezzetBegeniDurumu") as! String)
            
                    self.yorumLabel.text = self.yorumArray.last!
                    self.deliciousLabel.text = self.lezzetArray.last!
                    self.serviceLabel.text = self.hizmetArray.last!
                    
                }
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                self.foodNameTable.reloadData()
                
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
            return self.foodNameArray.count
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "FoodPriceCell", for: indexPath) as! FoodPriceCell
            cell.foodNameLabel.text = foodNameArray[indexPath.row]
            cell.foodPriceLabel.text = foodPriceArray[indexPath.row]
            
            return cell
       
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }


}
