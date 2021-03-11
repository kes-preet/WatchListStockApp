//
//  WatchListViewController.swift
//  WatchListStockApp
//
//  Created by Preetham Kesineni on 3/9/21.
//

import UIKit
import RealmSwift

protocol WatchListProtocols {
    func dismissView()
}

class WatchListViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate, WatchListProtocols{
    
    //Delegate for ViewController protocol functions
    var delegate: refreshViewController?

    //Outlets
    @IBOutlet weak var watchListTable: UITableView!
    
    let realm = try! Realm()

    // Alert object
    let alert = UIAlertController(title: "New Watchlist", message: "Please enter a valid name",preferredStyle: .alert)
    
    var newWatchListName: String?
    var watchLists: Results<WatchList>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        watchListTable.delegate = self
        watchListTable.dataSource = self
        
        watchListTable.register(WatchListTableCell.nib(), forCellReuseIdentifier: WatchListTableCell.identifier)
        
        self.watchLists = self.realm.objects(WatchList.self).sorted(byKeyPath: "name")
        
        
        // preparing alert object
        self.alert.addTextField { (textField) in
            textField.placeholder = "name here"
        
        }
        
        // Take value from textfield and create new watchlist with default tickers giving the name offered by textfield entered in alert
        self.alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak alert] (_) in
            
            let textField = alert?.textFields?[0]
            let watchLists = self.realm.objects(WatchList.self)
            
            try! self.realm.write{
                watchLists.setValue(false, forKey: "isActive")
            }
            
            try! self.realm.write {
                self.realm.create(WatchList.self, value: ["name": textField?.text,"Tickers":"AAPL,GOOG,MSFT","isActive":true], update: .all)
            }
            
            self.delegate?.refreshActiveWatchlist()
            self.dismissView()
        }))
    }
    

    
    // New watchlist Button present the alert
    @IBAction func addNewWatchList(_ sender: UIButton) {
        
        self.present(alert, animated: true, completion: nil)

    }
    
    // Dismiss view helper function
    public func dismissView(){
        dismiss(animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return watchLists!.count
    }
    
    // Custom cell prepartion
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: WatchListTableCell.identifier) as! WatchListTableCell
        cell.delegate = self.delegate
        cell.secondDelegate = self
        
        if cell == nil {
            cell = UITableViewCell(style: .default,reuseIdentifier: WatchListTableCell.identifier) as! WatchListTableCell
        }
        
        let watchListName = watchLists![indexPath.row].name
        cell.WatchListName.text = watchListName
        cell.WatchListContents.text = watchLists![indexPath.row].Tickers
        
        // Active watchlist Icon code setting alpha of imageview based on isActive or not
        if watchLists![indexPath.row].isActive == false {
            cell.activeIcon.alpha = 0.0
        }
        else {
            cell.activeIcon.alpha = 1.0
        }
        
        return cell
    }

    
    // Handling Deletion of Watch Lists
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            if watchLists!.count > 1 {
            
                let data = self.realm.object(ofType: WatchList.self, forPrimaryKey: self.watchLists![indexPath.row].name)
                
                let isCurrentActiveList = data?.isActive
                
                
                try! self.realm.write {
                    
                    self.realm.delete(data!)
                    
                    
                    if isCurrentActiveList == true {
                        let changeToThisList = self.realm.objects(WatchList.self).filter("name contains '\(self.watchLists![0].name)'").first
                        
                        changeToThisList?.isActive = true
                    }
                }
                
                self.realm.refresh()
                
                self.delegate?.refreshActiveWatchlist()
                
                

                
                self.watchListTable.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    


}
