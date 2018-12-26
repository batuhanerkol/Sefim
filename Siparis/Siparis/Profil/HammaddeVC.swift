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
            
            
        
        case .wifi:
         
            if PFUser.current()?.username != nil{
                getData()
            }
        case .wwan:
    
            if PFUser.current()?.username != nil{
                getData()
            }
        }
    }
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
    
    func getData(){
        let query = PFQuery(className: "HammaddeBilgileri")
        query.whereKey("HammaddeSahibi", equalTo: "\(PFUser.current()!.username!)")
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
                self.hammaddeAdiArray.removeAll(keepingCapacity: false)
                 self.hammaddeKalanMiktarArray.removeAll(keepingCapacity: false)
                for object in objects! {
                    self.hammaddeAdiArray.append(object.object(forKey: "HammaddeAdi") as! String)
                     self.hammaddeKalanMiktarArray.append(object.object(forKey: "HammaddeMiktariGr") as! String)
                }
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                
                self.hammaddeTableView.reloadData()
            }
        }
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
