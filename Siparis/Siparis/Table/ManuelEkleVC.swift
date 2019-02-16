//
//  ManuelEkleVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 11.12.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse

class ManuelEkleVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
    
    @IBOutlet weak var tableNumberLabel: UILabel!
    @IBOutlet weak var selectedFoodPriceLabel: UILabel!
    @IBOutlet weak var addToTableButton: UIButton!
    @IBOutlet weak var foodNameTable: UITableView!
    @IBOutlet weak var foodTitleTable: UITableView!
    @IBOutlet weak var selectedFoodNameLabel: UILabel!
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    var foodTitleArray = [String]()
    var foodNameArray = [String]()
    var priceArray = [String]()
    
    var chosenFoodTitle = ""
    var chosenFoodName = ""
    var chosenFoodPrice = ""
    var businessName = ""
    
    public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //internet bağlantı kontrolü
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
        updateUserInterface()

        foodNameTable.dataSource = self
        foodNameTable.delegate = self
        foodTitleTable.dataSource = self
        foodTitleTable.delegate = self
        
        // loading sembolu
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorView.Style.gray
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        addToTableButton.isEnabled = false
        
        tableNumberLabel.text = globalChosenTableNumberMasaVC
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
            self.addToTableButton.isEnabled = false
        case .wifi:
            getFoodTitleData()
            
        case .wwan:

            getFoodTitleData()
        }
    }
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
    
    
    func getFoodTitleData(){
        
        let query = PFQuery(className: "FoodTitle")
        query.whereKey("foodTitleOwner", equalTo: (PFUser.current()?.username)!)
        
        query.findObjectsInBackground { (objects, error) in
            
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                self.foodTitleArray.removeAll(keepingCapacity: false)
                self.businessName = ""
                for object in objects! {
                    self.foodTitleArray.append(object.object(forKey: "foodTitle") as! String)
                    self.businessName = (object.object(forKey: "BusinessName") as! String)
                    
                }
                
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
               
                self.foodTitleTable.reloadData()
                
            }
        }
        
    }
    
    func getFoodData(){
      
        if foodTitleArray.isEmpty == false && chosenFoodTitle != ""{
            
        let query = PFQuery(className: "FoodInformation")
        query.whereKey("foodNameOwner", equalTo: (PFUser.current()?.username)!)
        query.whereKey("foodTitle", equalTo: String(chosenFoodTitle))
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
                for object in objects! {
                    self.foodNameArray.append(object.object(forKey: "foodName") as! String)
                    self.priceArray.append(object.object(forKey: "foodPrice") as! String)
                }

            }
            self.foodNameTable.reloadData()
            

        }
        }
    }

    
    @IBAction func addToTableButtonPressed(_ sender: Any) {
        if selectedFoodNameLabel.text! != ""{
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let object = PFObject(className: "Siparisler")
        
        object["SiparisAdi"] = selectedFoodNameLabel.text!
        object["SiparisFiyati"] = selectedFoodPriceLabel.text!
        object["IsletmeSahibi"] = PFUser.current()?.username!
        object["SiparisSahibi"] = PFUser.current()?.username!
        object["MasaNumarasi"] = globalChosenTableNumberMasaVC
        object["YemekNotu"] = ""
        object["IsletmeAdi"] = self.businessName
        object["SiparisDurumu"] = ""
        
        object.saveInBackground { (success, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }else{
                
                let alert = UIAlertController(title: "Siparişe Eklenmiştir", message: "", preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
                
                self.selectedFoodNameLabel.text = ""
                self.selectedFoodPriceLabel.text = ""
                
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                
            }
        }
        }else{
            let alert = UIAlertController(title: "Yemek Seçmeniz Gerekli", message:"", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
        if tableView == foodTitleTable{
        if indexPath.row < self.foodTitleArray.count{
            
              chosenFoodTitle = foodTitleArray[indexPath.row]
            if chosenFoodTitle != ""{
          getFoodData()
                 selectedFoodNameLabel.text! = ""
                selectedFoodPriceLabel.text! = ""
            }
        }
        }
        else{
            if indexPath.row < foodNameArray.count{
                chosenFoodName = foodNameArray[indexPath.row]
                chosenFoodPrice = priceArray[indexPath.row]
                
                selectedFoodNameLabel.text! = String(chosenFoodName)
                selectedFoodPriceLabel.text! = String(chosenFoodPrice)
                
                addToTableButton.isEnabled = true
            }
        }
        
        
 
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        if tableView == foodTitleTable{
        return foodTitleArray.count
        }
        else{
            return foodNameArray.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == foodTitleTable{
        let cell = UITableViewCell()
        cell.textLabel?.text = foodTitleArray[indexPath.row]
        return cell
            
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ManuelEkleCell", for: indexPath) as! ManuelEkleCell
            //index out or range hatası almamak için
            if indexPath.row < foodNameArray.count {
                cell.foodNameLabel.text = foodNameArray[indexPath.row]
                cell.foodPriceLAbel.text = priceArray[indexPath.row]
        }
        return cell
    }
    
}
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if screenWidth > 500 && screenWidth < 1000 {
          return 35
        }
        else if screenWidth > 1000 && screenWidth < 1200{
            return 50
        }else{
            return 40
        }
    }
}
