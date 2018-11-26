//
//  FoodPriceCell.swift
//  Siparis
//
//  Created by Batuhan Erkol on 26.11.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit

class FoodPriceCell: UITableViewCell {

    @IBOutlet weak var foodPriceLabel: UILabel!
    @IBOutlet weak var foodNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
