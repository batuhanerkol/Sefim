//
//  OncekiSiparislerTVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 20.11.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit

class OncekiSiparislerTVC: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
   
    @IBOutlet weak var foodNameTable: UITableView!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var foodNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        foodNameTable.delegate = self
        foodNameTable.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodNameCell", for: indexPath) as! FoodNameCell
        cell.foodNameLabel.text! = "MEtn bey"
        print("berkay bey")
        return cell
    }
    
    
}
