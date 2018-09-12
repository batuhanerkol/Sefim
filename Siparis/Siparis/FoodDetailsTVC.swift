//
//  FoodDetailsTVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 8.09.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse

class FoodDetailsTVC: UITableViewController {

      var foodNameArray = [String]()
      var chosenFood = ""
    
      
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getData()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodNameArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = foodNameArray[indexPath.row]
        return cell
    }
    @IBAction func addButtonClicked(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "FoodDetailsTVCToFoodDetailsVC", sender: nil)
    }
    func getData(){
        let query = PFQuery(className: "FoodTitle")
      
         query.whereKey("foodNameOwner", equalTo: "\(PFUser.current()!.username!)")
           query.findObjectsInBackground { (objects, error) in
            
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                self.foodNameArray.removeAll(keepingCapacity: false)
                for object in objects! {
                    self.foodNameArray.append(object.object(forKey: "foodName") as! String)
                }
               
            }
             self.tableView.reloadData()
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FoodDetaisTVCToFoodInformationShowVC"{
            let destinationVC = segue.destination as! FoodInformationShowVC
            destinationVC.selectedFood = self.chosenFood
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.chosenFood = foodNameArray[indexPath.row]
        performSegue(withIdentifier: "FoodDetaisTVCToFoodInformationShowVC", sender: nil)
    }
}
