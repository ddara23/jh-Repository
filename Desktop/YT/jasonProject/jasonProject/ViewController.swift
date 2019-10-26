//
//  ViewController.swift
//  jasonProject
//
//  Created by Jh on 19/08/2019.
//  Copyright © 2019 jh. All rights reserved.
//

import UIKit
import SafariServices

class ViewController: UIViewController,UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,SFSafariViewControllerDelegate {
    
    @IBOutlet weak var searchText: UISearchBar!
     @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchText.delegate = self
        searchText.placeholder = "과자이름을 입력하세요"
        tableView.dataSource = self
        tableView.delegate = self
        
    }

    var snackList : [(name:String, maker : String, link: URL, image:URL)] = []

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        
        if let searchWord = searchText.text{
            
            print(searchWord)
            searchSnack(keyword: searchWord)
        }
    }
    
    func searchSnack(keyword: String){
        guard let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else{
            return
        }
        guard  let req_url = URL(string : "http://www.sysbird.jp/toriko/api/?apikey=guest&format=json&keyword=\(keyword_encode)&max=10&order=r") else {
            return
        }
        print(req_url)
        
        let req = URLRequest(url: req_url)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: req, completionHandler: {(data, responds, Error) in
        session.finishTasksAndInvalidate()
            do{
            let decoder = JSONDecoder()
                let json = try decoder.decode(ResultJson.self, from: data!)
            //print(json)
                
                if let items = json.item{
                    self.snackList.removeAll()
                    for item in items{
                        if let name = item.name, let maker = item.maker, let link = item.url, let image = item.image{
                            let snack = (name, maker, link, image)
                            self.snackList.append(snack)
                        }
                    }
                    self.tableView.reloadData()
                    if let snackdbg = self.snackList.first{
                        print("-------------------------")
                        print("snackList[0]= \(snackdbg)")
                    }
                }
            }catch{
            print("error")
            }
            })

        task.resume()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return snackList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "snackCell", for: indexPath)
        cell.textLabel?.text = snackList[indexPath.row].name
        if let imageData = try? Data(contentsOf: snackList[indexPath.row].image){
            cell.imageView?.image = UIImage(data: imageData)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        let safariViewController = SFSafariViewController(url: snackList[indexPath.row].link)
        safariViewController.delegate = self
        
        present(safariViewController, animated: true, completion: nil)
        
    }
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true, completion: nil)
    }
        struct ItemJson: Codable {
        let name : String?
        let maker : String?
        let url : URL?
        let image : URL?
        
    }
    struct ResultJson:Codable {
        let item: [ItemJson]?
    }
    
}

