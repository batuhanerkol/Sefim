//
//  UygulamaHakkindaVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 15.01.2019.
//  Copyright © 2019 Batuhan Erkol. All rights reserved.
//

import UIKit

class UygulamaHakkindaVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func iletisimClicked(_ sender: Any) {
        let email = "iletisim@sefimapp.com"
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
    
}
