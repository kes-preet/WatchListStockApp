//
//  CustomTableViewCell.swift
//  WatchListStockApp
//
//  Created by Preetham Kesineni on 3/7/21.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet var myLabel: UILabel!
    @IBOutlet var myImageView: UIImageView!
    @IBOutlet var myPriceLabel: UILabel!
    @IBOutlet var myAskPriceLabel: UILabel!
    @IBOutlet var myBidPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
