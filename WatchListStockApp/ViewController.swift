//
//  ViewController.swift
//  WatchListStockApp
//
//  Created by Preetham Kesineni on 3/5/21.
//

import UIKit
import SwiftyJSON
import Alamofire
import RealmSwift


protocol refreshViewController {
    func refreshActiveWatchlist()
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, refreshViewController {

    let realm = try! Realm()
    
    var ActiveWatchList: [String]?
    
    var ActiveWatchListName: String = "DEFAULT"
    var quotes: Results<Quote>?
    var timer: Timer?
    
    @IBOutlet weak var titleTextWatchList: UILabel!
    @IBOutlet var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       print("Realm is located at:", self.realm.configuration.fileURL!)

    
        
//        debugPrint(self.ActiveWatchList)

        titleTextWatchList.text = ActiveWatchListName

        let nib = UINib(nibName: "CustomTableViewCell", bundle: nil)
        
        tableView.register(nib, forCellReuseIdentifier: "CustomTableViewCell")
        
        tableView.delegate = self
        tableView.dataSource = self
   
        refreshActiveWatchlist()

        refreshData()
        
    }
    
    //proper removal hapening in deletion but not in switching?
    
    public func refreshActiveWatchlist() {
        
        
        
        let currentWatchList = self.realm.objects(WatchList.self).filter("isActive == true").first
        print(currentWatchList)
     //   debugPrint(currentWatchList)
        
        
       self.ActiveWatchList = currentWatchList?.Tickers?.components(separatedBy: ",").compactMap {String($0)}
       // self.ActiveWatchList = ["GOOG"]
       // print(self.ActiveWatchList)
        //TODO: NEED TO FIGURE OUT WAY TO RENAME THE TITLE THAT DOESNT RESULT IN NIL OPTIONAL CRASH
        
        
      
        //self.titleTextWatchList.text = self.ActiveWatchListName
        
        let data = self.realm.objects(Quote.self)
        
        try! self.realm.write {
         
            self.realm.delete(data)
        }
        
        print(self.ActiveWatchList)
        for ticker in self.ActiveWatchList!
        {
            self.getData(tickerSymbol: ticker)
            self.realm.refresh()
        }
        
        
        //TODO: TABLE VIEW SLOW TO THE REFRESH CURRENTLY THE REALM DATA IS SET BUT NEED TO FOR TIMER REFRESH CALL FOR CHANGES TO APPLY IF POSSIBLE WANT INSTANT REFRESH
    }
    
    @IBAction func addStockButton(_ sender: UIButton) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "search_vc") as? SearchViewController else { return }
        present(vc, animated: true)
    }
    
    @IBAction func manageWatchListsButton(_ sender: UIButton) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "watch_vc") as? WatchListViewController else { return }
        vc.delegate  = self
        present(vc,animated: true)
        
    }
    
 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quotes?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {

           self.ActiveWatchList?.remove(at: indexPath.row)
         //   debugPrint(self.ActiveWatchList ?? "ERROR")
            
            let data = self.realm.object(ofType: Quote.self, forPrimaryKey: self.quotes![indexPath.row].id)
     
            
            try! self.realm.write {
             
                self.realm.delete(data!)
            }
            for ticker in self.ActiveWatchList!
            {
                self.getData(tickerSymbol: ticker)
                self.realm.refresh()
            }
            
            
            self.quotes = self.realm.objects(Quote.self).sorted(byKeyPath: "id")
            
            let modifyWatchList = self.realm.objects(WatchList.self).filter("isActive == true").first
            
            

            try! self.realm.write {
                modifyWatchList?.Tickers = self.ActiveWatchList?.sorted().map {String(describing: $0) }.joined(separator: ",")
            }
            
            self.refreshActiveWatchlist()
//
//            self.timer?.invalidate()
//
//            self.refreshData()
//
            
            
            debugPrint(self.ActiveWatchList)
        //    debugPrint(self.quotes?.count)
            tableView.reloadData()
            
            
        } else if editingStyle == .insert
        {
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as! CustomTableViewCell
  

        let nameString = quotes![indexPath.row].name
        let symbolText = quotes![indexPath.row].id
        let lastPriceText = quotes![indexPath.row].lastPrice
        let askPriceText = quotes![indexPath.row].askPrice
        let bidPriceText = quotes![indexPath.row].bidPrice
        
        cell.myLabel.text = nameString + "  " + symbolText
        cell.myImageView.backgroundColor = .green
        cell.myPriceLabel.text = String(lastPriceText)
        cell.myAskPriceLabel.text = String(askPriceText)
        cell.myBidPriceLabel.text = String(bidPriceText)
        
        return cell
    }
    
    func refreshData()
    {
        
        func repeatThis(watchList:[String])
        {
           // debugPrint(watchList)
            
            for ticker in watchList
            {
                self.getData(tickerSymbol: ticker)
                self.realm.refresh()
            }
            
            self.quotes = realm.objects(Quote.self).sorted(byKeyPath: "id")
            
            self.tableView.reloadData()
        }
        
        repeatThis(watchList: self.ActiveWatchList!)

        self.timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { (timer) in
            debugPrint(self.ActiveWatchList!)
            repeatThis(watchList: self.ActiveWatchList!)
        })
    }

    func getData(tickerSymbol: String)
    {

        
        AF.request("https://sandbox.iexapis.com/stable/stock/\(tickerSymbol)/quote?token=Tpk_f4da85ac85c8471da814382d612cfdf9").responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                
                try! self.realm.write {
                 
                    self.realm.create(Quote.self,value:["id":json["symbol"].string!  , "name": json["companyName"].string! , "lastPrice": json["latestPrice"].double!, "askPrice": json["iexAskPrice"].double!, "bidPrice": json["iexBidPrice"].double!],update: .all)
                  
                    
                }

            case .failure(let error):
                print(error)
                
            }
        }
    }
    

}

class Quote: Object {
    @objc dynamic var id = ""
    @objc dynamic var name = ""
    @objc dynamic var lastPrice = 0.0
    @objc dynamic var askPrice = 0.0
    @objc dynamic var bidPrice = 0.0
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

class WatchList: Object {
    @objc dynamic var Tickers: String? = nil
    @objc dynamic var name = ""
    @objc dynamic var isActive = false
    
    
    
}

