//
//  HammaddeVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 23.12.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse

class HammaddeVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {

   
    @IBOutlet weak var mounthTextField: UITextField!
    
     var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    var hammaddeAdiArray = [String]()
    var toplamHammadde = [Double]()
      var chosenHammadde = ""
    
    var mounthsArray = ["Ay Seçin","Oca","Şub","Mar","Nis","May","Haz","Tem","Ağu","Eyl","Eki","Kas","Ara"]
     var chosenMounth: String = ""
    
    let mounthPicker = UIPickerView()
    

    @IBOutlet weak var hammaddeTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        hammaddeTableView.delegate = self
        hammaddeTableView.dataSource = self
    
        // interenet kontorlü
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
        updateUserInterface()
        
        // loading sembolu
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorView.Style.gray
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        mounthPicker.delegate = self
        mounthTextField.inputView = mounthPicker
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
                getHammaddeInfo()
                getFoodNames()
                createToolbar()
        case .wwan:
                getHammaddeInfo()
                getFoodNames()
                createToolbar()
        }
    }
    
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
    
    func createToolbar(){ // Geçmiş Siparişlerin seçili ayı göstermek için
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Seç", style: .plain, target: self, action: #selector(OncekiSiparislerVC.getPaidFoodStock))
        
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        mounthTextField.inputAccessoryView = toolBar
    }
    
    func getHammaddeInfo(){
      
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
                
                for object in objects! {
                    self.hammaddeAdiArray.append(object.object(forKey: "HammaddeAdi") as! String)
                }
                print("hammaddeAdi",self.hammaddeAdiArray)
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
    }
    var hammaddeAdlari = [[String]]()
    var hammaddeMiktarlari = [[String]]()
    var foodNamesArray = [String]()
    
    func getFoodNames(){
      
        let query = PFQuery(className: "FoodInformation")
        query.whereKey("foodNameOwner", equalTo: (PFUser.current()?.username)!)
        query.whereKey("HesapOnaylandi", equalTo: "Evet")
        query.findObjectsInBackground { (objects, error) in
            if error != nil {
                
            } else {
                self.foodNamesArray.removeAll()
                self.hammaddeAdlari.removeAll(keepingCapacity: false)
                self.hammaddeMiktarlari.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    self.foodNamesArray.append(object.object(forKey: "foodName") as! String)
                    self.hammaddeAdlari.append(object.object(forKey: "Hammadde") as! [String])
                    self.hammaddeMiktarlari.append(object.object(forKey: "HammaddeMiktarlari") as! [String])
                }
                print("======Yemek",self.foodNamesArray)
                print("======Hammadde",self.hammaddeAdlari)
                print("======Miktarları",self.hammaddeMiktarlari)
                
            }
        }
        
    }
    // Son kullanılacak array bu !!!!! yukarıdaki foodNamesArray ile eşleştirip tek tek bir sayı belirlemen gerekli
    var odendiSiparisArray = [[String]]()
    var allOdendiSiparisArray = [String]()
    var allOdendiSiparisSayiArray = [Int]()
    
    @objc func getPaidFoodStock() {
        odendiSiparisArray.removeAll()
        allOdendiSiparisArray.removeAll()
        allOdendiSiparisSayiArray.removeAll()
        
        let query = PFQuery(className: "VerilenSiparisler")
        query.whereKey("IsletmeSahibi", equalTo: (PFUser.current()?.username)!)
        query.whereKey("HesapOdendi", equalTo: "Evet")
        query.whereKey("Date", matchesText: chosenMounth)
        query.addDescendingOrder("createdAt")
        query.findObjectsInBackground { (objects, error) in
            if error != nil {
                
            } else {
                self.allOdendiSiparisArray.removeAll()
                for object in objects! {
                    self.odendiSiparisArray.append(object["SiparisAdi"] as! [String])
                    
                }
                for tekArray in self.odendiSiparisArray {
                    for tekUrun in tekArray  {
                        self.allOdendiSiparisArray.append(tekUrun)
                    }
                }
                self.calculateStokAdet()
            }
        }
    }
    var carpilmisHammaddeArray = [Int]()
    var allcarpilmisHammaddeArray = [Int]()
    var allHammaddeAdlari = [String]()
    var toplamHammaddeArray = [Int]()
    
    func calculateStokAdet(){
        allOdendiSiparisSayiArray.removeAll()
        for foodName in self.foodNamesArray {
            var counter = 0
            for siparisFoodName in self.allOdendiSiparisArray {
                if foodName == siparisFoodName {
                    counter += 1
                }
            }
            self.allOdendiSiparisSayiArray.append(counter)
            dismissKeyboard()
        }
        print("----------------------------TOPLAM SAYI-----------------------------------------------------")
        print("siparis verilmis yemekler:",self.allOdendiSiparisArray)
        print("siparis verilmis yemek sayilari:", self.allOdendiSiparisSayiArray)
        hammaddeTableView.reloadData()
        
        var hammaddeSayi = 0
        while hammaddeSayi < self.foodNamesArray.count{
            
            print("Hammaddesi Seçili ürün Adı", self.foodNamesArray[hammaddeSayi])
            print("Hammaddesi Seçili ürün Miktarı", self.hammaddeMiktarlari[hammaddeSayi])
            
            var urunHammaddeSayiArray = self.hammaddeMiktarlari[hammaddeSayi].map { Int($0)!}
            
            print("int çevirilmiş hammadde SAyi", urunHammaddeSayiArray)
            self.carpilmisHammaddeArray.removeAll(keepingCapacity: false)
            for i in urunHammaddeSayiArray{
               var carpilmisHammadde = i * self.allOdendiSiparisSayiArray[hammaddeSayi]
                print("çarpılmış halleri:", carpilmisHammadde )
                
                self.carpilmisHammaddeArray.append(carpilmisHammadde)
                
            }
            print("carpilmisArray", self.carpilmisHammaddeArray)
            self.allcarpilmisHammaddeArray.append(contentsOf: self.carpilmisHammaddeArray)
            print("======Hammadde",self.hammaddeAdlari)
            print("hammaddeAdlari:", self.hammaddeAdlari[hammaddeSayi])
            print("bütün carpılmıs sayılar:", self.allcarpilmisHammaddeArray)
            self.allHammaddeAdlari.append(contentsOf: self.hammaddeAdlari[hammaddeSayi])
            print("hammadde adlari tek array", self.allHammaddeAdlari)
            print("sadece hammadde adi:", self.hammaddeAdiArray)
            
          
            
           
            hammaddeSayi += 1
        }
        var hammaddeIndex0 = 0
        var hammaddeIndex1 = 0
        var hammaddeIndex2 = 0
        var toplamHammadde = 0
        
        
        while hammaddeIndex0 < self.hammaddeAdiArray.count{// kişinin girdiği hammadde sayısı kadar dönecek
            
            while self.hammaddeAdiArray[hammaddeIndex1] != self.allHammaddeAdlari[hammaddeIndex2]{
           
              hammaddeIndex2 += 1
                print("hammaddeIndex2",hammaddeIndex2)
                
            }
            toplamHammadde = toplamHammadde + self.allcarpilmisHammaddeArray[hammaddeIndex2]
            print("toplamHammadde", toplamHammadde)
            self.toplamHammadde.append(Double(toplamHammadde))
            
           
            if self.allHammaddeAdlari.count == hammaddeIndex2{
                hammaddeIndex0 += 1
                hammaddeIndex1 += 1
                
            }else{
                hammaddeIndex2 += 1
            }
        }
        
        print("toplam hammadde", self.toplamhammadde)
        
    }
 
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return hammaddeAdiArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
         let cell = tableView.dequeueReusableCell(withIdentifier: "HammaddeCell", for: indexPath) as! HammaddeCell
      
       
        cell.hammaddeNameLAbel.text = hammaddeAdiArray[indexPath.row]
       
        
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
    
        self.performSegue(withIdentifier: "hammaddeDetails", sender: nil)
        
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
        mounthTextField.text! = chosenMounth
        
    }
    

}
