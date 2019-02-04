//
//  MasaVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 3.09.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse

var globalChosenTableNumberMasaVC = ""

class MasaVC: UIViewController {
    
    var hesapIstendi = ""
    var hesapIstendiArray = [String]()
    
    var hesapMasaSayisi = ""
    var hesapMasaSAyisiArray = [String]()
    
    var siparisVerildi = ""
    var siparisVerildiArray = [String]()
    
    var yemekHazir = ""
    var yemekHazirArray = [String]()
    
    var yemekTeslim = ""
    var yemekTeslimArray = [String]()
    
    var hesapOdendi = ""
    var hesapOdendiArray = [String]()

    var objectIdArray = [String]()
    var objectId = ""
    
    
    var xLocation = 10
    var yLocation = 150
    
    var buttonWidth = 80
    var buttonHeight = 80
    
    var spacer = 10
    
    var tableNumber = 0
    
    var tableNumberArray = [String]()
    var tableNumberText = ""
    
    var mevcutMasaSayisi = 0
    
    var siraIndex = 0
    
   
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()

    
    var tableBottomBackgroundColor = UIColor.gray
    var tableButtonBackgroundColorChange = [UIButton]()
    var siraLabelBackgroundColorChange = [UILabel]()
    
  public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
     public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    @IBOutlet weak var tableNumberLabel: UILabel!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
           updateUserInterface()
         
          // 10 saniyede ekranın güncellenmesi
        _ = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(viewWillAppear(_:)), userInfo: nil, repeats: true)
        
     
        // loading sembolu
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorView.Style.gray
        view.addSubview(activityIndicator)
        

    }
    override func viewWillAppear(_ animated: Bool) {
        
        tableButton.backgroundColor = .gray
        
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
            self.createButton.isEnabled = false
            
            
        case .wifi:
           buttonSizes()
           getButtonWhenAppOpen()
           getObjectId()
           controlOfButtons()
  
              self.createButton.isEnabled = true
        case .wwan:
         buttonSizes()
         getButtonWhenAppOpen()
         getObjectId()
         controlOfButtons()
 
              self.createButton.isEnabled = true
        }
    }
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
    
    func buttonSizes(){
        if screenWidth > 1000 && screenWidth < 1200 {
            buttonWidth = 90
            buttonHeight = 90
            
            xLocation = 10
            yLocation = 90
        }
        else if screenWidth > 1200{
            buttonWidth = 140
            buttonHeight = 140
        }
        else if screenWidth < 1000{
            buttonWidth = 40
            buttonHeight = 40
            
            xLocation = 10
            yLocation = 70
        }
     
    }
    //  masa bilgilerinin kayıtlı olduğu işletme satırının obejct Id si
    func getObjectId(){
        let query = PFQuery(className: "BusinessInformation")
        query.whereKey("businessUserName", equalTo: (PFUser.current()?.username)!)
        query.whereKeyExists("businessName")
        
        query.findObjectsInBackground { (objects, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                self.objectIdArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    self.objectIdArray.append(object.objectId! )
                    
                    self.objectId = "\(self.objectIdArray.last!)"
                }
            }
        }
    }
   // masaların bilgilerinin çekilmesi
    func controlOfButtons(){
         var hesapMasaSayisiIndex = 0
    
        let query = PFQuery(className: "VerilenSiparisler")
        query.whereKey("IsletmeSahibi", equalTo: (PFUser.current()?.username)!)

        query.findObjectsInBackground { (objects, error) in
            
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                self.yemekTeslimArray.removeAll(keepingCapacity: false)
                self.yemekHazirArray.removeAll(keepingCapacity: false)
                self.hesapIstendiArray.removeAll(keepingCapacity: false)
                self.hesapMasaSAyisiArray.removeAll(keepingCapacity: false)
                self.siparisVerildiArray.removeAll(keepingCapacity: false)
                self.hesapOdendiArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    
                     self.yemekTeslimArray.append(object.object(forKey: "YemekTeslimEdildi") as! String)
                    self.yemekHazirArray.append(object.object(forKey: "YemekHazir") as! String)
                    self.hesapIstendiArray.append(object.object(forKey: "HesapIstendi") as! String)
                    self.hesapMasaSAyisiArray.append(object.object(forKey: "MasaNo") as! String)
                   self.siparisVerildiArray.append(object.object(forKey: "SiparisVerildi") as! String)
                  self.hesapOdendiArray.append(object.object(forKey: "HesapOdendi") as! String)
                }

//                print("-----------control of buttons----------------")
//                print("hesapMasaSayisi",self.hesapMasaSAyisiArray)
//                print("siparisVerildi",self.siparisVerildiArray )
//                print("yemekHazir", self.yemekHazirArray)
//                print("YemekTeslim:",  self.yemekTeslimArray)
//                print("hesapIstendi", self.hesapIstendiArray)
//                print("hesapmasaArray,", self.hesapMasaSAyisiArray)

                // BUARADA MASALARIN DURUMUANA GÖRE "YEMEK HAZIR VB"  RENK DEĞİŞİMLERİNİ GERÇEKLEŞTİRİLİYOR
        
                if  self.tableButtonBackgroundColorChange.count > 0  && self.hesapMasaSAyisiArray.isEmpty == false{
         
                    while hesapMasaSayisiIndex < self.hesapMasaSAyisiArray.count {
                        
                       
                       
                    let tableButtonIndex = Int(self.hesapMasaSAyisiArray[hesapMasaSayisiIndex])! - 1  // işlem yapılan bütün masaların renk değişimleri gerçekleşsin
    
                if self.siparisVerildiArray[hesapMasaSayisiIndex] == "Evet" && self.yemekHazirArray[hesapMasaSayisiIndex] == "" && self.yemekTeslimArray[hesapMasaSayisiIndex] == "" && self.hesapIstendiArray[hesapMasaSayisiIndex] == "" && self.hesapOdendiArray[hesapMasaSayisiIndex] == "" {
                    
                    self.tableButtonBackgroundColorChange[tableButtonIndex].backgroundColor = UIColor.orange
                    self.siraLabelBackgroundColorChange[tableButtonIndex].backgroundColor = UIColor.orange
                    
                    self.siraIndex += 1
                    
                    self.siraLabelBackgroundColorChange[tableButtonIndex].text = "sıra:\(self.siraIndex)"
   
                    print("tableButtonIndex:", tableButtonIndex) // +1 == rengi değişmiş masa
                }
                else  if self.siparisVerildiArray[hesapMasaSayisiIndex] == "Evet" && self.yemekHazirArray[hesapMasaSayisiIndex] == "Evet" && self.yemekTeslimArray[hesapMasaSayisiIndex] == ""  && self.hesapIstendiArray[hesapMasaSayisiIndex] == "" && self.hesapOdendiArray[hesapMasaSayisiIndex] == ""{
                    
                    self.tableButtonBackgroundColorChange[tableButtonIndex].backgroundColor = UIColor.blue
                    self.siraLabelBackgroundColorChange[tableButtonIndex].backgroundColor = UIColor.blue
                
                    }
                else  if self.siparisVerildiArray[hesapMasaSayisiIndex] == "Evet" && self.yemekHazirArray[hesapMasaSayisiIndex] == "Evet" && self.yemekTeslimArray[hesapMasaSayisiIndex] == "Evet"  && self.hesapIstendiArray[hesapMasaSayisiIndex] == "" && self.hesapOdendiArray[hesapMasaSayisiIndex] == ""{
                    
                    self.tableButtonBackgroundColorChange[tableButtonIndex].backgroundColor = UIColor.green
                    self.siraLabelBackgroundColorChange[tableButtonIndex].backgroundColor = UIColor.green
                 
                    }
                else  if self.siparisVerildiArray[hesapMasaSayisiIndex] == "Evet" && self.yemekHazirArray[hesapMasaSayisiIndex] == "Evet" && self.yemekTeslimArray[hesapMasaSayisiIndex] == "Evet"  && self.hesapIstendiArray[hesapMasaSayisiIndex] != "" && self.hesapOdendiArray[hesapMasaSayisiIndex] == ""{
                    
                    self.tableButtonBackgroundColorChange[tableButtonIndex].backgroundColor = UIColor.red
                    self.siraLabelBackgroundColorChange[tableButtonIndex].backgroundColor = UIColor.red
              
                    }
                else  if self.siparisVerildiArray[hesapMasaSayisiIndex] == "Evet" && self.yemekHazirArray[hesapMasaSayisiIndex] == "Evet" && self.yemekTeslimArray[hesapMasaSayisiIndex] == "Evet"  && self.hesapIstendiArray[hesapMasaSayisiIndex] != "" && self.hesapOdendiArray[hesapMasaSayisiIndex] != ""{
                    
                     self.tableButtonBackgroundColorChange[tableButtonIndex].backgroundColor = UIColor.gray
                    self.siraLabelBackgroundColorChange[tableButtonIndex].backgroundColor = UIColor.gray
                    
                     self.siraLabelBackgroundColorChange[tableButtonIndex].text = "sıra:..."
                    
                        }
                
                        hesapMasaSayisiIndex += 1
                }
                    
                    
                }else{
                    self.tableBottomBackgroundColor = UIColor.gray
                }
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                
                   self.siraIndex = 0
            }
            
        }
    }
    
   
    func getButtonWhenAppOpen(){ // uygulama açıldığında mevcut masa sayısını çekmek ve msaları oluşturmak için

        let query = PFQuery(className: "BusinessInformation")
        query.whereKey("businessUserName", equalTo: "\(PFUser.current()!.username!)")
        query.whereKeyExists("MasaSayisi")
        
        query.findObjectsInBackground { (objects, error) in
            if error != nil{
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                for object in objects!{
                    self.tableNumberArray.append(object.object(forKey: "MasaSayisi") as! String)
                    self.tableNumberLabel.text = "\(self.tableNumberArray.last!)"
                    
                    self.textField.text! = self.tableNumberLabel.text!
                    
                    self.mevcutMasaSayisi = Int(self.tableNumberLabel.text!)!
                    
                    
                }
                while self.tableNumber < self.mevcutMasaSayisi {
                    self.createTableButton()
                    self.createSiraLabel()
                    self.tableNumber = self.tableNumber + 1
                    
                    if CGFloat(self.xLocation) < self.screenWidth - CGFloat(self.buttonWidth * 2) {
                        self.xLocation = self.xLocation + self.buttonWidth + self.spacer
                    }
                    else if CGFloat(self.xLocation) >= self.screenWidth - CGFloat(self.buttonWidth * 2)  {
                        self.xLocation = 10
                        self.yLocation = self.yLocation + self.buttonWidth + self.spacer + 10
                    }
                    
                }
            }
        }
       
    }

    //   Masalar
    var tableButton = UIButton()
    func createTableButton(){
        tableButton = UIButton()
        if UIDevice.current.orientation.isPortrait{
        tableButton.frame = CGRect(x:   xLocation, y:   yLocation + 25, width: buttonWidth, height: buttonHeight)
        }else{
            tableButton.frame = CGRect(x:   xLocation, y:   yLocation + 5 , width: buttonWidth, height: buttonHeight)
        }
        tableButton.backgroundColor = tableBottomBackgroundColor
        tableButton.setTitle("\(tableNumber + 1)", for: .normal)
        tableButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        tableButtonBackgroundColorChange.append(tableButton)
        
        self.view.addSubview(tableButton)
    }
    
    //   SıraNo:
    var siraLabel = UILabel()
    func createSiraLabel(){
        siraLabel = UILabel()
        if UIDevice.current.orientation.isPortrait{
        siraLabel.frame = CGRect(x:   xLocation, y:   yLocation - (buttonHeight / 3) + 25, width: buttonWidth, height: buttonHeight / 3)
        }else{
            siraLabel.frame = CGRect(x:   xLocation, y:   yLocation - (buttonHeight / 3) + 5, width: buttonWidth, height: buttonHeight / 3)
        }
        siraLabel.backgroundColor = tableBottomBackgroundColor
        siraLabel.textColor = .white
        siraLabel.text = "Sıra:..."
        siraLabel.font = siraLabel.font.withSize(9)
        siraLabelBackgroundColorChange.append(siraLabel)
        
        self.view.addSubview(siraLabel)
    }

    
    @objc func buttonAction(sender: UIButton!) {
        
        if let buttonTitle = sender.title(for: .normal) {
            globalChosenTableNumberMasaVC = buttonTitle
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

            let query = PFQuery(className: "BusinessInformation")
            query.whereKey("businessUserName", equalTo: "\(PFUser.current()!.username!)")
            query.whereKeyExists("businessName")
            
            let textfieldInt: Int? = Int(textField.text!)
            
            if textfieldInt! <= 50 {
              
            while tableNumber < textfieldInt! {
                
                 createTableButton()
                createSiraLabel()
                 tableNumber = tableNumber + 1
                
                if CGFloat(xLocation) < screenWidth - CGFloat(buttonWidth * 2) {
                xLocation = xLocation + buttonWidth + spacer
                }
                else if CGFloat(xLocation) >= screenWidth - CGFloat(buttonWidth * 2)  {
                xLocation = 10
                yLocation = yLocation + buttonWidth + spacer
                }
              
            }
                query.getObjectInBackground(withId: objectId) { (objects, error) in
                        if error != nil{
                            let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
                            alert.addAction(okButton)
                            self.present(alert, animated: true, completion: nil)
                        }
                        else{
                            
                            objects!["MasaSayisi"] = String(self.tableNumber)
                             objects!.saveInBackground()
                            
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
            
        }
    
        else{
            let alert = UIAlertController(title: "Lütfen Masa Sayısı Giriniz", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
    }
        
    }
    
//    func deleteTableData(){ // silme işlemi artık yapılmıyor Lazım olabilir diye dursun
//        let query = PFQuery(className: "BusinessInformation")
//        query.whereKey("businessUserName", equalTo: "\(PFUser.current()!.username!)")
//        query.whereKeyExists("MasaSayisi")
//
//        query.getObjectInBackground(withId: objectId) { (objects, error) in
//            if error != nil{
//                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
//                let okButton = UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.cancel, handler: nil)
//                alert.addAction(okButton)
//                self.present(alert, animated: true, completion: nil)
//            }
//            else{
//
//                    objects!["MasaSayisi"] = ""
//                    objects!.saveInBackground()
//
//
//                    self.xLocation = 10
//                    self.yLocation = 100
//
//
//                // yeni button vb eklerken buradan düzelt çünkü silerken ekranda gözüken onje sayısına göre siliyor
//                // silme işlemi yapılmıyor artık
//                var viewItemNumber = Int(self.tableNumberLabel.text!)! + 3
//                while self.view.subviews.count > 4 {
//                    self.view.subviews[viewItemNumber].removeFromSuperview()
//                    viewItemNumber -= 1
//                }
//                 self.tableNumberLabel.text = ""
//
//            }
//        }
//
//    }
//
//
   
    @IBAction func updateButtonPressed(_ sender: Any) {
        
       viewDidLoad()
       
    }
    
    func dismissKeyboard() {
    view.endEditing(true)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        var text=""
        switch UIDevice.current.orientation{
        case .portrait:
            text="Portrait"
        case .portraitUpsideDown:
            text="PortraitUpsideDown"
        case .landscapeLeft:
            text="LandscapeLeft"
        case .landscapeRight:
            text="LandscapeRight"
        default:
            text="Another"
        }
        NSLog("You have moved: \(text)")
    }
}

