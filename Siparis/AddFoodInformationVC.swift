//
//  FoodInformationVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 8.09.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse
class AddFoodInformationVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    var businessName = ""
    var nameArray = [String]()
    
    var hammaddeAdiArray = [String]()
    var hammaddeToplamAdiArray = [String]()
    var hammaddeFiyatlariArray = [String]()
    
    var hammaddePicker = UIPickerView()
     var hammadde2Picker = UIPickerView()
     var hammadde3Picker = UIPickerView()
     var hammadde4Picker = UIPickerView()
    

    
    @IBOutlet weak var longTextField: UITextView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var selectedImage: UIImageView!
    

    @IBOutlet weak var hammadde1Text: UITextField!
    @IBOutlet weak var hammadde2Text: UITextField!
    @IBOutlet weak var hammadde3Text: UITextField!
    @IBOutlet weak var hammadde4Text: UITextField!
    @IBOutlet weak var miktar1Text: UITextField!
    @IBOutlet weak var miktar2Text: UITextField!
    @IBOutlet weak var miktar3Text: UITextField!
    @IBOutlet weak var miktar4Text: UITextField!
    
    
        var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //internet kontrolu
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
        updateUserInterface()


        
          selectedImage.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddFoodInformationVC.selectImage))
            selectedImage.addGestureRecognizer(gestureRecognizer)
        
     
        // loading sembolu
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorView.Style.gray
        view.addSubview(activityIndicator)

        
        
          priceTextField.delegate = self
          miktar1Text.delegate = self
          miktar2Text.delegate = self
          miktar3Text.delegate = self
          miktar4Text.delegate = self
        
        
           hammaddePicker.delegate = self
           hammadde2Picker.delegate = self
           hammadde3Picker.delegate = self
           hammadde4Picker.delegate = self
        
        hammadde1Text.inputView = hammaddePicker
        hammadde2Text.inputView = hammadde2Picker
        hammadde3Text.inputView = hammadde3Picker
        hammadde4Text.inputView = hammadde4Picker
        
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        updateUserInterface()
    }
    
    func createToolbar(){
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Seç", style: .plain, target: self, action: #selector(OncekiSiparislerVC.dismissKeyboard))
        
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        hammadde1Text.inputAccessoryView = toolBar
        hammadde2Text.inputAccessoryView = toolBar
        hammadde3Text.inputAccessoryView = toolBar
        hammadde4Text.inputAccessoryView = toolBar
        
    }
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    
    func updateUserInterface() {
        guard let status = Network.reachability?.status else { return }
        switch status {
        case .unreachable:
            let alert = UIAlertController(title: "İnternet Bağlantınız Bulunmuyor.", message: "Lütfen Kontrol Edin", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
            
            self.confirmButton.isEnabled = false
            
        case .wifi:
             self.confirmButton.isEnabled = true
             getBussinessNameData()
            getHammaddeData()
             createToolbar()
        case .wwan:
             getBussinessNameData()
             getHammaddeData()
              createToolbar()
             self.confirmButton.isEnabled = true
        }
    }
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
    
    @objc func selectImage() {
        
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        selectedImage.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func confirmButtonPressed(_ sender: Any) {
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
            addFoodInfo()
     
    }
    
    func addFoodInfo(){
        
        if textField.text != "" && longTextField.text != "" && priceTextField.text != ""  {
            if controlTextFields(){
           
            self.confirmButton.isHidden = true
            
            addFiyatToArray()

            
            let foodInformation = PFObject(className: "FoodInformation")
            foodInformation["foodName"] = textField.text!
            foodInformation["foodInformation"] = longTextField.text!
            foodInformation["foodPrice"] = priceTextField.text!
            foodInformation["foodNameOwner"] = PFUser.current()!.username!
            foodInformation["foodTitle"] = selectecTitle
            foodInformation["BusinessName"] = businessName
            foodInformation["HesapOnaylandi"] = ""
            foodInformation["Hammadde"] = hammaddeToplamAdiArray
            foodInformation["HammaddeFiyatlari"] = hammaddeFiyatlariArray

            
            if let imageData = UIImageJPEGRepresentation(selectedImage.image!, 0.5){
                foodInformation["image"] = PFFile(name: "image.jpg", data: imageData)
            }
            
            foodInformation.saveInBackground { (success, error) in
                
                if self.textField.text != "" && self.longTextField.text != "" && self.priceTextField.text != ""{
                    
                    if error != nil{
                        let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                        alert.addAction(okButton)
                        self.present(alert, animated: true, completion: nil)
                        
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                    }
                    else{
                        
                        print("success")
                        self.confirmButton.isHidden = false
                        self.priceTextField.text = ""
                        self.textField.text = ""
                        self.longTextField.text = ""
                        self.selectedImage.image = UIImage(named: "fotosecin.png")
                        self.hammadde1Text.text = ""
                        self.hammadde2Text.text = ""
                        self.hammadde3Text.text = ""
                        self.hammadde4Text.text = ""
                        self.miktar1Text.text = ""
                        self.miktar2Text.text = ""
                        self.miktar3Text.text = ""
                        self.miktar4Text.text = ""
                        
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        
                    }
                }
                else if self.textField.text == "" || self.longTextField.text == "" || self.priceTextField.text == ""{
                    let alert = UIAlertController(title: "HATA", message: "Lütfen Bilgileri Tam Giriniz", preferredStyle: UIAlertControllerStyle.alert)
                    let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                }
            }
        }
        }
        else if self.textField.text == "" || self.longTextField.text == "" || self.priceTextField.text == ""{
            let alert = UIAlertController(title: "HATA", message: "Lütfen Bilgileri Tam Giriniz", preferredStyle: UIAlertControllerStyle.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
            
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
        }
        
    }
    
    func controlTextFields() -> Bool{
        
        if self.hammadde1Text.text != "" && miktar1Text.text == "" {
            let alert = UIAlertController(title: "Lütfen 1. Miktarı Girin", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
            
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
             return false
        }
        else  if self.hammadde2Text.text! != "" && miktar2Text.text == "" {
            let alert = UIAlertController(title: "Lütfen 2. Miktarı Girin", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
            
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
             return false
        }
        else  if self.hammadde3Text.text! != "" && miktar3Text.text == "" {
            let alert = UIAlertController(title: "Lütfen 3. Miktarı Girin", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
            
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
             return false
        }
        else  if self.hammadde4Text.text! != "" && miktar4Text.text == "" {
            let alert = UIAlertController(title: "Lütfen 4. Miktarı Girin", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
            
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            return false
        }
        else{
            return true
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    
    }
    func addFiyatToArray(){
         if hammadde1Text.text != "" && miktar1Text.text != ""{
            hammaddeFiyatlariArray.append(miktar1Text.text!)
            
            if hammadde2Text.text != "" && miktar2Text.text != ""{
                hammaddeFiyatlariArray.append(miktar2Text.text!)
                
                if hammadde3Text.text != "" && miktar3Text.text != ""{
                    hammaddeFiyatlariArray.append(miktar3Text.text!)
                    
                    if hammadde4Text.text != "" && miktar4Text.text != ""{
                        hammaddeFiyatlariArray.append(miktar4Text.text!)
                    }
                }
            }
        }
    
        }
    
    
    func getBussinessNameData(){
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let query = PFQuery(className: "BusinessInformation")
        query.whereKey("businessUserName", equalTo: "\(PFUser.current()!.username!)")
        
        query.findObjectsInBackground { (objects, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
                
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
            else{
                self.nameArray.removeAll(keepingCapacity: false)
                for object in objects!{
                    self.nameArray.append(object.object(forKey: "businessName") as! String)
                    
                    self.businessName = "\(self.nameArray.last!)"
                }
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
    }
    
    
    func getHammaddeData(){
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
                    for object in objects! {
                        self.hammaddeAdiArray.append(object.object(forKey: "HammaddeAdi") as! String)
                    }
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                }
            }
        }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return hammaddeAdiArray.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return hammaddeAdiArray[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == hammaddePicker{
              hammadde1Text.text = hammaddeAdiArray[row]
            hammaddeToplamAdiArray.append( hammadde1Text.text!)
        }
        else if pickerView == hammadde2Picker{
            hammadde2Text.text = hammaddeAdiArray[row]
             hammaddeToplamAdiArray.append( hammadde2Text.text!)
        }
        else if pickerView == hammadde3Picker{
            hammadde3Text.text = hammaddeAdiArray[row]
             hammaddeToplamAdiArray.append( hammadde3Text.text!)
        }
        else if pickerView == hammadde4Picker{
            hammadde4Text.text = hammaddeAdiArray[row]
             hammaddeToplamAdiArray.append( hammadde4Text.text!)
        }
     
    
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: -250, up: true)
    }
    
    // Finish Editing The Text Field
    func textFieldDidEndEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: -250, up: false)
    }
    
    // Hide the keyboard when the return key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Move the text field in a pretty animation!
    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
}
    


