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
   
    //delegate for protocol functions of View Controller
    var delegate: refreshViewController?
    
    //Outlets
    @IBOutlet weak var SearchBar: UITextField!
    @IBOutlet weak var SymbolList: UITableView!
    
    //Autocomplete search Symbol group
    var subSectionSymbolGroup: [String] = Array()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //SymbolList TableView
        SymbolList.delegate = self
        SymbolList.dataSource = self
        
        //Search Bar Text Field
        SearchBar.delegate = self
        SearchBar.addTarget(self, action: #selector(searchRecords(_ :)), for: .editingChanged)
    }
    
    //Return func
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        SearchBar.resignFirstResponder()
        return true
    }
    
    //Dynamic autocomplete search view using iexCloud search JSON
    @objc func searchRecords(_ textField: UITextField) {
        self.subSectionSymbolGroup.removeAll() //reset current subsection of selected quote symbols
        
        // if textfield not empty
        if textField.text?.count != 0 {
            
                if let stubToSearch = textField.text {
                    //Alamofire request for search of given symbol stub
                    AF.request("https://sandbox.iexapis.com/stable//search/\(stubToSearch)?token=Tpk_f4da85ac85c8471da814382d612cfdf9").responseJSON {
                        response in switch response.result {
                        case .success(let value):
                            let json = JSON(value)

                            // if found append JSON values to subSectionSymbolGroup
                            DispatchQueue.main.async {
                                for ticker in json.arrayValue{
                                    self.subSectionSymbolGroup.append(ticker["symbol"].string!)
                                }
                                
                                self.SymbolList.reloadData() // refresh data
                            }
     
                        case .failure(let error):
                            print(error)
                            
                            
                        }
        
                    
                    }

                }

         
        }
        else {
            // otherwise reset to empty
            self.subSectionSymbolGroup.removeAll()
            self.SymbolList.reloadData()
        }
        

       
    }
    
    //Table view Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subSectionSymbolGroup.count
    }
    
    //Cell set up applying subSectionSymbolGroup values to each section
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "ticker")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "ticker")
            
        }
        cell?.textLabel?.text = subSectionSymbolGroup[indexPath.row]
        return cell!
    }
    
    // on selection of a section invoke new ticker and refresh watchlist protocol functions and dimiss current view
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        self.delegate?.addNewTicker(ticker: subSectionSymbolGroup[indexPath.row])
        self.delegate?.refreshActiveWatchlist()
        
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}
