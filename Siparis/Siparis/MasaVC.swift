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
    var yLocation = 10
    var tableNumber = 0
    
  public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
     public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if textField.text != nil{
          
        }
    }
    func createBtn(){
        let button = UIButton()

        button.frame = CGRect(x:   xLocation, y:   yLocation, width: 80, height: 80)
        button.backgroundColor = UIColor.gray
        button.setTitle("\(tableNumber + 1) ", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)

        self.view.addSubview(button)
        myScrollView.addSubview(button)
        myScrollView.contentSize = CGSize(width: xLocation, height: yLocation)
        
        print("button created")
        
    }
    @objc func buttonAction(sender: UIButton!) {
        print("Button tapped")
    }
    
    @IBAction func createButtonClicked(_ sender: Any) {
        
        if textField.text != ""{
            dismissKeyboard()

            let textfieldInt: Int? = Int(textField.text!)
            
            if textfieldInt! <= 50 {
              
            while tableNumber < textfieldInt! {
                
                 createBtn()
                 tableNumber = tableNumber + 1
                
                if CGFloat(xLocation) < screenWidth{
                xLocation = xLocation + 90
                }
                else if CGFloat(xLocation) >= screenWidth {
                xLocation = 10
                yLocation = yLocation + 90
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
      myScrollView.removeFromSuperview()

        textField.text = ""

    }
   
    func dismissKeyboard() {
    view.endEditing(true)
    }
}
