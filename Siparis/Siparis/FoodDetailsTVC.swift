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
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet var nameTableView: UITableView!
    

    var chosenFood = ""
    var foodNameArray = [String]()

      
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getData()
        
    }
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        nameTableView.isEditing = !nameTableView.isEditing
        
        switch nameTableView.isEditing {
        case true:
            editButton.title = "Tamam"
        case false:
            editButton.title = "Düzenle"
        }
    }
    
    @IBAction func addButtonClicked(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "FoodDetailsTVCToFoodDetailsVC", sender: nil)
    }
    func getData(){
    
        let query = PFQuery(className: "FoodInformation")
         query.whereKey("foodNameOwner", equalTo: "\(PFUser.current()!.username!)")
         query.whereKey("foodTitle", equalTo: selectecTitle)
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
             self.nameTableView.reloadData()

        }
        
    }
    
    func deleteData(foodIndexName : String){
        let query = PFQuery(className: "FoodInformation")
       query.whereKey("foodNameOwner", equalTo: "\(PFUser.current()!.username!)")
        query.whereKey("foodName", equalTo: foodIndexName)
        
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
                    object.deleteInBackground()
                    self.nameTableView.reloadData()
                    self.getData()
                }
            }
            
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
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete){
            let foodIndexName = nameTableView.cellForRow(at: indexPath)?.textLabel?.text!

            foodNameArray.remove(at: indexPath.item) 
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
           
            deleteData(foodIndexName: foodIndexName!)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = foodNameArray[sourceIndexPath.row]
        foodNameArray.remove(at: sourceIndexPath.row)
        foodNameArray.insert(item, at: destinationIndexPath.row)
        
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodNameArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = foodNameArray[indexPath.row]
        return cell
    }
}
