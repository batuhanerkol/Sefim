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
    var tableNumberArray = [String]()
    
    @IBOutlet weak var tableNumberLabel: UILabel!
    @IBOutlet weak var orderTableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        orderTableView.delegate = self
        orderTableView.dataSource = self
        

    }
    override func viewWillAppear(_ animated: Bool) {
          tableNumberLabel.text = globalChosenTableNumber
              getOrderData()
     
    }
    @IBAction func foodIsReadyButtonClicked(_ sender: Any) {

    }
    @IBAction func closeButtonClicked(_ sender: Any) {
    dismiss(animated: true, completion: nil)
    }
    
    func getOrderData(){
    
        let query = PFQuery(className: "VerilenSiparisler")
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
                self.foodNameArray.removeAll(keepingCapacity: false)
                self.priceArray.removeAll(keepingCapacity: false)
                for object in objects! {
                    self.foodNameArray = object["SiparisAdi"] as! [String]
                     self.priceArray = object["SiparisFiyati"] as! [String]
//                    self.foodNameArray.append(object.object(forKey: "SiparisAdi") as! String)
//                    self.priceArray.append(object.object(forKey: "SiparisFiyati") as! String)

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
        return cell
    }
}
    

