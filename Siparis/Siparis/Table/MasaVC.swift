//
//  MasaVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 3.09.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse



var globalChosenTableNumber = ""

class MasaVC: UIViewController {

    var xLocation = 10
    var yLocation = 100
    
    var buttonWidth = 80
    var buttonHeight = 80
    
    var spacer = 10
    
    var tableNumber = 0
    
    var tableNumberArray = [String]()
    var tableNumberText = ""
    
    var deneme = 0
    
    var tableBottomBackgroundColor = UIColor.gray
    var tableButtonBackgroundColorAray = [UIButton]()
    
    
    
  public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
     public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    
    @IBOutlet weak var tableNumberLabel: UILabel!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        buttonSizes()
        getTableNumberData()
        getButtonWhenAppOpen()
        
        let value = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    override func viewWillAppear(_ animated: Bool) {

        
    }
    func buttonSizes(){
        if screenWidth > 1000{
            buttonWidth = 100
            buttonHeight = 100
        }
        else if screenWidth > 1200{
            buttonWidth = 130
            buttonHeight = 130
        }
        else if screenWidth < 1000{
            buttonWidth = 45
            buttonHeight = 45
        }
     
    }
    
    
    func getButtonWhenAppOpen(){

        let query = PFQuery(className: "TableNumbers")
        query.whereKey("TableOwner", equalTo: "\(PFUser.current()!.username!)")
        
        query.findObjectsInBackground { (objects, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                for object in objects!{
                    self.tableNumberArray.append(object.object(forKey: "NumberOfTable") as! String)
                    self.tableNumberLabel.text = "\(self.tableNumberArray.last!)"
                    
                    self.textField.text! = self.tableNumberLabel.text!
                    
                    self.deneme = Int(self.tableNumberLabel.text!)!
                    
                    
                }
                while self.tableNumber < self.deneme {
                    self.createBtn()
                    self.tableNumber = self.tableNumber + 1
                    
                    if CGFloat(self.xLocation) < self.screenWidth - CGFloat(self.buttonWidth * 2) {
                        self.xLocation = self.xLocation + self.buttonWidth + self.spacer
                    }
                    else if CGFloat(self.xLocation) >= self.screenWidth - CGFloat(self.buttonWidth * 2)  {
                        self.xLocation = 10
                        self.yLocation = self.yLocation + self.buttonWidth + self.spacer
                    }
                    
                }
            }
        }
    }
    func getTableNumberData(){
    
        let query = PFQuery(className: "TableNumbers")
        query.whereKey("TableOwner", equalTo: "\(PFUser.current()!.username!)")
       
        query.findObjectsInBackground { (objects, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                for object in objects!{
                 self.tableNumberArray.append(object.object(forKey: "NumberOfTable") as! String)
                self.tableNumberLabel.text = "\(self.tableNumberArray.last!)"
                    
                    
                }
                self.createButton.isHidden = false
                self.textField.text = ""
            }
        }
        
    }
    var button = UIButton()
    func createBtn(){
        button = UIButton()

        button.frame = CGRect(x:   xLocation, y:   yLocation, width: buttonWidth, height: buttonHeight)
        button.backgroundColor = tableBottomBackgroundColor
        button.setTitle("\(tableNumber + 1)", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        tableButtonBackgroundColorAray.append(button)
        
        self.view.addSubview(button)
    }
    
    
    @objc func buttonAction(sender: UIButton!) {
        
        if let buttonTitle = sender.title(for: .normal) {
            globalChosenTableNumber = buttonTitle
        }
        self.performSegue(withIdentifier: "tableToPopUp", sender: nil)
    }
    
    
    
    @IBAction func createButtonClicked(_ sender: Any) {
        
        if tableNumberLabel == nil {
            let alert = UIAlertController(title: "Eski Masa Sayısını Silin", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
        else if tableNumberLabel != nil{
            
        if textField.text != "" {
        
            dismissKeyboard()

            let numberOfTables = PFObject(className: "TableNumbers")
            numberOfTables["TableOwner"] = PFUser.current()!.username!
            numberOfTables["NumberOfTable"] = textField.text!
            
            
            let textfieldInt: Int? = Int(textField.text!)
            
            if textfieldInt! <= 50 {
              
            while tableNumber < textfieldInt! {
                
                 createBtn()
                 tableNumber = tableNumber + 1
                
                if CGFloat(xLocation) < screenWidth - CGFloat(buttonWidth * 2) {
                xLocation = xLocation + buttonWidth + spacer
                }
                else if CGFloat(xLocation) >= screenWidth - CGFloat(buttonWidth * 2)  {
                xLocation = 10
                yLocation = yLocation + buttonWidth + spacer
                }
              
            }
                numberOfTables.saveInBackground { (success, error) in
                        if error != nil{
                            let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                            alert.addAction(okButton)
                            self.present(alert, animated: true, completion: nil)
                        }
                        else{
                            let alert = UIAlertController(title: "Masa Oluşturuldu", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                            alert.addAction(okButton)
                            self.present(alert, animated: true, completion: nil)
                    }
                }
             
        }
                
            else{
                let alert = UIAlertController(title: "En Fazla 50 Masa Olabilir", message: "", preferredStyle: UIAlertControllerStyle.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            tableNumberLabel.text!=textField.text!
            self.textField.text = ""
            createButton.isHidden = false
            deleteButton.isHidden = false
            
        }
    
        else{
            let alert = UIAlertController(title: "Lütfen Masa Sayısı Giriniz", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
    }
        
    }
    
    func deleteTableData(){
        let query = PFQuery(className: "TableNumbers")
        query.whereKey("TableOwner", equalTo: "\(PFUser.current()!.username!)")
        
        query.findObjectsInBackground { (objects, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                self.tableNumberArray.removeAll(keepingCapacity: false)
                for object in objects!{
                    object.deleteInBackground()
                    
                    print("Masa Silindi")
                    
                    self.xLocation = 10
                    self.yLocation = 100
                    
                }
//                 yeni button vb eklerken buradan düzelt
                var viewItemNumber = Int(self.tableNumberLabel.text!)! + 3
                while self.view.subviews.count > 4 {
                    self.view.subviews[viewItemNumber].removeFromSuperview()
                    viewItemNumber -= 1
                }
                 self.tableNumberLabel.text = ""

            }
        }
      
    }
    
  
    @IBAction func deleteButtonPressed(_ sender: Any) {
    
       deleteTableData()
        tableNumber = 0
        createButton.isHidden = false
        deleteButton.isHidden = true

    }

    func dismissKeyboard() {
    view.endEditing(true)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tableToPopUp" {
            let destination = segue.destination as! PopUpVC
            destination.delegate = self
        }
    }
   
}

extension MasaVC : SetTableButtonColor {
    func setTableButtonColor() {
        
        let tableButtonIndex = Int(globalChosenTableNumber)! - 1
        tableButtonBackgroundColorAray[tableButtonIndex].backgroundColor = UIColor.blue
    }
    
}
