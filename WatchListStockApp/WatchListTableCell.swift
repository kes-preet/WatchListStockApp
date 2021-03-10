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
    
    @IBOutlet var button: UIButton!
    
    @IBOutlet var activeIcon: UIImageView!
    
   //TODO: Get the functionality to work where i can dismiss on click of a watchlist
    
    @IBAction func didTapButton()
    {
        let watchListName = button.titleLabel?.text
        
        DispatchQueue.main.async {
            autoreleasepool
            {
                let watchLists = self.realm.objects(WatchList.self)
                
                try! self.realm.write{
                    watchLists.setValue(false, forKey: "isActive")
                }
                
                let setActiveWatchList = self.realm.objects(WatchList.self).filter("name contains '\(watchListName!)'").first
                
                try! self.realm.write
                {
                    setActiveWatchList!.isActive = true
                }
              //  ViewController().refreshActiveWatchlist() // THis is a new instance of the view controller so data not edidted properly
                self.delegate?.refreshActiveWatchlist()
            }
            
            self.secondDelegate?.dismissView()

            
        }
        
        
        
        
        
    }
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }


    
}
