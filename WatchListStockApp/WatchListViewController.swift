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
    
    var delegate: refreshViewController?

    @IBOutlet weak var watchListTable: UITableView!
    
    
    
    let realm = try! Realm()
    
    
    var watchLists: Results<WatchList>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        watchListTable.delegate = self
        watchListTable.dataSource = self
        
        watchListTable.register(WatchListTableCell.nib(), forCellReuseIdentifier: WatchListTableCell.identifier)
        
        self.watchLists = self.realm.objects(WatchList.self).sorted(byKeyPath: "name")
        
        
        
        // Do any additional setup after loading the view.
    }
    
    
    //TODO: create a new watchlist object and add it to the realm db
    
    //TODO: set this as the new active
    
    //COMPLETE: dismiss the view
    
    @IBAction func addNewWatchList(_ sender: UIButton) {
        
        
        
        
        
        
        dismissView()
    }
    
    
    public func dismissView()
    {
        dismiss(animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return watchLists!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: WatchListTableCell.identifier) as! WatchListTableCell
        cell.delegate = self.delegate
        cell.secondDelegate = self
        if cell == nil {
            cell = UITableViewCell(style: .default,reuseIdentifier: WatchListTableCell.identifier) as! WatchListTableCell
        }
        
        let watchListName = watchLists![indexPath.row].name
        
        //cell.textLabel?.text = watchListName
        cell.button.setTitle(watchListName, for: .normal)
        
        if watchLists![indexPath.row].isActive == false {
            cell.activeIcon.alpha = 0.0
        }
        else {
            cell.activeIcon.alpha = 1.0
        }
        
        return cell
    }
    
    
    //COMPLETED: need to place some sort of indicator for the user to allow them to see if this is the currently active list
    
    //COMPLETED: Need to make the change to default list only occur if this is the currently active list
    
    //COMPLETED: Dont let the user be able to delete all the watch lists. There has to be One in the system at all times
    
    //COMPLETED: need to invoke a refresh of the active watchlist in the Main View controller
    
    //TODO: Notify the user when they are not allowed to delete a watch list since it is the only watchlist left
    
    //QOL: Push notify the user if they really want to delete a watch list
    
    
    
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
