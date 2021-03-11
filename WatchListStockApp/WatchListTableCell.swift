//
//  WatchListTableCell.swift
//  WatchListStockApp
//
//  Created by Preetham Kesineni on 3/9/21.
//

import UIKit
import RealmSwift


class WatchListTableCell: UITableViewCell {

    var delegate: refreshViewController?
    
    var secondDelegate: WatchListProtocols?
    
    static let identifier = "WatchListTableCell"
    
    let realm = try! Realm()
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    //IB Outlets
    @IBOutlet var button: UIButton!
    @IBOutlet weak var WatchListName: UILabel!
    @IBOutlet weak var WatchListContents: UILabel!
    @IBOutlet var activeIcon: UIImageView!
    
    // Unactive current watchlist and reactivate selected watchlist to swap betweeen and dismiss view using prior protocol function
    @IBAction func didTapButton()
    {
        let watchListName = WatchListName.text
        
        DispatchQueue.main.async {
            autoreleasepool
            {
                let watchLists = self.realm.objects(WatchList.self)
                
                try! self.realm.write{
                    watchLists.setValue(false, forKey: "isActive")
                }
                
                let setActiveWatchList = self.realm.objects(WatchList.self).filter("name contains '\(watchListName!)'").first
                
                try! self.realm.write{
                    setActiveWatchList!.isActive = true
                }
                self.delegate?.refreshActiveWatchlist()
            }
            
            self.secondDelegate?.dismissView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }


    
}
