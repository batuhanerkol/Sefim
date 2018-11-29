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
    
    var serviceArray = [String]()
    var testeArray = [String]()
    
    var liikedServiceArray = [String]()
    var likedTesteArray = [String]()
    
    var disLiikedServiceArray = [String]()
    var disLikedTesteArray = [String]()
    
    var objectIdArray = [String]()
    var objectId = ""
    
    var testePoint = 0
    var servicePoint = 0
    
    @IBOutlet weak var previousOrderInfoTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        previousOrderInfoTable.dataSource = self
        previousOrderInfoTable.delegate = self
        
      
       getFoodDateTimeData()
       calculateBusinessLikedPoint()
        getObjectId()
  
   
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
    func calculateBusinessLikedPoint(){
        let query = PFQuery(className: "VerilenSiparisler")
        query.whereKey("IsletmeSahibi", equalTo: (PFUser.current()?.username)!)
        query.whereKey("HesapOdendi", equalTo: "Evet")
        query.whereKey("LezzetBegeniDurumu", notEqualTo: "")
        query.whereKey("HizmetBegenilmeDurumu", notEqualTo: "")

        query.addDescendingOrder("createdAt")
        
        query.findObjectsInBackground { (objects, error) in
            
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                
               
                self.serviceArray.removeAll(keepingCapacity: false)
                self.testeArray.removeAll(keepingCapacity: false)
           
                
                for object in objects! {
                    
                    self.serviceArray.append(object.object(forKey: "HizmetBegenilmeDurumu") as! String)
                    self.testeArray.append(object.object(forKey: "LezzetBegeniDurumu") as! String)
                   
                }
                print("Service:", self.serviceArray)
                print("teste:", self.testeArray)
                
                self.liikedServiceArray = self.serviceArray.filter { $0 == "Evet" }
                self.disLiikedServiceArray = self.serviceArray.filter { $0 == "Hayır" }

                
                self.likedTesteArray = self.testeArray.filter { $0 == "Evet" }
                self.disLikedTesteArray = self.testeArray.filter { $0 == "Hayır" }

                self.servicePoint = (self.liikedServiceArray.count * 5) / self.serviceArray.count
                print("ServicePoint:", self.servicePoint)
                
                self.testePoint = (self.likedTesteArray.count * 5) / self.testeArray.count
                print("TestePoint:", self.testePoint)
            }
        }
    }
    func calculateBusinessDisLikedPoint(){
        let query = PFQuery(className: "VerilenSiparisler")
        query.whereKey("IsletmeSahibi", equalTo: (PFUser.current()?.username)!)
        query.whereKey("HesapOdendi", equalTo: "Evet")
        query.whereKey("LezzetBegeniDurumu", equalTo: "Hayır")
        query.whereKey("HizmetBegenilmeDurumu", equalTo: "Hayır")
        
        query.addDescendingOrder("createdAt")
        
        query.findObjectsInBackground { (objects, error) in
            
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                
                
                self.disLiikedServiceArray.removeAll(keepingCapacity: false)
                  self.disLikedTesteArray.removeAll(keepingCapacity: false)
                
                
                for object in objects! {
                    
                    self.disLiikedServiceArray.append(object.object(forKey: "HizmetBegenilmeDurumu") as! String)
                     self.disLikedTesteArray.append(object.object(forKey: "LezzetBegeniDurumu") as! String)
                    
                    
                    print("ServiceDİS:", self.disLiikedServiceArray)
                    print("TesteDİS:", self.disLikedTesteArray)
                    
                }
            }
        }
    }
    func getObjectId(){
        let query = PFQuery(className: "BusinessInformation")
        query.whereKey("businessUserName", equalTo: (PFUser.current()?.username)!)
        
        query.findObjectsInBackground { (objects, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                self.objectIdArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    self.objectIdArray.append(object.objectId!)
                    
                    self.objectId = "\(self.objectIdArray.last!)"
                }
               self.savePoints()
            }
        }
    }
    
    func savePoints(){
        print("ID:", self.objectId)
        if self.serviceArray.isEmpty == false && self.testeArray.isEmpty == false{
            
        let query = PFQuery(className: "BusinessInformation")
            query.whereKey("businessUserName", equalTo: "\(PFUser.current()!.username!)")
        
         query.getObjectInBackground(withId: objectId) { (object, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                object!["LezzetPuan"] = String(self.testePoint)
                object!["HizmetPuan"] = String(self.servicePoint)
              
                object?.saveInBackground()
            }
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
