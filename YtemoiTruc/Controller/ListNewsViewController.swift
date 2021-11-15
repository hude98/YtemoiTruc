//
//  ListNewsViewController.swift
//  ytemoiQRCode
//
//  Created by Ta Huy Hung on 29/09/2021.
//

import UIKit

protocol ListNewsDelegate{
    func goToCallDeviceVC(_ index : Int)
    func goToDetailMessageVC(_ index: Int)
    func requestSendMessageApi(_ message : String, _ index : Int)
    func requestDeleteNewsApi(_ index : Int)
    func deleteCell(_ index : Int)
    func updateArrNews(_ news : News)
    func requestChangeNewsStateApi(_ index : Int)
}


class ListNewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ListNewsDelegate {
    @IBOutlet weak var lblNameTitle: UILabel!
    @IBOutlet weak var tblNews: UITableView!
    
    private var numberOfRows = 0
    private var arrMessages = [String]()
    private var arrNews = [News]()
    var cellHeights = [IndexPath: CGFloat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        doSomethingsBeforeInit()
        requestLoadListNoteApi()
        tblNews.transform = CGAffineTransform(scaleX: 1, y: -1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    private func refreshTableView(){
        numberOfRows = 0
        arrNews.removeAll()
        self.tblNews.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if numberOfRows == 1 {
            tblNews.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if arrNews.count == 0 {
            return UITableViewCell()
        }
        let news = arrNews[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
        cell.doThingsBeforeInit()
        cell.index = indexPath.row
        cell.delegate = self
        cell.bindData(news)
        let tapped = UITapGestureRecognizer(target: cell, action: #selector(cell.handleNewsState))
        cell.lblNewsState.addGestureRecognizer(tapped)
        if numberOfRows == 1 {
            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        else{
            tblNews.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellHeights[indexPath] = cell.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath] ?? UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    private func scrollToLastestRow(){
        let lastIndexPath = (arrNews.count > 0) ? IndexPath(row: arrNews.count - 1, section: 0) : IndexPath(row: 0, section: 0)
        tblNews.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
    }
    
    func goToDetailMessageVC(_ index: Int){
        let detailMessageVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailMessageViewController") as! DetailMessageViewController
        detailMessageVC.arrMessages = arrNews[index].messages
        detailMessageVC.arrDateTimes = arrNews[index].dateTimes
        detailMessageVC.idBanTin = arrNews[index].id
        let nav = UINavigationController()
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = nav
        nav.pushViewController(detailMessageVC, animated: true)
    }
    
    func goToCallDeviceVC(_ index : Int){
        let callDeviceVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CallDeviceViewController") as! CallDeviceViewController
        callDeviceVC.patientSip = arrNews[index].sip
        callDeviceVC.patientName = arrNews[index].patientName
        let nav = UINavigationController()
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = nav
        nav.pushViewController(callDeviceVC, animated: true)
    }
    
    func deleteCell(_ index : Int) {
        numberOfRows -= 1
        arrNews.remove(at: index)
        let indexPath = IndexPath(item: index, section: 0)
        tblNews.deleteRows(at: [indexPath], with: .fade)
        tblNews.reloadData()
    }
    
    func updateArrNews(_ news : News){
        var isEqualId = false
        if arrNews.count == 0 {
            arrNews.append(news)
            numberOfRows += 1
        }
        else{
            for i in 0...arrNews.count - 1 {
                if arrNews[i].id == news.id {
                    arrNews[i] = news
                    isEqualId = true
                    break
                }
            }
            if !isEqualId {
                arrNews.append(news)
                numberOfRows += 1
            }
        }
        tblNews.reloadData()
        scrollToLastestRow()
    }
    
    func requestSendMessageApi(_ message : String, _ index : Int){
        let url = "https://ytemoi.com/api/ncb/app_truc"
        let headers = ["Content-Type" : "application/json"] as [String : String]
        let params = ["loai": Key.appGhiChep,
                      "idbantin" : arrNews[index].id ?? "",
                      "idNhanVien" : Utils.getUserInfo().id ?? "",
                      "noidung" : message] as [String : Any]
        
        Utils.sendPostRequest(urlString: url,
                              headers: headers,
                              postDictionary: params) { data, response, error in
            
            print("url : \(url)")
            
            if let _ = error {
                print("Error :", error?.localizedDescription ?? "Undefined error")
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode != 200  {
                    print("return error: %@", response)
                    return
                }
            }
            
            if data == nil {
                print("No data is found")
                return
            }
            
            print("Send message: \(message) successfully!")
        }
    }
    
    
    func requestDeleteNewsApi(_ index : Int) {
        let url = "https://ytemoi.com/api/ncb/app_truc"
        let headers = ["Content-Type" : "application/json"] as [String : String]
        let params = ["loai": Key.appKetThuc,
                      "idNhanVien" : Utils.getUserInfo().id ?? "",
                      "idbantin" : arrNews[index].id ?? ""] as [String : Any]
        
        Utils.sendPostRequest(urlString: url,
                              headers: headers,
                              postDictionary: params) { data, response, error in
            
            print("url : \(url)")
            
            if let _ = error {
                print("Error :", error?.localizedDescription ?? "Undefined error")
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode != 200  {
                    print("return error: %@", response)
                    return
                }
            }
            
            if data == nil {
                print("No data is found")
                return
            }
            
            print("Deleted news \(index) successfully!")
        }
    }
    
    
    func requestChangeNewsStateApi(_ index : Int) {
        let url = "https://ytemoi.com/api/ncb/app_truc"
        let headers = ["Content-Type" : "application/json"] as [String : String]
        let params = ["loai": Key.nhanXuLy,
                      "idbantin" : arrNews[index].id ?? "",
                      "idNhanVien" : Utils.getUserInfo().id!] as [String : Any]
        
        Utils.sendPostRequest(urlString: url,
                              headers: headers,
                              postDictionary: params) { data, response, error in
            
            print("url : \(url)")
            
            if let _ = error {
                print("Error :", error?.localizedDescription ?? "Undefined error")
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode != 200  {
                    print("return error: %@", response)
                    return
                }
            }
            
            if data == nil {
                print("No data is found")
                return
            }
            
            print("Label state changed successfully !")
        }
    }
    
    private func requestLoadListNoteApi(){
        let url = "https://ytemoi.com/api/ncb/app_truc"
        let headers = ["Content-Type" : "application/json"] as [String : String]
        let params = ["loai": Key.appDanhSachBanTin,
                      "idNhanVien" : Utils.getUserInfo().id!] as [String : Any]
        
        Utils.sendPostRequest(urlString: url,
                              headers: headers,
                              postDictionary: params) { data, response, error in
        
            print("url : \(url)")
            
            if let _ = error {
                print("Error :", error?.localizedDescription ?? "Undefined error")
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode != 200  {
                    print("return error: %@", response)
                    return
                }
            }
            
            if data == nil {
                print("No data is found")
                return
            }
            
            do {
                var jsonString = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.fragmentsAllowed) as! String
                jsonString = jsonString
                    .replacingOccurrences(of: "ObjectId(", with: "")
                    .replacingOccurrences(of: ")", with: "")
                    .replacingOccurrences(of: "ISODate(", with: "")
                let data = jsonString.data(using: .utf8)
                var json: NSDictionary? = nil
                if let data = data {
                    json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.fragmentsAllowed) as? NSDictionary
                }
                
                self.arrNews = News.getListFromJson(json?["dsbantin"] as? Array<NSDictionary> ?? Array<NSDictionary>())
                self.numberOfRows = self.arrNews.count
                
                
                DispatchQueue.main.sync {
                    self.tblNews.reloadData()
                    self.scrollToLastestRow()
                }
                
            } catch let error {
                print("Error parsing json: \(error)")
            }
        }
    }
    
    private func doSomethingsBeforeInit(){
        tblNews.delegate = self
        tblNews.dataSource = self
        lblNameTitle.text = Utils.getUserInfo().name
        refreshTableView()
        Utils.listNewsdelegate = self
    }
    
}
