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
                getHammaddeInfo()
            }
        case .wwan:
    
            if PFUser.current()?.username != nil{
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
        harcananHammaddeMiktarıArray.removeAll(keepingCapacity: false)
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
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                
               // self.hammaddeTableView.reloadData()
                
                print("---Fonksiyon çağırıldı(getHarcanan)")
                self.getHarcananHammadde()
            }
            
        }
        
    }
    
  
    
    // [[String]] --> [String]
    func turnBigToSingleArray(){
        for tekArray in self.allHammaddeBigArray {
            for tekUrun in tekArray  {
                self.allHammaddeArray.append(tekUrun)
            }
        }
        for tekArray in self.allHammaddeMiktarBigArray {
            for tekUrun in tekArray  {
                self.allHammaddeMiktarArray.append(tekUrun)
            }
        }
    }
    
    // Tüm hammadde ve sayıları arrayleri
    var allHammaddeBigArray = [[String]]()
    var allHammaddeArray = [String]()
    var allHammaddeMiktarBigArray = [[String]]()
    var allHammaddeMiktarArray = [String]()
    var harcananHammaddeMiktarıArray = [Double]()
    
    func getHarcananHammadde(){
        allHammaddeBigArray.removeAll(keepingCapacity: false)
        allHammaddeArray.removeAll(keepingCapacity: false)
        allHammaddeMiktarBigArray.removeAll(keepingCapacity: false)
        allHammaddeMiktarBigArray.removeAll(keepingCapacity: false)
        harcananHammaddeMiktarıArray.removeAll(keepingCapacity: false)
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
                self.turnBigToSingleArray()
                var counter: Double = 0
                var intHamMiktarArray = [Double]()
                
                // miktarı int arraye çeviriyor
                for hm in self.allHammaddeMiktarArray {
                    if let a = Double(hm) {
                        intHamMiktarArray.append(a)
                    }
                }
                for _ in (self.hammaddeAdiArray.indices){
                    self.harcananHammaddeMiktarıArray.append(0)
                }
                ///////////////////////////////////////////////////
                // Hammaddelerle miktarlarını eşitliyor
                for hamIndex in self.hammaddeAdiArray.indices {
                    counter = 0
                    for i in self.allHammaddeArray.indices {
                        if self.hammaddeAdiArray[hamIndex] == self.allHammaddeArray[i] {
                            counter = intHamMiktarArray[i]
                            self.harcananHammaddeMiktarıArray[hamIndex] += counter
                        }
                    }
                }
                print("----HAMMADDE ADI =",self.hammaddeAdiArray)
                print("----HAMMADDE MİKTARI =",self.harcananHammaddeMiktarıArray)
                self.calculateKalanHammadde()
            }
    }
    }
    
    func calculateKalanHammadde(){
        print("İşlem tamam")
        var maddeMiktarıDoubleArray = [Double]()
        maddeMiktarıDoubleArray.removeAll(keepingCapacity: false)
        for mad in self.hammaddeKalanMiktarArray {
            let a = Double(mad)
            maddeMiktarıDoubleArray.append(a!)
        }
        for i in harcananHammaddeMiktarıArray.indices {
            harcananHammaddeMiktarıArray[i] = harcananHammaddeMiktarıArray[i] / 1000
        }
        // Substract arrays
        for i in hammaddeKalanMiktarArray.indices {
            let total = String(maddeMiktarıDoubleArray[i] - harcananHammaddeMiktarıArray[i])
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
    
        self.performSegue(withIdentifier: "hammaddeDetails", sender: nil)
        
    }
    

}
