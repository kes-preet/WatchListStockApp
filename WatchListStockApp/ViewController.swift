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

// Protocols functions to allow search view controller and watchlist view controller access to refresh and modify main view data
protocol refreshViewController {
    func refreshActiveWatchlist()
    func addNewTicker(ticker:String)
}

// simple extension to dollarize doubles
extension Double {
    var dollarString: String {
        return String(format: "$%.2f", self)
    }
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, refreshViewController {

    //Timers loops for data refreshing
    var tableRefreshTimer: Timer?
    var timer: Timer?

    let realm = try! Realm()
    var quotes: Results<Quote>? //Quote objects for watchlists
    var watchLists: Results<WatchList>? //Watchlist object groups
    
    var ActiveWatchList: [String]? // current active list string
    var ActiveWatchListName: String = "DEFAULT" // active list name
    
    //Outlets
    @IBOutlet weak var titleTextWatchList: UILabel!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print("Realm is located at:", self.realm.configuration.fileURL!) // - use this to find location of Realm DB if using Realm studio to investigate DB values

        titleTextWatchList.text = ActiveWatchListName //setting title text

        //custom view cell nib
        let nib = UINib(nibName: "CustomTableViewCell", bundle: nil)
        
        //table view set up
        tableView.register(nib, forCellReuseIdentifier: "CustomTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
   
        //init function runs
        refreshActiveWatchlist()
        refreshData()
        tableView.reloadData()
        runTableRefresher()
    }
    
    // table view refresh to update with new data
    func runTableRefresher(){
        self.tableRefreshTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (timer) in

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    // Adding new ticker to currently active watchlist (used in Search View Controller)
    public func addNewTicker(ticker:String) {
        
        if ((self.ActiveWatchList?.contains(ticker)) == true){
            return
        }
        else {
            
            if self.ActiveWatchList?[0] == ""{
                self.ActiveWatchList? = [ticker]
            }
            else{
                self.ActiveWatchList?.append(ticker)
            }
            self.ActiveWatchList?.sort()
        
            // Update the watchlist in the Realm DB after addition of new Ticker Symbol
            let modifyWatchList = self.realm.objects(WatchList.self).filter("isActive == true").first
            try! self.realm.write {
                modifyWatchList?.Tickers = self.ActiveWatchList?.sorted().map {String(describing: $0) }.joined(separator: ",")
            }
        }
    }
    
    // Refresh the active watchlist and update the data in  the Realm DB
    public func refreshActiveWatchlist() {
        let currentWatchList = self.realm.objects(WatchList.self).filter("isActive == true").first
       
        self.ActiveWatchList = currentWatchList?.Tickers?.components(separatedBy: ",").compactMap {String($0)}
        self.ActiveWatchListName = currentWatchList?.name ?? "Unknown"
      
        self.titleTextWatchList.text = self.ActiveWatchListName
        
        let data = self.realm.objects(Quote.self)
        
        try! self.realm.write {
         
            self.realm.delete(data)
        }

        self.getBatchData(tickers: self.ActiveWatchList!)
        self.realm.refresh()

        tableView.reloadData()
    }
    
    //IB Action buttons
    
    // Carosel buttons for navigating between watchlists
    @IBAction func nextWatchList(_ sender: UIButton) {
        
        let currentIndex = self.watchLists?.index(of: self.realm.object(ofType: WatchList.self, forPrimaryKey: self.ActiveWatchListName)!)

        let nextIdx = (currentIndex! + 1) % self.watchLists!.count
        
        let switchToList = self.watchLists?[nextIdx].name
        
        DispatchQueue.main.async {
            autoreleasepool{
                let watchLists = self.realm.objects(WatchList.self)
                
                try! self.realm.write{
                    watchLists.setValue(false, forKey: "isActive")
                }
                
                let setNextList = self.realm.objects(WatchList.self).filter("name contains '\(switchToList!)'").first
                
                try! self.realm.write{
                    setNextList!.isActive = true
                }
                self.refreshActiveWatchlist()
            }
        }
    }
    
    @IBAction func prevWatchList(_ sender: UIButton) {
        let currentIndex = self.watchLists?.index(of: self.realm.object(ofType: WatchList.self, forPrimaryKey: self.ActiveWatchListName)!)
        
        var nextIdx = 0
        
        if currentIndex! - 1 < 0 {
            nextIdx = self.watchLists!.count - 1
        } else{
            nextIdx = abs(currentIndex! - 1) % self.watchLists!.count
        }
        
        let switchToList = self.watchLists?[nextIdx].name
        
        DispatchQueue.main.async {
            autoreleasepool{
                let watchLists = self.realm.objects(WatchList.self)
                
                try! self.realm.write{
                    watchLists.setValue(false, forKey: "isActive")
                }
                
                let setNextList = self.realm.objects(WatchList.self).filter("name contains '\(switchToList!)'").first
                
                try! self.realm.write{
                    setNextList!.isActive = true
                }
                self.refreshActiveWatchlist()
            }
        }
    }
    
    // Present Adding stock Search View
    @IBAction func addStockButton(_ sender: UIButton) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "search_vc") as? SearchViewController else { return }
        vc.delegate = self
        present(vc, animated: true)
    }
    
    // Present Manage Watchlist Views
    @IBAction func manageWatchListsButton(_ sender: UIButton) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "watch_vc") as? WatchListViewController else { return }
        vc.delegate  = self 
        present(vc,animated: true)
    }
    
    // Table View Functions
    
    //When swipe to delete stop refresh timer to ensure no issue while deleting
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        self.tableRefreshTimer?.invalidate()
    }
    
    // resume timer when closing editing option of table view cell
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        runTableRefresher()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quotes?.count ?? 0
    }
    
    //Delete table view cell from active watchlist as well as update Realm DB to reflect Change
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {

            self.ActiveWatchList?.remove(at: indexPath.row)
            
            let data = self.realm.object(ofType: Quote.self, forPrimaryKey: self.quotes![indexPath.row].id)
     
            try! self.realm.write {
                self.realm.delete(data!)
            }
            
            self.getBatchData(tickers: self.ActiveWatchList!)
            self.realm.refresh()
            
            self.quotes = self.realm.objects(Quote.self).sorted(byKeyPath: "id")
            
            let modifyWatchList = self.realm.objects(WatchList.self).filter("isActive == true").first

            try! self.realm.write {
                modifyWatchList?.Tickers = self.ActiveWatchList?.sorted().map {String(describing: $0) }.joined(separator: ",")
            }
            
            self.refreshActiveWatchlist()
            self.tableView.reloadData()
            
        }
    }
    
    //Click Quote to open Quote View Controller
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "quote_vc") as? QuoteViewController else { return }
        vc.quote = self.quotes![indexPath.row]
        present(vc, animated: true, completion: nil)
    }
    
    
    //Present values from DB to custom view cells of table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as! CustomTableViewCell
  
        //default values to apply
        let nameString = quotes![indexPath.row].name
        let symbolText = quotes![indexPath.row].id
        let lastPriceText = quotes![indexPath.row].lastPrice
        let askPriceText = quotes![indexPath.row].askPrice
        let bidPriceText = quotes![indexPath.row].bidPrice
        
        cell.myLabel.text = symbolText
        cell.myNameLabel.text = nameString
        cell.myPriceLabel.text = lastPriceText.dollarString
        
        //if quote value is lower than open value of tday set to red else if higher set to green
        if quotes![indexPath.row].lastPrice < quotes![indexPath.row].openPrice {
            cell.myImageView.backgroundColor = .red
        }
        else{
            cell.myImageView.backgroundColor = .green
        }
        
        // if there is ask or bid price availible set it otherwise simply set to N/A if value is 0.0
        if askPriceText == 0.0{
            cell.myAskPriceLabel.text = "N/A"
        }
        else{
            cell.myAskPriceLabel.text = askPriceText.dollarString
        }
        
        if bidPriceText == 0.0{
            cell.myBidPriceLabel.text = "N/A"
        }
        else{
            cell.myBidPriceLabel.text = bidPriceText.dollarString
        }
       
        return cell
    }
    
    // Reload the data function
    func refreshData(){
        
        //repeatitive data refresh
        func repeatThis(watchList:[String]){
            self.getBatchData(tickers: watchList)
            self.realm.refresh()

            self.quotes = realm.objects(Quote.self).sorted(byKeyPath: "id")
            self.watchLists = self.realm.objects(WatchList.self).sorted(byKeyPath: "name")
        }
    
        repeatThis(watchList: self.ActiveWatchList!)

        //refresh the data every 5 seconds
        self.timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { (timer) in
            repeatThis(watchList: self.ActiveWatchList!)
        })
    }
    
    // JSON call to retrive batch data from iex Cloud API
    func getBatchData(tickers:[String])
    {
        let tickersJoined = tickers.sorted().map {String(describing: $0) }.joined(separator: ",")
        
        if tickersJoined == ""{
            return
        }
        
        AF.request("https://sandbox.iexapis.com/stable/stock/market/batch?symbols=\(tickersJoined)&types=quote&range=1m&last=5&token=Tsk_80f9ac6b9d784e00a0a5e5935bc52d5e").responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                for ticker in tickers
                {
                    let jsonQuote = json[ticker]["quote"]
                    try! self.realm.write {
                        self.realm.create(Quote.self,value:[
                                            "id":jsonQuote["symbol"].string ?? "Unknown: JSON Err"  ,
                                            "name": jsonQuote["companyName"].string! ,
                                            "lastPrice": jsonQuote["latestPrice"].double!,
                                            "askPrice": jsonQuote["iexAskPrice"].double ?? 0.0,
                                            "bidPrice": jsonQuote["iexBidPrice"].double ?? 0.0,
                                            "openPrice": jsonQuote["iexOpen"].double ?? 0.0,
                                            ],
                                          update: .all)
                    }
                }
                
            case .failure(let error):
                print(error)
                print("HERE")
            }
        }
        tableView.reloadData()
    }
    
}

//Quote Object Class
class Quote: Object {
    @objc dynamic var id = ""
    @objc dynamic var name = ""
    @objc dynamic var lastPrice = 0.0
    @objc dynamic var askPrice = 0.0
    @objc dynamic var bidPrice = 0.0
    @objc dynamic var openPrice = 0.0
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

//Watchlist Object Class
class WatchList: Object {
    @objc dynamic var Tickers: String? = nil
    @objc dynamic var name = ""
    @objc dynamic var isActive = false
    
    override class func primaryKey() -> String? {
        return "name"
    }
}

