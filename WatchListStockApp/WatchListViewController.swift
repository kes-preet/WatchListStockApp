//
//  WatchListViewController.swift
//  WatchListStockApp
//
//  Created by Preetham Kesineni on 3/9/21.
//

import UIKit
import RealmSwift

class WatchListViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate{

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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return watchLists!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: WatchListTableCell.identifier) as! WatchListTableCell
        if cell == nil {
            cell = UITableViewCell(style: .default,reuseIdentifier: WatchListTableCell.identifier) as! WatchListTableCell
        }
        
        let watchListName = watchLists![indexPath.row].name

        cell.button.setTitle(watchListName, for: .normal)
        
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
