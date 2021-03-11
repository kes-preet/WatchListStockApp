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
    func addNewTicker(ticker:String)
}


extension Double {
    var dollarString: String {
        return String(format: "$%.2f", self)
    }
}


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, refreshViewController {


    var tableRefreshTimer: Timer?
    var timer: Timer?

    let realm = try! Realm()
    var quotes: Results<Quote>?
    var watchLists: Results<WatchList>?
    
    
    var ActiveWatchList: [String]?
    var ActiveWatchListName: String = "DEFAULT"
    
    
    
    @IBOutlet weak var titleTextWatchList: UILabel!
    @IBOutlet var tableView: UITableView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Realm is located at:", self.realm.configuration.fileURL!)

        titleTextWatchList.text = ActiveWatchListName


        let nib = UINib(nibName: "CustomTableViewCell", bundle: nil)
        
        tableView.register(nib, forCellReuseIdentifier: "CustomTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
   
        refreshActiveWatchlist()
        refreshData()
        tableView.reloadData()
        
      
        runTableRefresher()
    }
    
//
//    func reloadTableCells()
//    {
//        for case let cell as CustomTableViewCell in self.tableView.visibleCells {
//
//            cell.myPriceLabel.text = String(self.quotes![index(ofAccessibilityElement: cell)].lastPrice)
//
//            cell.myAskPriceLabel.text = String(self.quotes![index(ofAccessibilityElement: cell)].askPrice)
//            cell.myBidPriceLabel.text = String(self.quotes![index(ofAccessibilityElement: cell)].bidPrice)
//
//        }
//    }
    
    //proper removal hapening in deletion but not in switching?
    
    func runTableRefresher()
    {
        
        
        self.tableRefreshTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (timer) in

            DispatchQueue.main.async {
                self.tableView.reloadData()
                //reloadTableCells()
            
            }
            
        })
    }
    
    public func addNewTicker(ticker:String) {
        
        if ((self.ActiveWatchList?.contains(ticker)) == true)
        {
            return
        }
        else {
            
            if self.ActiveWatchList?[0] == ""
            {
                self.ActiveWatchList? = [ticker]
            }
            else
            {
                self.ActiveWatchList?.append(ticker)
            }
            self.ActiveWatchList?.sort()
            
           // self.quotes = self.realm.objects(Quote.self).sorted(byKeyPath: "id")
            
            let modifyWatchList = self.realm.objects(WatchList.self).filter("isActive == true").first
            
            

            try! self.realm.write {
                modifyWatchList?.Tickers = self.ActiveWatchList?.sorted().map {String(describing: $0) }.joined(separator: ",")
            }
        }
       
    }
    
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
//        for ticker in self.ActiveWatchList!
//        {
//            self.getData(tickerSymbol: ticker)
//            self.realm.refresh()
//        }
        
        tableView.reloadData()
    }
    
    @IBAction func nextWatchList(_ sender: UIButton) {
        
        let currentIndex = self.watchLists?.index(of: self.realm.object(ofType: WatchList.self, forPrimaryKey: self.ActiveWatchListName)!)
       // print(currentIndex)
        
        let nextIdx = (currentIndex! + 1) % self.watchLists!.count
        
        let switchToList = self.watchLists?[nextIdx].name
        
     //   print(switchToList)
        
        
        DispatchQueue.main.async {
            autoreleasepool
            {
                let watchLists = self.realm.objects(WatchList.self)
                
                try! self.realm.write{
                    watchLists.setValue(false, forKey: "isActive")
                }
                
                let setNextList = self.realm.objects(WatchList.self).filter("name contains '\(switchToList!)'").first
                
                try! self.realm.write
                {
                    setNextList!.isActive = true
                }
              //  ViewController().refreshActiveWatchlist() // THis is a new instance of the view controller so data not edidted properly
                self.refreshActiveWatchlist()
            }
        
            
        }
 
        
        
    }
    
    @IBAction func prevWatchList(_ sender: UIButton) {
        let currentIndex = self.watchLists?.index(of: self.realm.object(ofType: WatchList.self, forPrimaryKey: self.ActiveWatchListName)!)
      //  print(currentIndex)
        
        var nextIdx = 0
        
        if currentIndex! - 1 < 0 {
            nextIdx = self.watchLists!.count - 1
        } else
        {
            nextIdx = abs(currentIndex! - 1) % self.watchLists!.count
        }
        
        let switchToList = self.watchLists?[nextIdx].name
        
       // print(switchToList)
        
        
        DispatchQueue.main.async {
            autoreleasepool
            {
                let watchLists = self.realm.objects(WatchList.self)
                
                try! self.realm.write{
                    watchLists.setValue(false, forKey: "isActive")
                }
                
                let setNextList = self.realm.objects(WatchList.self).filter("name contains '\(switchToList!)'").first
                
                try! self.realm.write
                {
                    setNextList!.isActive = true
                }
              //  ViewController().refreshActiveWatchlist() // THis is a new instance of the view controller so data not edidted properly
                self.refreshActiveWatchlist()
            }
        
            
        }
        
   
        
    }
    
    
    
    @IBAction func addStockButton(_ sender: UIButton) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "search_vc") as? SearchViewController else { return }
        vc.delegate = self
        present(vc, animated: true)
    }
    
    @IBAction func manageWatchListsButton(_ sender: UIButton) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "watch_vc") as? WatchListViewController else { return }
        vc.delegate  = self 
        present(vc,animated: true)
        
    }
    
 
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        self.tableRefreshTimer?.invalidate()
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        runTableRefresher()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quotes?.count ?? 0
    }
    
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
            
            
        } else if editingStyle == .insert
        {
            
        }
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        //TODO: prompt new view to open
        //TODO: transfer to that view the information in that mainly just the Symbol data

        
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "quote_vc") as? QuoteViewController else { return }
        vc.quote = self.quotes![indexPath.row]
        present(vc, animated: true, completion: nil)
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as! CustomTableViewCell
  

        let nameString = quotes![indexPath.row].name
        let symbolText = quotes![indexPath.row].id
        let lastPriceText = quotes![indexPath.row].lastPrice
        let askPriceText = quotes![indexPath.row].askPrice
        let bidPriceText = quotes![indexPath.row].bidPrice
        
        cell.myLabel.text = symbolText
        cell.myNameLabel.text = nameString
        cell.myPriceLabel.text = lastPriceText.dollarString
        
        
        if quotes![indexPath.row].lastPrice < quotes![indexPath.row].openPrice {
            cell.myImageView.backgroundColor = .red
        }
        else{
            cell.myImageView.backgroundColor = .green
        }
        
        
        if askPriceText == 0.0
        {
            cell.myAskPriceLabel.text = "N/A"
        }
        else
        {
            cell.myAskPriceLabel.text = askPriceText.dollarString
        }
        
        if bidPriceText == 0.0
        {
            cell.myBidPriceLabel.text = "N/A"
        }
        else
        {
            cell.myBidPriceLabel.text = bidPriceText.dollarString
        }
   
       
        return cell
    }
    
    func refreshData()
    {
        
        func repeatThis(watchList:[String])
        {

            self.getBatchData(tickers: watchList)
            self.realm.refresh()

            self.quotes = realm.objects(Quote.self).sorted(byKeyPath: "id")
            self.watchLists = self.realm.objects(WatchList.self).sorted(byKeyPath: "name")
        }
        
        repeatThis(watchList: self.ActiveWatchList!)

        self.timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { (timer) in
            repeatThis(watchList: self.ActiveWatchList!)
        })
    }

//    func getData(tickerSymbol: String)
//    {
//        AF.request("https://sandbox.iexapis.com/stable/stock/\(tickerSymbol)/quote?token=Tpk_f4da85ac85c8471da814382d612cfdf9",method: .get,encoding: JSONEncoding.default).responseJSON { response in
//            switch response.result {
//            case .success(let value):
//                let json = JSON(value)
//
//
//                try! self.realm.write {
//
//                    self.realm.create(Quote.self,value:[
//                                        "id":json["symbol"].string! ,
//                                        "name": json["companyName"].string!,
//                                        "lastPrice": json["latestPrice"].double!,
//                                        "askPrice": json["iexAskPrice"].double!,
//                                        "bidPrice": json["iexBidPrice"].double!
//                                        ]
//                                      ,update: .all)
//
//
//                }
//
//            case .failure(let error):
//                print(error)
//
//            }
//        }
//    }
    
    func getBatchData(tickers:[String])
    {
        let tickersJoined = tickers.sorted().map {String(describing: $0) }.joined(separator: ",")
        
        if tickersJoined == ""
        {
            return
        }
        
        AF.request("https://sandbox.iexapis.com/stable/stock/market/batch?symbols=\(tickersJoined)&types=quote&range=1m&last=5&token=Tsk_80f9ac6b9d784e00a0a5e5935bc52d5e").responseJSON { response in
            switch response.result {
            case .success(let value):
                
                
                
                let json = JSON(value)
                
               // print(json)
                
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

class WatchList: Object {
    @objc dynamic var Tickers: String? = nil
    @objc dynamic var name = ""
    @objc dynamic var isActive = false
    
    override class func primaryKey() -> String? {
        return "name"
    }
    
}

