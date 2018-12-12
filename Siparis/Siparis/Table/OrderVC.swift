//
//  OrderVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 11.12.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse

var globalBusinessNameOrderVC = ""

class OrderVC: UIViewController,UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var sendKitchenButton: UIButton!
    @IBOutlet weak var hasPaidButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var orderTable: UITableView!
    @IBOutlet weak var tableNumberLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    let currentDateTime = Date()
    let formatter = DateFormatter()
    let formatterTime = DateFormatter()
    
     var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    var foodNameArray = [String]()
    var priceArray = [String]()
    var orderNoteArray = [String]()
    var objectIdArray = [String]()
    var checkFoodNamesArray = [String]()
    var deliveredOrderNumberArray = [String]()
    var hesapOdendiArray = [String]()
    
    var siparisIndexNumber = 0
    var totalPrice = 0
    var objectId = ""
    var businessName = ""
  
    var deliveredOrderNumber = ""
    var hesapOdendi = ""
    
    
   var editingStyleCheck = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateTime()
        
        //internet bağlantı kontrolü
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
        updateUserInterface()
        
        // loading sembolu
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorView.Style.gray
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        orderTable.dataSource = self
        orderTable.delegate = self

        tableNumberLabel.text = globalChosenTableNumberMasaVC
     
    }
    override func viewWillAppear(_ animated: Bool) {
        dateTime()
    }
    func dateTime(){
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        let loc = Locale(identifier: "tr")
        formatter.locale = loc
        let dateString = formatter.string(from: currentDateTime)
        dateLabel.text! = dateString
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        timeLabel.text = ("\(hour)  \(minute)")
    }
    
    
    func updateUserInterface() {
        guard let status = Network.reachability?.status else { return }
        switch status {
        case .unreachable:
            let alert = UIAlertController(title: "İnternet Bağlantınız Bulunmuyor.", message: "Lütfen Kontrol Edin", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
            
            self.sendKitchenButton.isEnabled = false
            self.cancelButton.isEnabled = false
            self.hasPaidButton.isEnabled = false

        case .wifi:
            getOrderData()
            getObjectId()
            checkGivenOrder()
            getDeliveredORrderNumber()
            
            self.sendKitchenButton.isEnabled = true
            self.cancelButton.isEnabled = true
            self.hasPaidButton.isEnabled = true
            
        case .wwan:
            getOrderData()
            getObjectId()
            checkGivenOrder()
            getDeliveredORrderNumber()
            
            self.sendKitchenButton.isEnabled = true
            self.cancelButton.isEnabled = true
            self.hasPaidButton.isEnabled = true
        
        }
    }
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
    
    func calculateSumPrice(){
        
        totalPrice = 0
        
        for string in priceArray{
            if string != "" {
                let myInt = Int(string)!
                totalPrice = totalPrice + myInt
            }
        }
        totalPriceLabel.text = String(totalPrice)
        
    }
    
    func getOrderData(){
        
        let query = PFQuery(className: "Siparisler")
        query.whereKey("SiparisSahibi", equalTo: (PFUser.current()?.username)!)
        query.whereKey("MasaNumarasi", equalTo: globalChosenTableNumberMasaVC)
        query.whereKey("IsletmeSahibi", equalTo:(PFUser.current()?.username)!)
        query.whereKey("HesapOdendi", notEqualTo: "Evet")
        
        query.findObjectsInBackground { (objects, error) in
            
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                self.foodNameArray.removeAll(keepingCapacity: false)
                self.priceArray.removeAll(keepingCapacity: false)
                self.orderNoteArray.removeAll(keepingCapacity: false)
                self.businessName = ""
                for object in objects! {
                    self.foodNameArray.append(object.object(forKey: "SiparisAdi") as! String)
                    self.priceArray.append(object.object(forKey: "SiparisFiyati") as! String)
                    self.orderNoteArray.append(object.object(forKey: "YemekNotu") as! String)
                    self.businessName = (object.object(forKey: "IsletmeAdi") as! String)
                    
                    
                }
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                
                self.orderTable.reloadData()
                
                self.editingStyleCheck = false
                
                self.calculateSumPrice()
                globalBusinessNameOrderVC = self.businessName
            }
          
            
        }
        
    }
    
    func getObjectId(){
        let query = PFQuery(className: "Siparisler")
        query.whereKey("SiparisSahibi", equalTo: (PFUser.current()?.username)!)
        query.whereKey("IsletmeSahibi", equalTo: (PFUser.current()?.username)!)
        query.whereKey("MasaNumarasi", equalTo: globalChosenTableNumberMasaVC)
        
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
                    
                }
            }
        }
    }
    
    func deleteData(oderIndex : String){ // KAYDIRARAK SİLMEK İÇİN
        let query = PFQuery(className: "Siparisler")
        query.whereKey("SiparisDurumu", equalTo: "")
        query.whereKey("objectId", equalTo: objectId)
        
        query.findObjectsInBackground { (objects, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else {
                self.foodNameArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    
                    object.deleteInBackground(block: { (sucess, error) in
                        if error != nil{
                            let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                            alert.addAction(okButton)
                            self.present(alert, animated: true, completion: nil)
                        }
                    })
                }
                
               
                self.orderTable.reloadData()
                
            }
        }
    }
   
    
    func deleteGivenOrderData(){ // BÜTÜN SİPARİŞİ SİLMEK İÇİN
        
        let query = PFQuery(className: "Siparisler")
        query.whereKey("SiparisSahibi", equalTo: (PFUser.current()!.username!))
        query.whereKey("MasaNumarasi", equalTo: globalChosenTableNumberMasaVC)
        query.whereKey("IsletmeSahibi", equalTo: (PFUser.current()!.username!))
        query.whereKey("SiparisDurumu", equalTo: "")
        
        query.findObjectsInBackground { (objects, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else {
                self.foodNameArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    object.deleteInBackground()
                    
                    self.totalPriceLabel.text = ""
                    self.orderTable.reloadData()
                }
                
            }
        }
    }

    func uploadOrderData(){
        
        getOrderData()
        self.sendKitchenButton.isEnabled = false
    
        if orderTable.visibleCells.isEmpty == false && foodNameArray.isEmpty == false && priceArray.isEmpty == false && orderNoteArray.isEmpty == false && self.businessName != "" {
            
            let object = PFObject(className: "VerilenSiparisler")
            
            object["SiparisAdi"] = foodNameArray
            object["SiparisFiyati"] = priceArray
            object["IsletmeSahibi"] = PFUser.current()?.username!
            object["SiparisSahibi"] = PFUser.current()?.username!
            object["MasaNo"] = globalChosenTableNumberMasaVC
            object["ToplamFiyat"] = totalPriceLabel.text!
            object["IsletmeAdi"] = self.businessName
            object["YemekNotu"] = orderNoteArray
            object["Date"] = dateLabel.text!
            object["Time"] = timeLabel.text!
            object["HesapOdendi"] = ""
            object["HesapIstendi"] = ""
            object["SiparisVerildi"] = "Evet"
            object["YapilanYorum"] = ""
            object["LezzetBegeniDurumu"] = ""
            object["HizmetBegenilmeDurumu"] = ""
            object["YemekTeslimEdildi"] = ""
            object["YemekHazir"] = ""
            object["TeslimEdilenSiparisSayisi"] = "0"
            
            object.saveInBackground { (success, error) in
                if error != nil{
                    let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                }
                    
                else{
                    let alert = UIAlertController(title: "Mutfağa İletilmiştir", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                    
                    
                    while self.siparisIndexNumber < self.foodNameArray.count{
                        self.siparislerChangeSituation()
                        self.siparisIndexNumber += 1
                    }
                }
            }
            
        }else{
            
            let alertController = UIAlertController(title: "Lütfen Tekrar Deneyin", message: "", preferredStyle: .alert)
            
            // Create the actions
            let okAction = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.default) {
                UIAlertAction in
                
                self.getOrderData()
            }
            
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
    
    func siparislerChangeSituation(){ //sipariş verildiğinde parse -> siparisler den eski siparislerin durumunu teslim edildi yapmak için
        
        let query = PFQuery(className: "Siparisler")
        query.whereKey("SiparisSahibi", equalTo: (PFUser.current()?.username)!)
        query.whereKey("MasaNumarasi", equalTo: globalChosenTableNumberMasaVC)
        query.whereKey("IsletmeSahibi", equalTo: (PFUser.current()?.username)!)
        query.whereKeyExists("SiparisDurumu")
        
        query.getObjectInBackground(withId: objectIdArray[siparisIndexNumber]) { (objects, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else {
                if  self.dateLabel.text! != "" && self.timeLabel.text! != ""{
                    objects!["SiparisDurumu"] = "Verildi"
                    objects!["Date"] = self.dateLabel.text!
                    objects!["Time"] = self.timeLabel.text!
                    objects!.saveInBackground(block: { (success, error) in
                        if error != nil{
                            let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                            alert.addAction(okButton)
                            self.present(alert, animated: true, completion: nil)
                        }
                    })
                    
                }
            }
        }
        
    }
    
    func checkGivenOrder(){ // hesabın ödenmediğinden emin olmak ve verilmiş sipariş sayısına bakmak için
        
        let query = PFQuery(className: "VerilenSiparisler")
        query.whereKey("SiparisSahibi", equalTo: (PFUser.current()?.username)!)
        query.whereKey("IsletmeSahibi", equalTo: (PFUser.current()?.username)!)
        query.whereKey("MasaNo", equalTo: globalChosenTableNumberMasaVC)
//        query.whereKey("IsletmeAdi", equalTo: self.businessName)
        query.whereKey("HesapOdendi", equalTo: "")
        
        
        query.findObjectsInBackground { (objects, error) in
            
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
                
                self.orderTable.reloadData()
            }
            else{
                
                self.hesapOdendiArray.removeAll(keepingCapacity: false)
                self.checkFoodNamesArray.removeAll(keepingCapacity: false)
                
                
                for object in objects! {
                    
                    
                    self.hesapOdendi = (object.object(forKey: "HesapOdendi") as! String)
                    self.checkFoodNamesArray = object["SiparisAdi"] as! [String]
                    
                 
                }

                
            }
            
        }
    }
    func getDeliveredORrderNumber(){ // hesabın ödenmediğinden emin olmak ve verilmiş sipariş sayısına bakmak için
        
        let query = PFQuery(className: "VerilenSiparisler")
        query.whereKey("SiparisSahibi", equalTo: (PFUser.current()?.username)!)
        query.whereKey("IsletmeSahibi", equalTo: (PFUser.current()?.username)!)
        query.whereKey("MasaNo", equalTo: globalChosenTableNumberMasaVC)
//        query.whereKey("IsletmeAdi", equalTo: businessName)
        query.whereKey("HesapOdendi", equalTo: "")
        
        
        query.findObjectsInBackground { (objects, error) in
            
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
                
                self.orderTable.reloadData()
            }
            else{
                
                self.deliveredOrderNumberArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    
                    self.deliveredOrderNumberArray.append(object.object(forKey: "TeslimEdilenSiparisSayisi") as! String)
                    
                    self.deliveredOrderNumber = "\(self.deliveredOrderNumberArray.last!)"
                }
               
            }
            
        }
    }
    func deletePreviousOrder(){
        
        let query = PFQuery(className: "VerilenSiparisler")
        query.whereKey("SiparisSahibi", equalTo: (PFUser.current()?.username)!)
        query.whereKey("IsletmeSahibi", equalTo: (PFUser.current()?.username)!)
        query.whereKey("MasaNo", equalTo: tableNumberLabel.text!)
//        query.whereKey("IsletmeAdi", equalTo: businessName)
        query.whereKey("HesapOdendi", equalTo: "")
        
        
        query.findObjectsInBackground { (objects, error) in
            
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
                
            }
            else{
                for object in objects! {
                    object.deleteInBackground(block: { (success, error) in
                        
                        if error != nil{
                            let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                            alert.addAction(okButton)
                            self.present(alert, animated: true, completion: nil)
                            
                        }else{
                     
                            self.uploadOrderDataWithDeliveredOrderNumber()
                           
                        }
                    })
                }
            }
        }
    }
    
    func uploadOrderDataWithDeliveredOrderNumber(){
        
        getOrderData()
        self.sendKitchenButton.isEnabled = false
        
        if orderTable.visibleCells.isEmpty == false && foodNameArray.isEmpty == false && priceArray.isEmpty == false && orderNoteArray.isEmpty == false && businessName != "" {
            
            let object = PFObject(className: "VerilenSiparisler")
            
            object["SiparisAdi"] = foodNameArray
            object["SiparisFiyati"] = priceArray
            object["IsletmeSahibi"] = PFUser.current()?.username!
            object["SiparisSahibi"] = PFUser.current()?.username!
            object["MasaNo"] = globalChosenTableNumberMasaVC
            object["ToplamFiyat"] = totalPriceLabel.text!
            object["IsletmeAdi"] = businessName
            object["YemekNotu"] = orderNoteArray
            object["Date"] = dateLabel.text!
            object["Time"] = timeLabel.text!
            object["HesapOdendi"] = ""
            object["HesapIstendi"] = ""
            object["SiparisVerildi"] = "Evet"
            object["YapilanYorum"] = ""
            object["LezzetBegeniDurumu"] = ""
            object["HizmetBegenilmeDurumu"] = ""
            object["YemekTeslimEdildi"] = ""
            object["YemekHazir"] = ""
            object["TeslimEdilenSiparisSayisi"] = deliveredOrderNumber
            
            object.saveInBackground { (success, error) in
                if error != nil{
                    let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                }
                    
                else{
                    let alert = UIAlertController(title: "Mutfak Siparişine Eklenmiştir", message: "", preferredStyle: UIAlertController.Style.alert)
                    let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                    
                    
                    while self.siparisIndexNumber < self.foodNameArray.count{
                        self.siparislerChangeSituation()
                        self.siparisIndexNumber += 1
                    }
                }
            }
            
        }else{
            
            let alertController = UIAlertController(title: "Lütfen Tekrar Deneyin", message: "", preferredStyle: .alert)
            
            // Create the actions
            let okAction = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.default) {
                UIAlertAction in
                
                self.getOrderData()
            }
            
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
    
    @IBAction func sendToKitchenButtonPressed(_ sender: Any) {
        
        checkGivenOrder()
        print("FoodnameArra:", foodNameArray)
        print("checkFoodNamesArray:", checkFoodNamesArray)
        print("hesapOdendi:", hesapOdendi)
        print("deliveredOrderNumberArray:", deliveredOrderNumberArray)
        
    
        if self.foodNameArray.isEmpty == false && self.checkFoodNamesArray != self.foodNameArray {
            
            if self.deliveredOrderNumberArray.isEmpty == true{
                uploadOrderData()
                
            }
            else if  self.deliveredOrderNumberArray.isEmpty == false {
                
                print("DEvieredArray", self.deliveredOrderNumberArray.last!)
                deletePreviousOrder()
                
            }
            
            
        }
        else{
            let alert = UIAlertController(title: "Siparişiniz Boş veya Bir Değişiklik Yapılmamış", message: "", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
        
        
    }
        
    @IBAction func cancelButtonPressed(_ sender: Any) {
       deleteGivenOrderData()
    }
    
        
        
        
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = foodNameArray[sourceIndexPath.row]
        foodNameArray.insert(item, at: destinationIndexPath.row)
        foodNameArray.remove(at: sourceIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && editingStyleCheck == true{
            
            objectId = objectIdArray[indexPath.row]
            deleteData(oderIndex: objectId)
            
        }
    }
    
 
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodNameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath) as! OrderCell
        //index out or range hatası almamak için
        if indexPath.row < foodNameArray.count {
            cell.foodNameLabel.text = foodNameArray[indexPath.row]
            cell.foodPriceLabel.text = priceArray[indexPath.row]
         
        }
           return cell
        }
}
