//
//  CustomTableViewCell.swift
//  WatchListStockApp
//
//  Created by Preetham Kesineni on 3/7/21.
//

import UIKit

//Custom Table View Cell Class
class CustomTableViewCell: UITableViewCell {

    //Outlets
    @IBOutlet var myLabel: UILabel!
    @IBOutlet var myImageView: UIImageView!
    @IBOutlet var myPriceLabel: UILabel!
    @IBOutlet var myAskPriceLabel: UILabel!
    @IBOutlet var myBidPriceLabel: UILabel!
    @IBOutlet weak var myNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
