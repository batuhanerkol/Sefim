//
//  HammaddeVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 23.12.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse

class HammaddeVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    
     var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    var hammaddeAdiArray = [String]()
    var harcananHammadde = [Double]()
    
    var hammaddeKalanMiktarArray = [String]()
    
    var chosenHammadde = ""
    

    @IBOutlet weak var hammaddeTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        hammaddeTableView.delegate = self
        hammaddeTableView.dataSource = self
        navigationItem.hidesBackButton = true
        // interenet kontorlü
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
        //updateUserInterface()
        
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
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    // ık sonrası yapılacaklar
    func updateUserInterface() {
        guard let status = Network.reachability?.status else { return }
        switch status {
        case .unreachable:
            let alert = UIAlertController(title: "İnternet Bağlantınız Bulunmuyor.", message: "Lütfen Kontrol Edin", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
            
            
        
        case .wifi:
         
            if PFUser.current()?.username != nil{
                getFoodNames()
                getHammaddeInfo()
            }
        case .wwan:
    
            if PFUser.current()?.username != nil{
                getFoodNames()
                getHammaddeInfo()
                
            }
        }
    }
    
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
    
    func getHammaddeInfo(){
        // Remove arrays
        hammaddeAdiArray.removeAll(keepingCapacity: false)
        hammaddeKalanMiktarArray.removeAll(keepingCapacity: false)
        allHammaddeBigArray.removeAll(keepingCapacity: false)
        allHammaddeArray.removeAll(keepingCapacity: false)
        allHammaddeMiktarBigArray.removeAll(keepingCapacity: false)
        allHammaddeMiktarBigArray.removeAll(keepingCapacity: false)
        harcananHammadde.removeAll(keepingCapacity: false)
        // Start Query
        let query = PFQuery(className: "HammaddeBilgileri")
        query.whereKey("HammaddeSahibi", equalTo: "\(PFUser.current()!.username!)")
        query.findObjectsInBackground { (objects, error) in
            
            if error != nil{
                self.alertMessage(title: "HATA", message: (error?.localizedDescription)!)
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
            else{
                self.hammaddeAdiArray.removeAll(keepingCapacity: false)
                 self.hammaddeKalanMiktarArray.removeAll(keepingCapacity: false)
                for object in objects! {
                    self.hammaddeAdiArray.append(object.object(forKey: "HammaddeAdi") as! String)
                     self.hammaddeKalanMiktarArray.append(object.object(forKey: "HammaddeMiktariGr") as! String)
                }
                
                for _ in self.hammaddeAdiArray {
                    self.harcananHammadde.append(0)
                }
                print("Harcanan hammadde init", self.harcananHammadde)
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                
               // self.hammaddeTableView.reloadData()
                
                print("---Fonksiyon çağırıldı(getHarcanan)")
                self.getHarcananHammadde()
            }
            
        }
        
    }
    // Yemek isimleri çekiliyor
    var foodNamesArray = [String]()
    func getFoodNames(){
        foodNamesArray.removeAll()
        let query = PFQuery(className: "FoodInformation")
        query.whereKey("foodNameOwner", equalTo: (PFUser.current()?.username)!)
        query.whereKey("HesapOnaylandi", equalTo: "Evet")
        query.findObjectsInBackground { (objects, error) in
            if error != nil {
                
            } else {
                
                for object in objects! {
                    self.foodNamesArray.append(object.object(forKey: "foodName") as! String)
                }
            }
        }
        
    }
    // Tüm hammadde ve sayıları arrayleri
    var allHammaddeBigArray = [[String]]()
    var allHammaddeArray = [String]()
    var allHammaddeMiktarBigArray = [[String]]()
    var allHammaddeMiktarArray = [String]()
    var doubledMiktarAray = [[Double]]()
    
    func getHarcananHammadde(){
        allHammaddeBigArray.removeAll(keepingCapacity: false)
        allHammaddeArray.removeAll(keepingCapacity: false)
        allHammaddeMiktarBigArray.removeAll(keepingCapacity: false)
        allHammaddeMiktarBigArray.removeAll(keepingCapacity: false)
        doubledMiktarAray.removeAll(keepingCapacity: false)
        
        let query = PFQuery(className:  "FoodInformation")
        query.whereKey("HesapOnaylandi", equalTo: "Evet")
        query.whereKey("foodNameOwner", equalTo: (PFUser.current()?.username)!)
        query.findObjectsInBackground { (objects, error) in
            if error != nil {
                self.alertMessage(title: "Hata", message: "Bir hata oluştu")
            } else {
                for object in objects! {
                    if object["Hammadde"] != nil && object["HammaddeMiktarlari"] != nil {
                        self.allHammaddeBigArray.append(object["Hammadde"] as! [String])
                        self.allHammaddeMiktarBigArray.append(object["HammaddeMiktarlari"] as! [String])
                    }
                }
                // miktarı int arraye çeviriyor
                
                for _ in self.allHammaddeMiktarBigArray.indices {
                    self.doubledMiktarAray.append([])
                }
                
                for i in self.doubledMiktarAray.indices {
                    for stringedValue in self.allHammaddeMiktarBigArray[i] {
                        self.doubledMiktarAray[i].append(Double(stringedValue)!)
                    }
                }
                
                self.getPaidFoodStock()
                
            }
        }
    }
    
    // Tüm siparişlerdeki yemek adları çekiliyor
    var odendiSiparisArray = [[String]]()
    var tumSiparisler = [String]()
    
    @objc func getPaidFoodStock() {
        odendiSiparisArray.removeAll()
        tumSiparisler.removeAll()
        let query = PFQuery(className: "VerilenSiparisler")
        query.whereKey("IsletmeSahibi", equalTo: (PFUser.current()?.username)!)
        query.whereKey("HesapOdendi", equalTo: "Evet")
        query.addDescendingOrder("createdAt")
        query.findObjectsInBackground { (objects, error) in
            if error != nil {
                
            } else {
                self.tumSiparisler.removeAll()
                for object in objects! {
                    self.odendiSiparisArray.append(object["SiparisAdi"] as! [String])
                    
                }
                for tekArray in self.odendiSiparisArray {
                    for tekUrun in tekArray  {
                        self.tumSiparisler.append(tekUrun)
                    }
                }
                self.getHarcanan()
            }
            
        }
        
    }
    
    var newYemekIcerik = [[[String:Double]]]()
    
    func getHarcanan() {
        
        newYemekIcerik.removeAll(keepingCapacity: false)
        // -------- initializing the array --------
        for _ in allHammaddeBigArray {
            newYemekIcerik.append([["":0]])
        }
        
        for ham in allHammaddeBigArray.indices {
            if allHammaddeBigArray[ham].count > 1 {
                for _ in 1...(allHammaddeBigArray[ham].count - 1) {
                    newYemekIcerik[ham].append(["":0])
                }
            }
        }
        //--------- end of initialing -------------
        //-----------------------------------------
        //--------- filling the newYemekIcerik ---
        
        // TODO: REMOVE ALL ARRAYS !!!!!
        
        for arrayIndex in allHammaddeBigArray.indices {
            for i in 0...(allHammaddeBigArray[arrayIndex].count - 1) {
                newYemekIcerik[arrayIndex][i] = ["\(allHammaddeBigArray[arrayIndex][i])": doubledMiktarAray[arrayIndex][i]]
            }
        }
       
        
        for siparis in tumSiparisler {
            for yemekIndex in foodNamesArray.indices {
                if siparis == foodNamesArray[yemekIndex] {
                    for hammaddeIndex in self.hammaddeAdiArray.indices {
                        for icerik in newYemekIcerik[yemekIndex] {
                            if icerik[self.hammaddeAdiArray[hammaddeIndex]] != nil {
                                harcananHammadde[hammaddeIndex] += icerik[self.hammaddeAdiArray[hammaddeIndex]]!
                            }
                        }
                    }
                }
            }
        }
        
        print("Hammadde adı", self.hammaddeAdiArray)
        print("harcanan hammadde ",harcananHammadde)
        calculateKalanHammadde()
    }
    
    func calculateKalanHammadde(){
        print("İşlem tamam")
        
        var maddeMiktarıDoubleArray = [Double]()
        maddeMiktarıDoubleArray.removeAll(keepingCapacity: false)
        for mad in self.hammaddeKalanMiktarArray {
            let a = Double(mad)
            maddeMiktarıDoubleArray.append(a!)
        }
        for i in harcananHammadde.indices {
            harcananHammadde[i] = harcananHammadde[i] / 1000
        }
        // Substract arrays
        for i in hammaddeKalanMiktarArray.indices {
            let total = String(maddeMiktarıDoubleArray[i] - harcananHammadde[i])
            hammaddeKalanMiktarArray[i] = total
        }
        self.hammaddeTableView.reloadData()
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return hammaddeAdiArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HammaddeCell", for: indexPath) as! HammaddeCell
        cell.hammaddeNameLAbel.text = hammaddeAdiArray[indexPath.row]
        cell.hammaddeKalanLabel.text = hammaddeKalanMiktarArray[indexPath.row]
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "hammaddeDetails"{
            let destinationVC = segue.destination as! HammaddeDetails
            destinationVC.selectedHammadde = self.chosenHammadde
        }
    }

     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.chosenHammadde = hammaddeAdiArray[indexPath.row]
    
       // self.performSegue(withIdentifier: "hammaddeDetails", sender: nil)
        
    }
    

}
