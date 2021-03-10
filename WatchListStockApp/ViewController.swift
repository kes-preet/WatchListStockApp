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
    
    public func addNewTicker(ticker:String) {
        
        if ((self.ActiveWatchList?.contains(ticker)) == true)
        {
            return
        }
        else {
            self.ActiveWatchList?.append(ticker)
            
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
        
        self.getBatchData(tickers: self.ActiveWatchList!)
        self.realm.refresh()
//        for ticker in self.ActiveWatchList!
//        {
//            self.getData(tickerSymbol: ticker)
//            self.realm.refresh()
//        }
        
        
        //TODO: TABLE VIEW SLOW TO THE REFRESH CURRENTLY THE REALM DATA IS SET BUT NEED TO FOR TIMER REFRESH CALL FOR CHANGES TO APPLY IF POSSIBLE WANT INSTANT REFRESH
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
            
            self.getBatchData(tickers: self.ActiveWatchList!)
            self.realm.refresh()
//            for ticker in self.ActiveWatchList!
//            {
//                self.getData(tickerSymbol: ticker)
//                self.realm.refresh()
//            }
//
            
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
            self.tableView.reloadData()
            
            
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
        
        if askPriceText == 0.0
        {
            cell.myAskPriceLabel.text = "N/A"
        }
        else
        {
            cell.myAskPriceLabel.text = String(askPriceText)
        }
        
        if bidPriceText == 0.0
        {
            cell.myBidPriceLabel.text = "N/A"
        }
        else
        {
            cell.myBidPriceLabel.text = String(bidPriceText)
        }
   
       
        return cell
    }
    
    func refreshData()
    {
        
        func repeatThis(watchList:[String])
        {
           // debugPrint(watchList)
            debugPrint(watchList) // THE GIVE WATCH LIST IS SIZE 4 SO YOU WOULD ASSUME FOUR TICKERS GO THROUGH
//
            self.getBatchData(tickers: watchList)
            self.realm.refresh()
            //for ticker in watchList
//            {
//               // debugPrint(ticker)
//                self.getData(tickerSymbol: ticker)
//                self.realm.refresh()
//            }
            
            self.quotes = realm.objects(Quote.self).sorted(byKeyPath: "id") // QUOTES HOWEVER ENDS UP WITH 3
            
            debugPrint(self.quotes?.count)
            
            self.tableView.reloadData()
        }
        
        repeatThis(watchList: self.ActiveWatchList!)

        self.timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { (timer) in
            
           
            repeatThis(watchList: self.ActiveWatchList!)
        })
    }

    func getData(tickerSymbol: String)
    {

       // debugPrint(tickerSymbol)
        AF.request("https://sandbox.iexapis.com/stable/stock/\(tickerSymbol)/quote?token=Tpk_f4da85ac85c8471da814382d612cfdf9",method: .get,encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                
                try! self.realm.write {
                 
                    self.realm.create(Quote.self,value:["id":json["symbol"].string!  , "name": json["companyName"].string! , "lastPrice": json["latestPrice"].double!, "askPrice": json["iexAskPrice"].double!, "bidPrice": json["iexBidPrice"].double!],update: .all)
                  
                    
                }

            case .failure(let error):
                print(tickerSymbol)
                print(error)
                
            }
        }
    }
    
    func getBatchData(tickers:[String])
    {
        let tickersJoined = tickers.sorted().map {String(describing: $0) }.joined(separator: ",")
        
        if tickersJoined == ""
        {
            return
        }
        
        AF.request("https://sandbox.iexapis.com/stable/stock/market/batch?symbols=\(tickersJoined)&types=quote,news,chart&range=1m&last=5&token=Tsk_80f9ac6b9d784e00a0a5e5935bc52d5e").responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                //print(json)
                
                for ticker in tickers
                {
                    let jsonQuote = json[ticker]["quote"]
                    try! self.realm.write {
                     
                        self.realm.create(Quote.self,value:[
                                            "id":jsonQuote["symbol"].string!  ,
                                            "name": jsonQuote["companyName"].string! ,
                                            "lastPrice": jsonQuote["latestPrice"].double!,
                                            "askPrice": jsonQuote["iexAskPrice"].double ?? 0,
                                            "bidPrice": jsonQuote["iexBidPrice"].double ?? 0
                                            ],
                
                                          update: .all)
                      
                        
                    }
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
    
    override class func primaryKey() -> String? {
        return "name"
    }
    
}

