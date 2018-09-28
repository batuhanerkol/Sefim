//
//  MasaVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 3.09.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit

class MasaVC: UIViewController {

    var xLocation = 10
    var yLocation = 120
   
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    func createButton(){
        let button = UIButton()
        button.frame = CGRect(x:   xLocation, y:   yLocation, width: 70, height: 70)
        button.backgroundColor = UIColor.red
        button.setTitle("masa: ", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(button)
        
        print("button created")
    }
    @objc func buttonAction(sender: UIButton!) {
        print("Button tapped")
    }
    
    @IBAction func createButtonClicked(_ sender: Any) {
        
        if textField.text != ""{
            
            var tableNumber = 0
            let textfieldInt: Int? = Int(textField.text!)
            
            if textfieldInt! < 50 {
            while tableNumber < textfieldInt! {
                createButton()
                 tableNumber = tableNumber + 1
                
                if xLocation < 280{
                xLocation = xLocation + 80
                }
                else if xLocation >= 280 {
                xLocation = 10
                yLocation = yLocation + 80
                }
            }
        }
            else{
                let alert = UIAlertController(title: "En Fazla 50 Masa Olabilir", message: "", preferredStyle: UIAlertControllerStyle.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
        }
        else{
            let alert = UIAlertController(title: "Lütfen Masa Sayısı Giriniz", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @IBAction func deleteButtonPressed(_ sender: Any) {
        
    }
}
