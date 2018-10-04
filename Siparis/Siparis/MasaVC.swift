//
//  MasaVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 3.09.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse

class MasaVC: UIViewController {

    var xLocation = 10
    var yLocation = 100
    
    var buttonWidth = 80
    var buttonHeight = 80
    
    var spacer = 10
    
    var tableNumber = 0
    
    var tableNumberArray = [String]()
    var tableNumberText = ""
    
    
    
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
        if textField.text != ""{
            

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
                    
                       self.textField.text! = self.tableNumberLabel.text!
                }
            }
        }
        
    }
    var button = UIButton()
    func createBtn(){
        button = UIButton()

        button.frame = CGRect(x:   xLocation, y:   yLocation, width: buttonWidth, height: buttonHeight)
        button.backgroundColor = UIColor.gray
        button.setTitle("\(tableNumber + 1) ", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        
        self.view.addSubview(button)
        print("button created")
        
    }
    @objc func buttonAction(sender: UIButton!) {
        print("Button tapped ")
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
            textField.text! = ""
            createButton.isHidden = true
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
                    
                }
//                self.button.removeFromSuperview()
                var i = Int(self.tableNumberLabel.text!)! + 3
                while self.view.subviews.count > 4 {
                    self.view.subviews[i].removeFromSuperview()
                    i -= 1
                }
                

            }
        }
        xLocation = 10
        yLocation = 100
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
}
