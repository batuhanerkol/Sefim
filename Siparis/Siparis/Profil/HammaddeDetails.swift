//
//  HammaddeDetails.swift
//  Siparis
//
//  Created by Batuhan Erkol on 23.12.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse

class HammaddeDetails: UIViewController {
    
    @IBOutlet weak var hammaddeAdiTExtField: UITextField!
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    var hammaddeAdi = ""
    var selectedHammadde = ""
    var objectId = ""
    var allHammaddeNamesArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
        updateUserInterface()
        
        // loading sembolu
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorView.Style.gray
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    // IK sonrası yaılacaklar
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

                getHammaddeInfo()
                print("------------------------AAAAAAAAAAA", self.allHammaddeNamesArray)
              
            }
        case .wwan:
            
            if PFUser.current()?.username != nil{
                  getHammaddeInfo()
                print("------------------------AAAAAAAAAAA", self.allHammaddeNamesArray)
            }
        }
    }
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
    
    
    func getHammaddeInfo(){
        if selectedHammadde != ""{
        let query = PFQuery(className: "HammaddeBilgileri")
        query.whereKey("HammaddeSahibi", equalTo: "\(PFUser.current()!.username!)")
        query.whereKey("HammaddeAdi", equalTo: selectedHammadde)
            
        query.findObjectsInBackground { (objects, error) in
            
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
                
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
            else{
                self.hammaddeAdi = ""
                self.objectId = ""
        
                for object in objects! {
                    self.hammaddeAdi = (object.object(forKey: "HammaddeAdi") as! String)

                   self.objectId = (object.objectId! as String)
                }
                
                self.hammaddeAdiTExtField.text = self.hammaddeAdi
    
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                
            }
        }
    }
        else{
            let alert = UIAlertController(title: "Bir Hata Oluştu Lütfen Tekrar Deneyin", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
            
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
    
    @IBAction func guncelleButtonPressed(_ sender: Any) {
        if self.allHammaddeNamesArray.contains(selectedHammadde) == false{
        if hammaddeAdiTExtField.text != ""  {
            
        let query = PFQuery(className: "HammaddeBilgileri")
        query.whereKey("HammaddeSahibi", equalTo: "\(PFUser.current()!.username!)")
        query.whereKey("HammaddeAdi", equalTo: selectedHammadde)
        
        query.getObjectInBackground(withId: objectId) { (objects, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
                
            }else {
                
                 objects!["HammaddeAdi"] = self.hammaddeAdiTExtField.text!
                
                objects!.saveInBackground(block: { (success, error) in
                    if error != nil{
                        let alert = UIAlertController(title: "Lütfen Tekrar Deneyin", message: "", preferredStyle: UIAlertController.Style.alert)
                        let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                        alert.addAction(okButton)
                        self.present(alert, animated: true, completion: nil)
                        
                    }else{
                        let alert = UIAlertController(title: "Güncelleme Gerçekleşti", message: "", preferredStyle: UIAlertController.Style.alert)
                        let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                        alert.addAction(okButton)
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }
    }
    
}
        else{
            let alert = UIAlertController(title: "Lütfen Hammadde Adı Girin", message: "", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
        }else{
            let alert = UIAlertController(title: "Seçili Hammadde, Satılan Urunler de Bulunduğu İçin Adını Değiştiremezsiniz", message: "", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
    }

}
//    var foodNameObjectIdArray = [String]()
//
//    func getFoodInfoObjectId(){ // parse döngü sebebi ile kullanılmıyor.
//        if selectedHammadde != ""{
//            let query = PFQuery(className: "FoodInformation")
//            query.whereKey("foodNameOwner", equalTo: "\(PFUser.current()!.username!)")
//            query.whereKey("Hammadde", contains: self.selectedHammadde)
//
//            query.findObjectsInBackground { (objects, error) in
//
//                if error != nil{
//                    let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
//                    let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
//                    alert.addAction(okButton)
//                    self.present(alert, animated: true, completion: nil)
//
//                    self.activityIndicator.stopAnimating()
//                    UIApplication.shared.endIgnoringInteractionEvents()
//                }
//                else{
//                    self.foodNameObjectIdArray.removeAll(keepingCapacity: false)
//
//                    for object in objects! {
//                        self.foodNameObjectIdArray.append(object.objectId! as String)
//                    }
//                    print("foodNameObjectIdArray", self.foodNameObjectIdArray)
//                }
//            }
//        }
//        else{
//            let alert = UIAlertController(title: "Bir Hata Oluştu Lütfen Tekrar Deneyin", message: "", preferredStyle: UIAlertControllerStyle.alert)
//            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
//            alert.addAction(okButton)
//            self.present(alert, animated: true, completion: nil)
//
//            self.activityIndicator.stopAnimating()
//            UIApplication.shared.endIgnoringInteractionEvents()
//        }
//    }
//
//
//    var foodInfoHammadde = [[String]]()
//    var index0 = 0
//    var index1 = 0
//    var index2 = 0
//    var indexArray = [String]()
//    var reverseIndexArray = [String]()
//
//    func changeHammaddeInFoodInfo(){ // parse döngü ayarlanamadığı için kullanılmıyor foodInformation classındaki yemek hammadde isimlerini değüişmek için
//
//            print("index-1:", self.index1)
//
//            let query = PFQuery(className: "FoodInformation")
//            query.whereKey("foodNameOwner", equalTo: "\(PFUser.current()!.username!)")
//
//            query.findObjectsInBackground { (objects, error) in
//
//                if error != nil{
//                    let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
//                    let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
//                    alert.addAction(okButton)
//                    self.present(alert, animated: true, completion: nil)
//
//                    self.activityIndicator.stopAnimating()
//                    UIApplication.shared.endIgnoringInteractionEvents()
//                }
//                else{
//                    self.foodInfoHammadde.removeAll(keepingCapacity: false)
//
//                    for object in objects! {
//                        self.foodInfoHammadde.append(object.object(forKey: "Hammadde") as! [String])
//                    }
//
//                    while self.index0 < self.foodInfoHammadde.count{
//
//                        if self.foodInfoHammadde[self.index0].contains(self.selectedHammadde){
//                        print("DEĞİŞİM DÖNGÜSÜ")
//                        print("index0:", self.index0)
//                        print("selected hammadde :",self.selectedHammadde)
//                        let arrayIndex:Int = self.foodInfoHammadde[self.index0].index(of: self.selectedHammadde)!
//                        print("selectedHammadde yeri: ", arrayIndex )
//                        print("Seçili array:", self.foodInfoHammadde[self.index0])
//                        print("hammadde Array : ",  self.foodInfoHammadde )
//                       self.foodInfoHammadde[self.index0][arrayIndex] = self.hammaddeAdiTExtField.text!
//                        self.index0 += 1
//                        self.index1 += 1
//
//                            self.indexArray.append(String(arrayIndex))
//                        }
//                        else{
//                            self.index0 += 1
//                        }
//                        self.reverseIndexArray = Array(self.indexArray.reversed()) // arrayi ters çevirmek için
//                }
//
//                    print("Değişmiş Hammadde Array:", self.foodInfoHammadde)
//            }
//        }
//
//    }
//
//    func changeFoodInfoHammaddeNames(){ // parse döngüsü ayarlanamadığı için kullaılmıyor, hammaddenin Food info da isimlerini değştirmek için
//        self.index2 = 0
//
//        while index2 < self.foodNameObjectIdArray.count{
//
//            // parse a veri yazma işlemi tamamlanamdan döngü kendini tamamlıyor.
//            print("------------------------------------ changeFoodInfoHammaddeNames e girildi ------------------------------------")
//            print("SEÇİLİ URUN OBJECT ID:", foodNameObjectIdArray[self.index2])
//            print("Array Index:", self.indexArray)
//            print("reverseIndexArray:", self.reverseIndexArray)
//            print("index0--", self.index0)
//            print("index1--", self.index1)
//            print("index2:", self.index2)
//
//            let query = PFQuery(className: "FoodInformation")
//            query.whereKey("foodNameOwner", equalTo: "\(PFUser.current()!.username!)")
//
//            query.getObjectInBackground(withId: foodNameObjectIdArray[self.index2]) { (objects, error) in
//                if error != nil{
//                    let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
//                    let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
//                    alert.addAction(okButton)
//                    self.present(alert, animated: true, completion: nil)
//
//                }else {
//                    print("DEĞİŞİM İÇİNDE ARRAY:", self.foodInfoHammadde)
//                    objects!["Hammadde"] = self.foodInfoHammadde[Int(self.reverseIndexArray[self.index2])!]
//
//                    objects!.saveInBackground(block: { (success, error) in
//                        if error != nil{
//                            let alert = UIAlertController(title: "Lütfen Tekrar Deneyin", message: "", preferredStyle: UIAlertController.Style.alert)
//                            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
//                            alert.addAction(okButton)
//                            self.present(alert, animated: true, completion: nil)
//
//                        }else{
//                            print("--------------------KAYDEDİLDİ")
//                            let alert = UIAlertController(title: "Güncelleme Gerçekleşti", message: "", preferredStyle: UIAlertController.Style.alert)
//                            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
//                            alert.addAction(okButton)
//                            self.present(alert, animated: true, completion: nil)
//                        }
//                    })
//
//                }
//            }
//            self.index2 += 1
//        }
//        }
//

