//
//  PopUpTVC.swift
//  Siparis
//
//  Created by Batuhan Erkol on 20.10.2018.
//  Copyright © 2018 Batuhan Erkol. All rights reserved.
//

import UIKit
import Parse

class PopUpTVC: UITableViewCell {

    @IBOutlet weak var doneLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var foodNoteLabel: UILabel!
    @IBOutlet weak var foodPriceLabel: UILabel!
    @IBOutlet weak var foodNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.doneLabel.isHidden = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

     
       
    }

}

