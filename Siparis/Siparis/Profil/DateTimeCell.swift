//
//  DateTimeCell.swift
//  Siparis
//
//  Created by Batuhan Erkol on 23.11.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse

class DateTimeCell: UITableViewCell {
   
    @IBOutlet weak var tlLabel: UILabel!
    @IBOutlet weak var odemeYontemi: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var paymentLabel: UILabel!
    @IBOutlet weak var foodNamesTable: UITableView!
    @IBOutlet weak var sumPriceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    lazy var labelsToHide: [UILabel] = [tlLabel,odemeYontemi,paymentLabel,timeLabel,dateLabel]
    
    var setLabelsCenter = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if setLabelsCenter {
            totalPriceLabel.center = self.center
            sumPriceLabel.center = self.center
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
