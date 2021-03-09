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

//Current Issues:

// - need to figure out a way to prevent repeated entries into my realm DB
// - need to find a clean way to display these entries onto my app
// What I need to do tommorow:

//  - Handle the issue with repeated entries
//  - Display a predetermined  list of tickers

// - Future needs
// - ensure tickers updated on 5 minute basis
// - ensure that data is handled locally until update time at which updates if can access new date otherwise retain current data



class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let realm = try! Realm()
    var Tickers = ["AAPL","AMZN","GOOG"].sorted()
    var quotes: Results<Quote>?
    var timer: Timer?
    
    
    @IBOutlet var tableView: UITableView!
    let myData = ["First","second","third","fourth"]
    
    
    let myListName = "myListName"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let nib = UINib(nibName: "CustomTableViewCell", bundle: nil)
        
        tableView.register(nib, forCellReuseIdentifier: "CustomTableViewCell")
        
        tableView.delegate = self
        tableView.dataSource = self
   

        refreshData()
        
        
//        for ticker in Tickers
//        {
//            getData(tickerSymbol: ticker)
//            realm.refresh()
//        }
        
//        quotes = realm.objects(Quote.self).sorted(byKeyPath: "id")
//
//        tableView.reloadData()
 
        
        
    }
    
    @IBAction func addStockButton(_ sender: UIButton) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "search_vc") as? SearchViewController else { return }
        present(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quotes!.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            
        
//
//            try! self.realm.write {
//                self.realm.delete(self.realm.objects(Quote.self).filter(quotes![indexPath.row].id))
//                self.realm.refresh()
//            }
//
              Tickers.remove(at: indexPath.row)
//
              debugPrint(Tickers)
//
            
            let data = self.realm.object(ofType: Quote.self, forPrimaryKey: self.quotes![indexPath.row].id)
            
            try! self.realm.write {
             
                self.realm.delete(data!)
            }
            for ticker in Tickers
            {
                self.getData(tickerSymbol: ticker)
                self.realm.refresh()
            }
            
            
            self.quotes = self.realm.objects(Quote.self).sorted(byKeyPath: "id")
            
            debugPrint(self.quotes?.count)
            
            //tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
            
            
        } else if editingStyle == .insert
        {
            //todo
        }
    } // TODO: delete button is there but the functionaility is missing
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as! CustomTableViewCell
        //let string = quotes![indexPath.row].name + "     " + quotes![indexPath.row].id +  "        " + String(quotes![indexPath.row].lastPrice)

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
        func repeatThis()
        {
            for ticker in self.Tickers
            {
                self.getData(tickerSymbol: ticker)
                self.realm.refresh()
            }
            
            self.quotes = realm.objects(Quote.self).sorted(byKeyPath: "id")
            
            self.tableView.reloadData()
        }
        
        repeatThis()

        self.timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { (timer) in
            repeatThis()
        })
    }

    func getData(tickerSymbol: String)
    {

        
        AF.request("https://sandbox.iexapis.com/stable/stock/\(tickerSymbol)/quote?token=Tpk_f4da85ac85c8471da814382d612cfdf9").responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                //debugPrint(json)
                
                if let companyName = json["companyName"].string {
                  //  debugPrint(companyName)
                } else { return }
                
                if let latestPrice = json["latestPrice"].string {
                    //debugPrint(latestPrice)
                } else {  }
                
                if let askPrice = json["iexAskPrice"].string {
                    //debugPrint(askPrice)
                } else { }
                
                if let bidPrice = json["iexBidPrice"].string {
                    //debugPrint(bidPrice)
                } else { }
                
                // ISSUE: bid and ask price are generally null values so need to make a catch to set it as 0 if == to null or a value
 
             
                
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
    
    //need to Program
    //bid
    //ask
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

