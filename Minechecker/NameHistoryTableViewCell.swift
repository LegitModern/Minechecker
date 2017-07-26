//
//  NameHistoryTableViewCell.swift
//  Minehistory
//
//  Created by Ryan Donaldson on 7/22/15.
//  Copyright (c) 2015 Ryan Donaldson. All rights reserved.
//

import UIKit

class NameHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var playerName: UILabel!
    @IBOutlet weak var nameChangedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
