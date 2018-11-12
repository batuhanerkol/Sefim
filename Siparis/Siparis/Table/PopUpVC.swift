//
//  PopUpVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 20.10.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse

protocol SetTableButtonColor {
    func setTableButtonColor()
}

var globalChosenTableNumberColor = 0

class PopUpVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var delegate : SetTableButtonColor?
    
    var businessNameArray = [String]()
    var foodNameArray = [String]()
    var priceArray = [String]()
    var orderNoteArray = [String]()
    var dateArray = [String]()
    var timeArray =  [String]()
    var tableNumberArray = [String]()
    var totalPriceArray = [String]()
    var objectIdArray = [String]()
    var hesapOdendiArray = [String]()
    
     var tableNumber = ""
     var objectId = ""
     var chosenBusiness = ""
     var chosenDate = ""
     var chosenTime = ""
     var hesapOdendi = ""
    
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var tableNumberLabel: UILabel!
    @IBOutlet weak var orderTableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        orderTableView.delegate = self
        orderTableView.dataSource = self
        
    }
    override func viewWillAppear(_ animated: Bool) {
        getTableNumberData()
           checkHesap()
    }
   
   
    func getTableNumberData(){
        
        let query = PFQuery(className: "VerilenSiparisler")
        query.whereKey("IsletmeSahibi", equalTo: (PFUser.current()?.username)!)
        
        query.findObjectsInBackground { (objects, error) in
            
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                
                self.tableNumberArray.removeAll(keepingCapacity: false)
                for object in objects! {
                    self.tableNumberArray.append(object.object(forKey: "MasaNo") as! String)
                }
            }
            
            self.tableNumber = self.tableNumberArray.last!
        }
    }
    func checkHesap(){
        getTableNumberData()
        tableNumberLabel.text! =  globalChosenTableNumber
        
        let query = PFQuery(className: "VerilenSiparisler")
        query.whereKey("IsletmeSahibi", equalTo: (PFUser.current()?.username)!)
        query.whereKey("MasaNo", equalTo: globalChosenTableNumber.substring(toIndex: globalChosenTableNumber.length - 1))
        query.whereKeyExists("HesapOdendi")
        
        query.findObjectsInBackground { (objects, error) in
            
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                
                self.hesapOdendiArray.removeAll(keepingCapacity: false)
                
                
                for object in objects! {
                    
                  
                    self.hesapOdendiArray.append(object.object(forKey: "HesapOdendi") as! String)
                    
                    self.hesapOdendi = "\(self.hesapOdendiArray.last!)"
                }

                if self.hesapOdendi != "Evet"{
                    self.getOrderData()
                }
            }
        }
    }
    
    func getOrderData(){
    getTableNumberData()
     tableNumberLabel.text! =  globalChosenTableNumber
        
        let query = PFQuery(className: "VerilenSiparisler")
        query.whereKey("IsletmeSahibi", equalTo: (PFUser.current()?.username)!)
        query.whereKey("MasaNo", equalTo: globalChosenTableNumber.substring(toIndex: globalChosenTableNumber.length))

        query.findObjectsInBackground { (objects, error) in

            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
               
                self.businessNameArray.removeAll(keepingCapacity: false)
                self.foodNameArray.removeAll(keepingCapacity: false)
                self.priceArray.removeAll(keepingCapacity: false)
                self.orderNoteArray.removeAll(keepingCapacity: false)
                self.dateArray.removeAll(keepingCapacity: false)
                self.timeArray.removeAll(keepingCapacity: false)
                self.totalPriceArray.removeAll(keepingCapacity: false)
                self.objectIdArray.removeAll(keepingCapacity: false)
              
            
                for object in objects! {
                 
                    self.foodNameArray = object["SiparisAdi"] as! [String]
                    self.priceArray = object["SiparisFiyati"] as! [String]
                    self.orderNoteArray = object["YemekNotu"] as! [String]
                   
                    self.businessNameArray.append(object.object(forKey: "IsletmeAdi") as! String)
                    self.totalPriceArray.append(object.object(forKey: "ToplamFiyat") as! String)
                    self.dateArray.append(object.object(forKey: "Date") as! String)
                    self.timeArray.append(object.object(forKey: "Time") as! String)
                    
                    self.objectIdArray.append(object.objectId! as String)
                    
                    self.totalPriceLabel.text = "\(self.totalPriceArray.last!)"
                    self.chosenDate = "\(self.dateArray.last!)"
                    self.chosenTime = "\(self.timeArray.last!)"
                    self.chosenBusiness = "\(self.businessNameArray.last!)"
                   self.objectId = "\(self.objectIdArray.last!)"
                }
            }
            
            self.orderTableView.reloadData()
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       dismiss(animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodNameArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PopUpTVC
        cell.foodNameLabel.text = foodNameArray[indexPath.row]
        cell.foodPriceLabel.text = priceArray[indexPath.row]
        cell.foodNoteLabel.text = orderNoteArray[indexPath.row]
        
         cell.dateLabel.text = dateArray.last
         cell.timeLabel.text = timeArray.last
        return cell
    }
    @IBAction func foodIsReadyButtonClicked(_ sender: Any) {
        let alertController = UIAlertController(title: "Yemeğin Hazır Olduğuna Emin Misiniz ?", message: "", preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "Evet", style: UIAlertActionStyle.default) {
            UIAlertAction in
     
            self.delegate?.setTableButtonColor()
            
        }
        let cancelAction = UIAlertAction(title: "Hayır", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
        }
        
        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
       
    }
    @IBAction func closeButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func orderHasGivenButtonClicked(_ sender: Any) {
    }
    
    @IBAction func chechkHasPaidButtonClicked(_ sender: Any) {
        let query = PFQuery(className: "VerilenSiparisler")
        query.whereKeyExists("HesapOdendi")
        query.getObjectInBackground(withId: objectId) { (objects, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }else {
                let alertController = UIAlertController(title: "Hesabın Ödendiğinden Emin Misiniz ?", message: "", preferredStyle: .alert)
                
                // Create the actions
                let okAction = UIAlertAction(title: "Evet", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    NSLog("OK Pressed")
                    objects!["HesapOdendi"] = "Evet"
                    objects!.saveInBackground()
                }
                let cancelAction = UIAlertAction(title: "Hayır", style: UIAlertActionStyle.cancel) {
                    UIAlertAction in
                    NSLog("Cancel Pressed")
                }
                
                // Add the actions
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                
                // Present the controller
                self.present(alertController, animated: true, completion: nil)
               
            }
        }
    
    }
}


extension String {
    
    var length: Int {
        return count
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }
    
    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
    
}

    

