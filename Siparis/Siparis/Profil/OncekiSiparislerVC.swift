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
var globaTotalPriceOncekiSiparisler = ""

class OncekiSiparislerVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
   
    
    var dateArray = [String]()
    var timeArray = [String]()
    var totalPriceArray = [String]()
    var paymentArray = [String]()
    
    var serviceArray = [String]()
    var testeArray = [String]()
    
    var servisBegenildiArray = [String]()
    var lezzetBegenildiArray = [String]()
    
    var servisBegenilmediArray = [String]()
    var lezzetBegenilmediArray = [String]()
    
    var objectIdArray = [String]()
    var objectId = ""
    
    var oneMounthDateArray = [String]()
    var allMounths = ""
    
    var selectedMounthsArray = [String]()
    
    var totalLezzet: Float = 0
    var totalServis: Float = 0
    
    var servisPuan1Bas = ""
    var lezzetPuan1Bas = ""
    
    var lezzetPoint: Float = 0
    var servicePoint: Float = 0
    
    var date = ""
    
    var chosenMounth: String = ""
    
    var mounthsArray = ["Oca","Şub","Mar","Nis","May","Haz","Tem","Ağu","Eyl","Eki","Kas","Ara"]
    
    var totalPrice = 0
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    let mounthPicker = UIPickerView()
    
    @IBOutlet weak var sumPriceLAbel: UILabel!
    @IBOutlet weak var selectedMounth: UITextField!
    @IBOutlet weak var previousOrderInfoTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //internet kontrolü
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
        updateUserInterface()

        previousOrderInfoTable.dataSource = self
        previousOrderInfoTable.delegate = self
        
        // loading sembolu
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorView.Style.gray
        view.addSubview(activityIndicator)
        
//        activityIndicator.startAnimating()
//        UIApplication.shared.beginIgnoringInteractionEvents()
        
        
       
        mounthPicker.delegate = self
        selectedMounth.inputView = mounthPicker

    }
    // IK sonrası yapılacaklar
    func updateUserInterface() {
        guard let status = Network.reachability?.status else { return }
        switch status {
        case .unreachable:
            let alert = UIAlertController(title: "İnternet Bağlantınız Bulunmuyor.", message: "Lütfen Kontrol Edin", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
            
        case .wifi:
            getObjectId()
            createToolbar()
            getFoodInfo()
            calculateBusinessLikedPoint()
        
        case .wwan:
            getObjectId()
            createToolbar()
            getFoodInfo()
            calculateBusinessLikedPoint()
          
        }
    }
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }

    func createToolbar(){ // Geçmiş Siparişlerin seçili ayı göstermek için
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Seç", style: .plain, target: self, action: #selector(OncekiSiparislerVC.dismissKeyboard))
        
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        selectedMounth.inputAccessoryView = toolBar
        
    }
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    func calculateSumPrice(){
        
        totalPrice = 0
        
        for string in totalPriceArray{
            if string != "" {
                let myInt = Int(string)!
                totalPrice = totalPrice + myInt
            }
        }
        sumPriceLAbel.text = String(totalPrice)
        
    }
    
    func getFoodInfo(){
        if chosenMounth != ""{
            
                  activityIndicator.startAnimating()
                  UIApplication.shared.beginIgnoringInteractionEvents()
        
        let query = PFQuery(className: "VerilenSiparisler")
        query.whereKey("IsletmeSahibi", equalTo: (PFUser.current()?.username)!)
        query.whereKey("HesapOdendi", equalTo: "Evet")
        query.whereKey("Date", matchesText: chosenMounth)
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
                    
                    self.date = self.dateArray.last!
                }
   
                self.previousOrderInfoTable.reloadData()
                self.calculateSumPrice()
                
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
        }
    }
    func calculateBusinessLikedPoint(){
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
                
               
                self.serviceArray.removeAll(keepingCapacity: false)
                self.testeArray.removeAll(keepingCapacity: false)
                
                self.servisBegenildiArray.removeAll(keepingCapacity: false)
                self.servisBegenilmediArray.removeAll(keepingCapacity: false)
                
                self.lezzetBegenildiArray.removeAll(keepingCapacity: false)
                self.lezzetBegenilmediArray.removeAll(keepingCapacity: false)
                
                self.totalServis = 0
                self.totalLezzet = 0
                self.lezzetPoint = 0
                self.servicePoint = 0
                self.lezzetPuan1Bas = ""
                self.servisPuan1Bas = ""
           
                
                for object in objects! {
                    
                    self.serviceArray.append(object.object(forKey: "HizmetBegenilmeDurumu") as! String)
                    self.testeArray.append(object.object(forKey: "LezzetBegeniDurumu") as! String)
                   
                }

                self.servisBegenildiArray = self.serviceArray.filter { $0 == "Evet" }
                self.servisBegenilmediArray = self.serviceArray.filter { $0 == "Hayır" }
                
                self.lezzetBegenildiArray = self.testeArray.filter { $0 == "Evet" }
                self.lezzetBegenilmediArray = self.testeArray.filter { $0 == "Hayır" }
                
                self.totalLezzet = Float(self.lezzetBegenildiArray.count + self.lezzetBegenilmediArray.count)
                self.totalServis = Float(self.servisBegenildiArray.count + self.servisBegenilmediArray.count)
                

                if self.servisBegenildiArray.isEmpty == false && self.lezzetBegenildiArray.isEmpty == false{
                    
                    self.servicePoint = Float(self.servisBegenildiArray.count * 5) / self.totalServis
                    self.lezzetPoint = Float(self.lezzetBegenildiArray.count * 5) / self.totalLezzet
                    
                    self.servisPuan1Bas = String(format: "%.1f", ceil(self.servicePoint*100)/100)
                     self.lezzetPuan1Bas = String(format: "%.1f", ceil(self.lezzetPoint*100)/100)
                    
                    print("bütün servis puanlama sayısı:", self.serviceArray.count)
                    print("bütün lezzet puanlama sayısı:", self.testeArray.count)
                    print("---------------------------------")
                    print("SERVIS beg-begme top:", self.totalServis)
                    print("LEZZET beg-begme top:", self.totalLezzet)
                     print("---------------------------------")
                    print("servis beğenme sayısı:", self.servisBegenildiArray.count)
                    print("servis beğenmeme sayısı:", self.servisBegenilmediArray.count)
                     print("---------------------------------")
                    print("lezzet beğenmeme sayısı:", self.lezzetBegenildiArray.count)
                    print("lezzet beğenmeme sayısı:", self.lezzetBegenilmediArray.count)
                     print("---------------------------------")
                    print("servis puanı:", self.servicePoint)
                    print("testePoint puanı:", self.lezzetPoint)
                    print("---------------------------------")
                    print("servis puanı 1 basamak:", self.servisPuan1Bas)
                    print("testePoint puanı 1 basamak:", self.lezzetPuan1Bas)

                }
            }
        }
    }
    

    func getObjectId(){ // işletme bilgilerinin olduğu satırın object ID si
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
                object!["LezzetPuan"] = String(self.lezzetPuan1Bas)
                object!["HizmetPuan"] = String(self.servisPuan1Bas)
              
                object?.saveInBackground()
            }
        }
        }
    }
 
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return mounthsArray.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return mounthsArray[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        chosenMounth = mounthsArray[row]
        selectedMounth.text! = chosenMounth
        getFoodInfo()
    }
  
    
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        globalDateOncekiSparisler = dateArray[indexPath.row]
        globalTimeOncekiSiparisler = timeArray[indexPath.row]
        globaTotalPriceOncekiSiparisler = totalPriceArray[indexPath.row]
        
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

extension String { // String in seçili harfine bakabilmek için kullanılmıyor
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    subscript (bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ..< end]
    }
    subscript (bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ... end]
    }
    subscript (bounds: CountablePartialRangeFrom<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(endIndex, offsetBy: -1)
        return self[start ... end]
    }
    subscript (bounds: PartialRangeThrough<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ... end]
    }
    subscript (bounds: PartialRangeUpTo<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ..< end]
    }
}
