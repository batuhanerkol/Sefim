//
//  PopUpVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 20.10.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse

class PopUpVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
    var hesapIstendiArray = [String]()
    var yemekTeslimEdildiArray = [String]()
    
    var allFoodsNamesArray = [String]()
    var allPricesArray = [String]()
    var allNoteArray = [String]()
    var allDateArray = [String]()
    var allTimeArray = [String]()
    
    var numberOfDeliveredOrder = ""
    
     var tableNumber = ""
     var objectId = ""
     var chosenBusiness = ""
     var chosenDate = ""
     var chosenTime = ""
     var hesapOdendi = ""
     var hesapIstendi = ""
     var orderNumber = 0
     var yemekHazir = ""
    
    @IBOutlet weak var checkPaidButton: UIButton!
    @IBOutlet weak var orderHasGivenButton: UIButton!
    @IBOutlet weak var foodIsReadyButton: UIButton!
    @IBOutlet weak var hesapDurumuLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var tableNumberLabel: UILabel!
    @IBOutlet weak var orderTableView: UITableView!
    
     var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
        updateUserInterface()

        orderTableView.delegate = self
        orderTableView.dataSource = self
        
        tableNumberLabel.text = globalChosenTableNumberMasaVC
        
        
       
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
            self.checkPaidButton.isEnabled = false
            self.orderHasGivenButton.isEnabled = false
            self.foodIsReadyButton.isEnabled = false
            
            
            
        case .wifi:
            getTableNumberData()
            checkHesapToGetOrder()
            self.checkPaidButton.isEnabled = true
            self.orderHasGivenButton.isEnabled = true
            self.foodIsReadyButton.isEnabled = true
        case .wwan:
            getTableNumberData()
            checkHesapToGetOrder()
            self.checkPaidButton.isEnabled = true
            self.orderHasGivenButton.isEnabled = true
            self.foodIsReadyButton.isEnabled = true
        }
    }
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
   
   
    func getTableNumberData(){ // app açıuldığında eski girilmiş olan masa sayısını almak için
        
        let query = PFQuery(className: "BusinessInformation")
        query.whereKey("businessUserName", equalTo: (PFUser.current()?.username)!)
        query.whereKeyExists("MasaSayisi")
        
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
                    self.tableNumberArray.append(object.object(forKey: "MasaSayisi") as! String)
                }
            }
            if self.tableNumberArray.isEmpty == false{
            self.tableNumber = self.tableNumberArray.last!
            }
        }
    }
    func checkHesapToGetOrder(){ // istenen hesabın nakit-kredi kartı olduğunu görebilmek için
        let query = PFQuery(className: "VerilenSiparisler")
        query.whereKey("IsletmeSahibi", equalTo: (PFUser.current()?.username)!)
        query.whereKey("MasaNo", equalTo: globalChosenTableNumberMasaVC)
        
        query.findObjectsInBackground { (objects, error) in
            
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                
                self.hesapOdendiArray.removeAll(keepingCapacity: false)
                 self.hesapIstendiArray.removeAll(keepingCapacity: false)
                self.yemekHazir = ""
                
                
                for object in objects! {
                
                    self.hesapOdendiArray.append(object.object(forKey: "HesapOdendi") as! String)
                    self.hesapIstendiArray.append(object.object(forKey: "HesapIstendi") as! String)
                    self.yemekHazir = (object.object(forKey: "YemekHazir") as! String)
            
                    self.hesapOdendi = String(self.hesapOdendiArray.last!)
                    self.hesapIstendi = String(self.hesapIstendiArray.last!)
               
                }
                if self.hesapOdendi != "Evet"{
                  self.getOrderData()
                    if self.hesapIstendi == ""{
                        
                    }else{
                      
                        self.hesapDurumuLabel.text = self.hesapIstendiArray.joined(separator: ",") // aynı masada farklı kişiler hesap istediğinde
                    }
                }
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
        }
            
        }
       
    }
    
    func getOrderData(){ // verilen sipariş datalarını çekmek için
        
        let query = PFQuery(className: "VerilenSiparisler")
        query.whereKey("IsletmeSahibi", equalTo: (PFUser.current()?.username)!)
        query.whereKey("MasaNo", equalTo: globalChosenTableNumberMasaVC)
        query.addDescendingOrder("createdAt")

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
                
                 self.allFoodsNamesArray.removeAll(keepingCapacity: false)
                 self.allPricesArray.removeAll(keepingCapacity: false)
                 self.allNoteArray.removeAll(keepingCapacity: false)
                 self.allDateArray.removeAll(keepingCapacity: false)
                 self.allTimeArray.removeAll(keepingCapacity: false)
                
                self.numberOfDeliveredOrder = ""
            
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
                    
                    self.allFoodsNamesArray.append(contentsOf: self.foodNameArray)
                    self.allPricesArray.append(contentsOf: self.priceArray)
                    self.allNoteArray.append(contentsOf: self.orderNoteArray)
                    self.allDateArray.append(contentsOf: self.dateArray)
                    self.allTimeArray.append(contentsOf: self.timeArray)
                    
                    self.numberOfDeliveredOrder = (object.object(forKey: "TeslimEdilenSiparisSayisi") as! String)

                }
                 print("numberOfDeliveredOrder!", self.numberOfDeliveredOrder)
                
                
                if self.numberOfDeliveredOrder == "" {
                 
                   
                }
//                print("--------------------------------------------")
//                 print("allFOODNAME:", self.allFoodsNamesArray)
//                 print("allPrice:", self.allPricesArray)
//                 print("allnorte:", self.allNoteArray)
//                 print("alldate:", self.allDateArray)
//                 print("objectID:", self.objectIdArray)
                
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                 self.orderTableView.reloadData()
            }
            
          
        }
    }
  
    
    
    @IBAction func foodIsReadyButtonClicked(_ sender: Any) {
        
        orderNumber = 0
        if self.foodNameArray.isEmpty == false{
            while self.orderNumber < self.objectIdArray.count{
                
            let query = PFQuery(className: "VerilenSiparisler")
            query.whereKey("IsletmeSahibi", equalTo: (PFUser.current()?.username)!)
            query.whereKey("MasaNo", equalTo: globalChosenTableNumberMasaVC)
            query.addDescendingOrder("createdAt")
            
            query.getObjectInBackground(withId: self.objectIdArray[self.orderNumber]) { (objects, error) in
                if error != nil{
                    let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                    
                }else {

                    objects!["YemekHazir"] = "Evet"
                    objects!.saveInBackground(block: { (success, error) in
                        if error != nil{
                            let alert = UIAlertController(title: "Lütfen Tekrar Deneyin", message: "", preferredStyle: UIAlertController.Style.alert)
                            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                            alert.addAction(okButton)
                            self.present(alert, animated: true, completion: nil)
                            
                        }else{
//                            self.performSegue(withIdentifier: "ToMasaVC", sender: nil)
                            self.touchesBegan(Set<UITouch>(), with: nil)                        }
                    })
//                    let alertController = UIAlertController(title: "Yemeğin Hazır Olduğuna Emin Misiniz ?", message: "", preferredStyle: .alert)
//
//                    // Create the actions
//                    let okAction = UIAlertAction(title: "Evet", style: UIAlertActionStyle.default) {
//                        UIAlertAction in
//                        NSLog("OK Pressed")
//
//                    }
//                    let cancelAction = UIAlertAction(title: "Hayır", style: UIAlertActionStyle.cancel) {
//                        UIAlertAction in
//                        NSLog("Cancel Pressed")
//                    }
//
//                    // Add the actions
//                    alertController.addAction(okAction)
//                    alertController.addAction(cancelAction)
//
//                    // Present the controller
//                    self.present(alertController, animated: true, completion: nil)
//
                }
                
            }
               self.orderNumber += 1
        }
            
        }
        else{
            let alert = UIAlertController(title: "Yemek Listesi Boş", message: "", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
    }

    
    @IBAction func closeButtonClicked(_ sender: Any) {
       performSegue(withIdentifier: "toMasaVC", sender: nil)
    }
    
    
    
    @IBAction func orderHasGivenButtonClicked(_ sender: Any) {
        if self.yemekHazir != ""{
        orderTableView.reloadData()
        orderNumber = 0
        if self.foodNameArray.isEmpty == false{
            while self.orderNumber < self.objectIdArray.count{
                
                let query = PFQuery(className: "VerilenSiparisler")
                query.whereKey("IsletmeSahibi", equalTo: (PFUser.current()?.username)!)
                query.whereKey("MasaNo", equalTo: globalChosenTableNumberMasaVC)
                query.addDescendingOrder("createdAt")
                
                query.getObjectInBackground(withId: self.objectIdArray[self.orderNumber]) { (objects, error) in
                    if error != nil{
                        let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                        let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                        alert.addAction(okButton)
                        self.present(alert, animated: true, completion: nil)
                        
                    }else {
                      
                        objects!["YemekTeslimEdildi"] = "Evet"
                        objects!["TeslimEdilenSiparisSayisi"] = String(self.allFoodsNamesArray.count)
                        objects!.saveInBackground(block: { (success, error) in
                            if error != nil{
                                let alert = UIAlertController(title: "Lütfen Tekrar Deneyin", message: "", preferredStyle: UIAlertController.Style.alert)
                                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                                alert.addAction(okButton)
                                self.present(alert, animated: true, completion: nil)
                                
                            }
                            else{
//                                  self.performSegue(withIdentifier: "ToMasaVC", sender: nil)
                                  self.touchesBegan(Set<UITouch>(), with: nil)
                            }
                        })
        
                    }
                    
                }
                self.orderNumber += 1
            }
          
        }
        else{
            let alert = UIAlertController(title: "Yemek Listesi Boş", message: "", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
        }else{
            let alert = UIAlertController(title: "Yemek Henüz Hazırlanmadı", message: "", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func chechkHasPaidButtonClicked(_ sender: Any) {
        if self.hesapIstendi != ""{
            
        orderNumber = 0
        if self.foodNameArray.isEmpty == false{
            while self.orderNumber < self.objectIdArray.count{
                
                let query = PFQuery(className: "VerilenSiparisler")
                query.whereKey("IsletmeSahibi", equalTo: (PFUser.current()?.username)!)
                query.whereKey("MasaNo", equalTo: globalChosenTableNumberMasaVC)
                query.addDescendingOrder("createdAt")
                
                query.getObjectInBackground(withId: self.objectIdArray[self.orderNumber]) { (objects, error) in
                    if error != nil{
                        let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                        let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                        alert.addAction(okButton)
                        self.present(alert, animated: true, completion: nil)
                        
                    }else {
                        objects!["HesapOdendi"] = "Evet"
                        objects!.saveInBackground(block: { (success, error) in
                            if error != nil{
                                let alert = UIAlertController(title: "Lütfen Tekrar Deneyin", message: "", preferredStyle: UIAlertController.Style.alert)
                                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                                alert.addAction(okButton)
                                self.present(alert, animated: true, completion: nil)
                                
                            }else{
                                 self.deleteGivenOrderDataFromOwersParse()
//                                 self.performSegue(withIdentifier: "ToMasaVC", sender: nil)
                                  self.touchesBegan(Set<UITouch>(), with: nil)
                            }
                        })
                        
                    }
                    
                }

                self.orderNumber += 1
            }
           
        }
        else{
            let alert = UIAlertController(title: "Yemek Listesi Boş", message: "", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
        }else{
            let alert = UIAlertController(title: "Hesap Henüz İstenmedi", message: "", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
    }
    func deleteGivenOrderDataFromOwersParse(){ // kullanıcı siparişine ekleme yaptığında eski aray i silmek için
    
    let query = PFQuery(className: "Siparisler")
    query.whereKey("IsletmeSahibi", equalTo: "\(PFUser.current()!.username!)")
    query.whereKey("MasaNumarasi", equalTo: globalChosenTableNumberMasaVC)
    query.whereKey("SiparisDurumu", equalTo: "Verildi")
    
    query.findObjectsInBackground { (objects, error) in
    if error != nil{
    let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
    let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
    alert.addAction(okButton)
    self.present(alert, animated: true, completion: nil)
    }
    else {

    for object in objects! {
    object.deleteInBackground()

    self.orderTableView.reloadData()
    }
    
    }
    }
        
    }
    
  
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allFoodsNamesArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PopUpTVC
   
        
                if allFoodsNamesArray.count > indexPath.row && allPricesArray.count > indexPath.row && allNoteArray.count > indexPath.row{
                    
        if indexPath.row < Int(numberOfDeliveredOrder)!  {
        
                cell.doneLabel.isHidden = false
            }
                    
        cell.foodNameLabel.text = allFoodsNamesArray[indexPath.row]
        cell.foodPriceLabel.text = allPricesArray[indexPath.row]
        cell.foodNoteLabel.text = allNoteArray[indexPath.row]
    
        
        cell.dateLabel.text = allDateArray.last
        cell.timeLabel.text = allTimeArray.last
                    
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
        
    }
}



