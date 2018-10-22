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
    
    var foodNameArray = [String]()
    var priceArray = [String]()
    var orderNoteArray = [String]()
    var dateArray = [String]()
    var timeArray =  [String]()
     var tableNumberArray = [String]()
    
     var tableNumber = ""
    
    @IBOutlet weak var tableNumberLabel: UILabel!
    @IBOutlet weak var orderTableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        orderTableView.delegate = self
        orderTableView.dataSource = self
        
    }
    override func viewWillAppear(_ animated: Bool) {
        getTableNumberData()
        
        
         getOrderData()
        
    }
    @IBAction func foodIsReadyButtonClicked(_ sender: Any) {

    }
    @IBAction func closeButtonClicked(_ sender: Any) {
    dismiss(animated: true, completion: nil)
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
                    print("AAAAAAA3")
                    self.tableNumberArray.append(object.object(forKey: "MasaNo") as! String)
                }
            }
            
            self.tableNumber = self.tableNumberArray.last!
            print( self.tableNumber )
        }
    }
    
    
    func getOrderData(){
     tableNumberLabel.text! =  globalChosenTableNumber
        getTableNumberData()
      //  print(tableNumberLabel.text!)
    
        let query = PFQuery(className: "VerilenSiparisler")
        query.whereKey("IsletmeSahibi", equalTo: (PFUser.current()?.username)!)
        query.whereKey("MasaNo", equalTo:tableNumber )

        query.findObjectsInBackground { (objects, error) in

            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                 print("AAAAAAA1")
                self.foodNameArray.removeAll(keepingCapacity: false)
                self.priceArray.removeAll(keepingCapacity: false)
                self.orderNoteArray.removeAll(keepingCapacity: false)
                self.dateArray.removeAll(keepingCapacity: false)
                self.timeArray.removeAll(keepingCapacity: false)
                print("AAAAAAA2")
                for object in objects! {
                        print("AAAAAAA3")
                    self.foodNameArray = object["SiparisAdi"] as! [String]
                    self.priceArray = object["SiparisFiyati"] as! [String]
                    self.orderNoteArray = object["YemekNotu"] as! [String]
                     print("AAAAAAA4")
                    self.dateArray.append(object.object(forKey: "Date") as! String)
                     self.timeArray.append(object.object(forKey: "Time") as! String)
                   
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
}
    

