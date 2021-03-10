//
//  SearchViewTableCell.swift
//  WatchListStockApp
//
//  Created by Preetham Kesineni on 3/9/21.
//

import UIKit

class SearchViewTableCell: UITableViewCell {

    
    static let identifier = "SearchViewTableCell"
    
    @IBOutlet weak var symbolLabel: UILabel!
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    
    @IBAction func didTapButton(_ sender: UIButton) {
        
        
        
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
    }


    
}
