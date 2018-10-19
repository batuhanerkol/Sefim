//
//  popUpVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 19.10.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit

class popUpVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func foodIsReadyButtonClicked(_ sender: Any) {
        
    }
    
    @IBAction func closePopUpButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
         dismiss(animated: true, completion: nil)
    }
}
