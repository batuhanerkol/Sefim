//
//  MenuTVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 8.09.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse

var selectecTitle = ""

class MenuTVC: UITableViewController {

    @IBOutlet var titleTableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    var foodTitleArray = [String]()

    var chosenFood = ""
    
    var screenPassword = ""
    
    var passwordTextField: UITextField?
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //internet kontroplü
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
        updateUserInterface()
        
       tableView.delegate = self
        tableView.dataSource = self

        self.navigationItem.hidesBackButton = true
        
        // loading sembolu
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorView.Style.gray
        view.addSubview(activityIndicator)
        
        //loading sembolu ve ekran erişimini kapalı, başlatmak için
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
    }
    override func viewWillAppear(_ animated: Bool) {
         enteringPassword()
    }
    
    // internet kontrolü sonrası yapılacaklar
    func updateUserInterface() {
        guard let status = Network.reachability?.status else { return }
        switch status {
        case .unreachable:
            let alert = UIAlertController(title: "İnternet Bağlantınız Bulunmuyor.", message: "Lütfen Kontrol Edin", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
            
            
            self.editButton.isEnabled = false
        case .wifi:
            self.editButton.isEnabled = true
            if PFUser.current()?.username != nil{
                getFoodTitle()
            }
        case .wwan:
            self.editButton.isEnabled = true
            if PFUser.current()?.username != nil{
                getFoodTitle()
            }
        }
    }
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
    
    // uygulama sahibi dışındaki kişilerin ekrana erişimini engellemek için ekran şifresi isteme
    func enteringPassword(){
  
        let alertController = UIAlertController(title: "Şifre Girin", message: "", preferredStyle: .
        alert)
        let action = UIAlertAction(title: "Tamam", style: .default) { (action) in
            
            self.activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
            
                let query = PFQuery(className: "BusinessInformation")
                query.whereKey("businessUserName", equalTo: "\(PFUser.current()!.username!)")
                
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
                      
                        self.screenPassword = ""
                        
                        for object in objects!{
                           
                            self.screenPassword = (object.object(forKey: "EkranSifresi") as! String)
                            
                        }
                
                        if alertController.textFields?.first?.text! == self.screenPassword{
                            print("Şifreler eşleşiyor")
                            self.activityIndicator.stopAnimating()
                            UIApplication.shared.endIgnoringInteractionEvents()
                        }
                        else{
                        
                            self.viewWillAppear(false)
                            self.activityIndicator.stopAnimating()
                            UIApplication.shared.endIgnoringInteractionEvents()
                        }
                
                    }
                }
        }
      
        alertController.addTextField { (passwordTextField) in
            print(passwordTextField.text!)
        }
          alertController.textFields?.first?.isSecureTextEntry = true
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
       
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "MenuVCToAddFoodTitleVC", sender: nil)
        }
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        
        titleTableView.isEditing = !titleTableView.isEditing
        
        switch titleTableView.isEditing {
        case true:
            editButton.title = "Tamam"
         case false:
            editButton.title = "Düzenle"
        }
    }
    
    
    
   
    func getFoodTitle(){
        let query = PFQuery(className: "FoodTitle")
        query.whereKey("foodTitleOwner", equalTo: "\(PFUser.current()!.username!)")
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
                    self.foodTitleArray.removeAll(keepingCapacity: false)
                    for object in objects! {
                        self.foodTitleArray.append(object.object(forKey: "foodTitle") as! String)
                    }
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.tableView.reloadData()
            }
        }
    }

    func deleteFoodTitle(foodIndexTitle : String){
        let query = PFQuery(className: "FoodTitle")
        query.whereKey("foodTitleOwner", equalTo: "\(PFUser.current()!.username!)")
       query.whereKey("foodTitle", equalTo: foodIndexTitle)
        query.findObjectsInBackground { (objects, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
                
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
            else {
                self.foodTitleArray.removeAll(keepingCapacity: false) 
                for object in objects! {
                    object.deleteInBackground()
                    self.titleTableView.reloadData()
                    self.getFoodTitle()
                }
               
            }
        }
    }
// segue yapmadan önce bilgi aktarımı için
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "MenuToFoodDetailsTVC"{
                let destinationVC = segue.destination as! FoodDetailsTVC
                destinationVC.chosenFood = self.chosenFood
            }
    }
    
    
    
    
    // tableView ayarları
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodTitleArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.textLabel?.text = foodTitleArray[indexPath.row]
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.chosenFood = foodTitleArray[indexPath.row]
        
        selectecTitle = (titleTableView.cellForRow(at: indexPath)?.textLabel?.text)!
        
        self.performSegue(withIdentifier: "MenuToFoodDetailsTVC", sender: nil)

    }
   
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = foodTitleArray[sourceIndexPath.row]
        foodTitleArray.remove(at: sourceIndexPath.row)
        foodTitleArray.insert(item, at: destinationIndexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == .delete){
             let foodIndexTitle = titleTableView.cellForRow(at: indexPath)?.textLabel?.text!
            
            foodTitleArray.remove(at: indexPath.item)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            deleteFoodTitle(foodIndexTitle: foodIndexTitle!)
        }
    }
    }

