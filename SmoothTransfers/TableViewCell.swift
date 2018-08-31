//
//  TableViewCell.swift
//  SmoothTransfers
//
//  Created by Noritaka Sekiyama on 2018/08/31.
//  Copyright © 2018年 Noritaka Sekiyama. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
