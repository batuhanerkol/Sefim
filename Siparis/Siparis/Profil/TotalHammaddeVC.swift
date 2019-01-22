//
//  TotalHammaddeVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 18.01.2019.
//  Copyright © 2019 Batuhan Erkol. All rights reserved.
//
import UIKit

class TotalHammaddeVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var toplamMiktarLabel: UILabel!
    @IBOutlet weak var hammaddeAdiLabel: UILabel!
    @IBOutlet weak var secilenUrunAdi: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedHammadde = [String]()
    var selectedHammaddeMiktar = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    // bu sayfaya gelmek için identifier = toTotalHammadde
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return selectedHammadde.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "totalcellidentifier", for: indexPath) as! TotalHammaddeCell
            cell.hammaddeAdiLabel.text = selectedHammadde[indexPath.row]
            cell.hammaddeMiktarıLabel.text = selectedHammaddeMiktar[indexPath.row]
        return cell
    }

  
}
