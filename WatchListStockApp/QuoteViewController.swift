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

    //IB Outlets
    @IBOutlet weak var stockySymbolLabel: UILabel!
    @IBOutlet weak var stockNameLabel: UILabel!
    @IBOutlet weak var stockPriceLabel: UILabel!
    @IBOutlet weak var stockBidLabel: UILabel!
    @IBOutlet weak var stockAskLabel: UILabel!
    
    var lineChart = LineChartView()
    var quote: Quote?
    let realm = try! Realm()

    var chartDataDictionary: [String: Double] = [:]
    var timer:Timer?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Symbol label
        self.stockySymbolLabel.text = quote?.id
        
        //Bid and ask if 0.0 just set to N/A
        if quote!.bidPrice == 0.0 {
            self.stockBidLabel.text = "N/A"
        } else {
            self.stockBidLabel.text =  quote!.bidPrice.dollarString
        }
        if quote!.askPrice == 0.0 {
            self.stockAskLabel.text = "N/A"
        } else {
            self.stockAskLabel.text =  quote!.askPrice.dollarString
        }
        
        //Name
        self.stockNameLabel.text = quote?.name
        
        //latest Price
        self.stockPriceLabel.text =  quote!.lastPrice.dollarString
        
        // Preparing the chart Data
        self.getLastMonthDates()
        self.getData(tickerSymbol: quote!.id)
      
        
        lineChart.delegate = self
      
        // Refresh timer to obtain new data every 5 seconds
        self.timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { (timer) in
            self.updatePriceLabels()
            
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Prepping Line Chart
        lineChart.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width - 20, height: self.view.frame.size.width - 20)
        lineChart.extraTopOffset = 150
        lineChart.legend.enabled = false
        lineChart.xAxis.enabled = false
        lineChart.isUserInteractionEnabled = false
        
        view.addSubview(lineChart)
        
        var dateArray = [String]()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8){
       
        
            var entries = [ChartDataEntry]()
            var today = Date()
         
            // Get the dates from the last 30 days
            for _ in 0...29{
                let tomorrow = Calendar.current.date(byAdding: .day,value: -1, to: today)
                let date = DateFormatter()
                date.dateFormat = "yyyy-MM-dd"
                let stringDate: String = date.string(from: today)
                today = tomorrow!
                dateArray.append(stringDate)
               
                
            }
            dateArray = dateArray.reversed() // Reveresal needed to properly retrive data from chart Data Dictionary
            
            // append entries with sorted chart data dictionary
            for x in 0...29 {
                // if value not defined in chart data ignore and skip since is missing data from JSON
                if self.chartDataDictionary[dateArray[x]] != 0.0 {
                    entries.append(ChartDataEntry(x: Double(x), y: Double(self.chartDataDictionary[dateArray[x]]!)))
                }
            }

            //defining data set values
            let set = LineChartDataSet(entries:entries)
            set.setColor(.green)
            set.circleRadius = 0
            set.lineWidth = 5.0
            
            // add data to line chart object
            let data = LineChartData(dataSet: set)
            self.lineChart.data = data
        }
    }
    
    // End timer if view dismissed
    override func viewDidDisappear(_ animated: Bool) {
        self.timer?.invalidate()

    }

    // Retrieve the string value of last 30 days storing in chart by default as 0.0
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
 
    }
    
    // Updating price label values
    func updatePriceLabels()
    {
        
        if quote!.bidPrice == 0.0 {
            self.stockBidLabel.text = "N/A"
        } else {
            self.stockBidLabel.text = quote!.bidPrice.dollarString
        }
        
        if quote!.askPrice == 0.0 {
            self.stockAskLabel.text = "N/A"
        } else {
            self.stockAskLabel.text = quote!.askPrice.dollarString
        }
        
        self.stockPriceLabel.text = quote!.lastPrice.dollarString
        
    }
    
     
    // Retrieve the chart data from iex Cloud API
    func getData(tickerSymbol: String)
    {
        AF.request("https://sandbox.iexapis.com/stable/stock/\(tickerSymbol)/chart?token=Tpk_f4da85ac85c8471da814382d612cfdf9",method: .get,encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)


                // For each availible quote historical data
                for (_,subJson):(String,JSON) in json {

                    
                    let closeDouble = subJson["close"].double
                    let openDouble = subJson["open"].double
                    
                    let averageHistorical = (openDouble! + closeDouble!)/2 // average price data from open and close of that day
                    
                    self.chartDataDictionary[subJson["date"].string!] = averageHistorical // set average with key of specific date from JSON
                    
                }
            
  

            case .failure(let error):
                print(error)

            }
        }
    }


}
