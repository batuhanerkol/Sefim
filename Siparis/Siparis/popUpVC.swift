//
//  popUpVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 19.10.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse

class popUpVC: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    var orderArray = [String]()
    var priceArray = [String]()
    
    @IBOutlet weak var ordersTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ordersTableView.delegate = self
        ordersTableView.dataSource = self
        
        getFoodNameData()
    }
    override func viewWillAppear(_ animated: Bool) {
        getFoodNameData()
    }
    
    func getFoodNameData(){
//        let query = PFQuery(className: "VerilenSiparisler")
//        query.whereKey("IsletmeSahibi", equalTo: (PFUser.current()?.username)!)
//        query.whereKey("MasaNumarasi", equalTo: globalChosenTableNumber)
//
//        query.findObjectsInBackground { (objects, error) in
//
//            if error != nil{
//                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
//                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
//                alert.addAction(okButton)
//                self.present(alert, animated: true, completion: nil)
//            }
//            else{
//                self.orderNameArray.removeAll(keepingCapacity: false)
//                self.priceArray.removeAll(keepingCapacity: false)
//
//                for object in objects! {
//                    self.orderNameArray.append(object.object(forKey: "SiparisAdi") as! String)
//                    self.priceArray.append(object.object(forKey: "SiparisFiyati") as! String)
//
//                }
//                 self.ordersTableView.reloadData()
//            }
//
//        }
        
        let query = PFQuery(className: "Siparisler")
        query.whereKey("IsletmeSahibi", equalTo: (PFUser.current()?.username)!)
        query.whereKey("MasaNumarasi", equalTo: globalChosenTableNumber)
        
        query.findObjectsInBackground { (objects, error) in
            
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                self.orderArray.removeAll(keepingCapacity: false)
                self.priceArray.removeAll(keepingCapacity: false)
                for object in objects! {
                    self.orderArray.append(object.object(forKey: "SiparisAdi") as! String)
                    self.priceArray.append(object.object(forKey: "SiparisFiyati") as! String)
                    
                }
            }
            self.ordersTableView.reloadData()
        }
    }
    
    @IBAction func foodIsReadyButtonClicked(_ sender: Any) {
        
    }
    
    @IBAction func closePopUpButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
         dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PopUpCellTableViewCell
        
        cell.fooNameLabel.text = orderArray[indexPath.row]
        cell.priceLabel.text = priceArray[indexPath.row]
        
        return cell
    }
    
}
