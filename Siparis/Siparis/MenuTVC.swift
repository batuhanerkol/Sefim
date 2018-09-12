//
//  MenuTVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 8.09.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse

class MenuTVC: UITableViewController {

    var foodTitleArray = [String]()

    var chosenFood = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       tableView.delegate = self
        tableView.dataSource = self
       
       getData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return foodTitleArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.textLabel?.text = foodTitleArray[indexPath.row]
        return cell
    }
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "MenuVCToAddFoodTitleVC", sender: nil)
        }
    
    func getData(){
        let query = PFQuery(className: "FoodTitle")
        query.whereKey("foodOwner", equalTo: "\(PFUser.current()!.username!)")
        query.findObjectsInBackground { (objects, error) in
    
                if error != nil{
                    let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    self.foodTitleArray.removeAll(keepingCapacity: false)
                    for object in objects! {
                        self.foodTitleArray.append(object.object(forKey: "foodTitle") as! String)
                        
                    }
                    self.tableView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "MenuToFoodDetailsTVC"{
                let destinationVC = segue.destination as! FoodDetailsTVC
                destinationVC.chosenFood = self.chosenFood
            }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.chosenFood = foodTitleArray[indexPath.row]
        self.performSegue(withIdentifier: "MenuToFoodDetailsTVC", sender: nil)
        
    }
    
    }

