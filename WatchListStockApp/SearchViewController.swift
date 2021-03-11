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
    
    
    var subSectionSymbolGroup: [String] = Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
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

                if let stubToSearch = textField.text {

                    
                    AF.request("https://sandbox.iexapis.com/stable//search/\(stubToSearch)?token=Tpk_f4da85ac85c8471da814382d612cfdf9").responseJSON {
                        response in switch response.result {
                        case .success(let value):
                            let json = JSON(value)

                            
                            DispatchQueue.main.async {
                                for ticker in json.arrayValue{
                                    //debugPrint(ticker["symbol"].string!)
                                    self.subSectionSymbolGroup.append(ticker["symbol"].string!)
                                }
                                
                                self.SymbolList.reloadData()
                            }
                            
        
                            
                        case .failure(let error):
                            print(error)
                            
                            
                        }
        
                    
                    }

                }

         
        }
        else {
            self.subSectionSymbolGroup.removeAll()
            self.SymbolList.reloadData()
        }
        

       
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

       
        self.delegate?.addNewTicker(ticker: subSectionSymbolGroup[indexPath.row])
        self.delegate?.refreshActiveWatchlist()
        
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}
