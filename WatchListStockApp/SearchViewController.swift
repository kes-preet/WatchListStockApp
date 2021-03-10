//
//  SearchViewController.swift
//  WatchListStockApp
//
//  Created by Preetham Kesineni on 3/8/21.
//

import UIKit
import Alamofire
import SwiftyJSON


class SearchViewController: UIViewController , UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate{
    var delegate: refreshViewController?
    
    @IBOutlet weak var SearchBar: UITextField!
    @IBOutlet weak var SymbolList: UITableView!
    
//    var sampleSubSection: [String] = Array()
//    var fullSample: [String] = Array()
    
    
    var subSectionSymbolGroup: [String] = Array()
    var prevSubSectionSymbolGroup: [String] = Array() // may not need this
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//
//        sampleSubSection.append("AARP")
//        sampleSubSection.append("XEP")
//        sampleSubSection.append("AWP")
//        sampleSubSection.append("XXT")
//        sampleSubSection.append("AYXE")
//        sampleSubSection.append("AEET")
//        sampleSubSection.append("AEE")
//        sampleSubSection.append("AEEV")
//
//        for stub in sampleSubSection {
//            fullSample.append(stub)
//        }
        
        SymbolList.delegate = self
        SymbolList.dataSource = self
        
        SearchBar.delegate = self
        SearchBar.addTarget(self, action: #selector(searchRecords(_ :)), for: .editingChanged)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        SearchBar.resignFirstResponder()
        return true
    }
    
    @objc func searchRecords(_ textField: UITextField) {
        self.subSectionSymbolGroup.removeAll()
        
        
        
        if textField.text?.count != 0 {
           // for stub in fullSample {
                if let stubToSearch = textField.text {
//                    let range = stub.lowercased().range(of: stubToSearch, options: .caseInsensitive, range: nil,locale: nil)
                    
                  //  let range = stub.hasPrefix(stubToSearch.uppercased())
                    
                    AF.request("https://sandbox.iexapis.com/stable//search/\(stubToSearch)?token=Tpk_f4da85ac85c8471da814382d612cfdf9").responseJSON {
                        response in switch response.result {
                        case .success(let value):
                            let json = JSON(value)
                            
                            
                           // debugPrint(json)
                            
                          //  debugPrint(json.array)
                            
                            
                            
                            DispatchQueue.main.async {
                                for ticker in json.arrayValue{
                                    //debugPrint(ticker["symbol"].string!)
                                    self.subSectionSymbolGroup.append(ticker["symbol"].string!)
                                }
                                
                                self.SymbolList.reloadData()
                            }
                            
                            
                          
//
//
//                            //self.prevSubSectionSymbolGroup = self.subSectionSymbolGroup
//                            debugPrint("One: ")
//                            debugPrint(self.subSectionSymbolGroup)
                            
                        case .failure(let error):
                            print(error)
                            
                            
                        }
                    
                   // debugPrint("Two: ")
                    //debugPrint(self.subSectionSymbolGroup)
                    
                    }
                    //debugPrint("Three: ")
                    //debugPrint(self.subSectionSymbolGroup)
                    
                    
                    //https://sandbox.iexapis.com/stable//search/tsl?token=Tpk_f4da85ac85c8471da814382d612cfdf9
//
//                    if range  {
//                        self.sampleSubSection.append(stub)
//                    }
                    
                }
            //}
//            debugPrint(sampleSubSection)
         
        }
        else {
            self.subSectionSymbolGroup.removeAll()
            self.SymbolList.reloadData()
        }
        
//        debugPrint("This Code has RUNNED")
//
//        debugPrint(textField.text?.count)
//        debugPrint("Four: ")
//        debugPrint(self.subSectionSymbolGroup)
       
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subSectionSymbolGroup.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "ticker")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "ticker")
            
        }
        cell?.textLabel?.text = subSectionSymbolGroup[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        debugPrint(subSectionSymbolGroup[indexPath.row])
        
        self.delegate?.addNewTicker(ticker: subSectionSymbolGroup[indexPath.row])
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}
