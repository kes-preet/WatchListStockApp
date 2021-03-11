//
//  QuoteViewController.swift
//  WatchListStockApp
//
//  Created by Preetham Kesineni on 3/10/21.
//

import UIKit
import SwiftyJSON
import Alamofire
import RealmSwift
import Charts


class QuoteViewController: UIViewController ,ChartViewDelegate {

    @IBOutlet weak var stockySymbolLabel: UILabel!
    @IBOutlet weak var stockNameLabel: UILabel!
    @IBOutlet weak var stockPriceLabel: UILabel!
    
    @IBOutlet weak var stockBidLabel: UILabel!
    @IBOutlet weak var stockAskLabel: UILabel!
    
    var lineChart = LineChartView()
    
    
    var quote: Quote?
    let realm = try! Realm()
    
    //Complete: implement the updating from the view controller
    
    //COmplete: get iex api chart information
    //COMPLETE: take that chart information grab the date,
    //COMPLETE: calculate average price (open + close)/2
    //COMPLETE: take these and store them in some sort of array with values for each day
        // - will need some adjustment and filler
    //TODO: use chart library to create the chart for it
    
    var chartDataDictionary: [String: Double] = [:]
    var developedChartDataDict: [Date:Double] = [:]
 
    
    
    var timer:Timer?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        

        self.stockySymbolLabel.text = quote?.id
        
        if quote!.bidPrice == 0.0 {
            self.stockBidLabel.text = "N/A"
        } else {
            self.stockBidLabel.text = String(quote!.bidPrice)
        }
        
        if quote!.askPrice == 0.0 {
            self.stockAskLabel.text = "N/A"
        } else {
            self.stockAskLabel.text = String(quote!.askPrice)
        }
        
        self.stockNameLabel.text = quote?.name
        self.stockPriceLabel.text = String(quote!.lastPrice)
        
        self.getLastMonthDates()
        self.getData(tickerSymbol: quote!.id)
       // self.prepLibraryForDateSorting()
      
        
        lineChart.delegate = self
      
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { (timer) in
            self.updatePriceLabels()
            //print("ticking")
           // self.lineChart.notifyDataSetChanged()
           // print(self.developedChartDataDict)
            
        })

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        lineChart.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.width)
        lineChart.center = view.center
        view.addSubview(lineChart)
        lineChart.xAxis.enabled = false

        var dateArray = [String]()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3){
       
        
            var entries = [ChartDataEntry]()
        
        
       // print(self.chartDataDictionary)
      
            var today = Date()
         
            for x in 0...29{
                let tomorrow = Calendar.current.date(byAdding: .day,value: -1, to: today)
                let date = DateFormatter()
                date.dateFormat = "yyyy-MM-dd"
                let stringDate: String = date.string(from: today)
                today = tomorrow!
                dateArray.append(stringDate)
               
                
            }
            //print(entries)
            dateArray = dateArray.reversed()
            
            for x in 0...29 {
                if self.chartDataDictionary[dateArray[x]] != 0.0 {
                    entries.append(ChartDataEntry(x: Double(x), y: Double(self.chartDataDictionary[dateArray[x]]!)))
                }
            }
          
        
            let set = LineChartDataSet(entries:entries)
            set.colors = ChartColorTemplates.material()
        
            let data = LineChartData(dataSet: set)
            self.lineChart.data = data
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.timer?.invalidate()
       // print("Stopped the clock")
        
    }
    
    func prepLibraryForDateSorting()
    {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for (date,_) in self.chartDataDictionary {
            
            let convertedDate = dateFormatter.date(from: date)
           
            self.developedChartDataDict[convertedDate!] = self.chartDataDictionary[date]
            
        }
        
        let sortedKeys = Array(self.developedChartDataDict.keys).sorted(by: { $0.compare($1) == .orderedDescending })

        
       // debugPrint(self.chartDataDictionary)
        //debugPrint(self.developedChartDataDict)
       // debugPrint("HELLO")
        
    }
    
    func getLastMonthDates()
    {
        var today = Date()
        var dateArray = [String]()
        for _ in 1...30{
            let tomorrow = Calendar.current.date(byAdding: .day,value: -1, to: today)
            let date = DateFormatter()
            date.dateFormat = "yyyy-MM-dd"
            let stringDate: String = date.string(from: today)
            today = tomorrow!
            dateArray.append(stringDate)
            self.chartDataDictionary[stringDate] = 0.0
        }
       // print(dateArray)
    }
    
    
    func updatePriceLabels()
    {
        
        if quote!.bidPrice == 0.0 {
            self.stockBidLabel.text = "N/A"
        } else {
            self.stockBidLabel.text = String(quote!.bidPrice)
        }
        
        if quote!.askPrice == 0.0 {
            self.stockAskLabel.text = "N/A"
        } else {
            self.stockAskLabel.text = String(quote!.askPrice)
        }
        
        self.stockPriceLabel.text = String(quote!.lastPrice)
        
    }
    
     
    
    func getData(tickerSymbol: String)
    {
        AF.request("https://sandbox.iexapis.com/stable/stock/\(tickerSymbol)/chart?token=Tpk_f4da85ac85c8471da814382d612cfdf9",method: .get,encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
               // print(json)

                
                for (_,subJson):(String,JSON) in json {
//
//                    print(subJson["date"])
//                    print(subJson["close"])
//                    print(subJson["open"])
                    
                    let closeDouble = subJson["close"].double
                    let openDouble = subJson["open"].double
                    
                    let averageHistorical = (openDouble! + closeDouble!)/2
                    
                    //print(" avg historical: " + String(averageHistorical))
                    // hash the date with the average value
                    
                    self.chartDataDictionary[subJson["date"].string!] = averageHistorical
                    
                }
            
              // print(self.chartDataDictionary)
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

            case .failure(let error):
                print(error)

            }
        }
    }


}