//
//  DetailMessageViewController.swift
//  ytemoi_app_yta
//
//  Created by HienNguyen on 5/9/21.
//

import UIKit

protocol DetailMessageDelegate{
    func updateMessage(_ news : News)
}

class DetailMessageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,DetailMessageDelegate {
    
    func updateMessage(_ news : News) {
        arrMessages = news.messages
        arrDateTimes = news.dateTimes
        numberOfRows = news.messages.count
        tblChat.reloadData()
        onKeyboardDidShow()
    }
    
    @IBOutlet weak var tblChat: UITableView!
    @IBOutlet weak var edtTextMessage: UITextField!
    @IBOutlet weak var cstMesssageViewBottom: NSLayoutConstraint!
    @IBOutlet weak var cstMessageHeight: NSLayoutConstraint!
    
    var arrMessages = [String]()
    var arrDateTimes = [String]()
    var idBanTin = ""
    private var numberOfRows = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblChat.delegate = self
        tblChat.dataSource = self
        numberOfRows = arrMessages.count
        self.navigationController?.isNavigationBarHidden = false
        Utils.detailMessdelegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerKeyboardView()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterKeyboardView()
    }
    
    
    private func refreshTableView(){
        numberOfRows = 0
        arrMessages.removeAll()
        self.tblChat.reloadData()
    }
    
    
    //MARK: - Table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeTextCell", for: indexPath) as! MeTextCell
        let message = arrMessages[indexPath.row]
        let datetime = arrDateTimes[indexPath.row]
        cell.bindData(message,datetime)
        return cell
    }
    
    
    @IBAction func getTableViewTapped(_ sender: Any) {
        endEdittingTextField()
    }
    
    @IBAction func onSendButtonClicked(_ sender: Any) {
        requestSendMessageApi()
        endEdittingTextField()
    }
    
    @IBAction func onPopViewControllerPressed(_ sender: Any) {
        let listNewsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ListNewsViewController") as! ListNewsViewController
        let nav = UINavigationController()
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = nav
        nav.pushViewController(listNewsVC, animated: true)
    }
    
    func requestSendMessageApi(){
        let url = "https://ytemoi.com/api/ncb/app_truc"
        let headers = ["Content-Type" : "application/json"] as [String : String]
        let params = ["loai": Key.appGhiChep,
                      "idbantin" : idBanTin,
                      "idNhanVien" : Utils.getUserInfo().id ?? "",
                      "noidung" : edtTextMessage.text ?? ""] as [String : Any]
        
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
            
            DispatchQueue.main.async {
                print("Send message: \(self.edtTextMessage.text ?? "") successfully!")
            }
            
        }
    }
    
    private func endEdittingTextField(){
        edtTextMessage.endEditing(true)
        edtTextMessage.text = ""
    }
    
}


//MARK: - Keyboard notifications
extension DetailMessageViewController{
    func unregisterKeyboardView() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    func registerKeyboardView() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        handleWhenKeyboardChanged(false, notification: notification)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        handleWhenKeyboardChanged(true, notification: notification)
    }
    
    @objc func keyboardDidShow(_ notification:Notification) {
        print("keyboardDidShow")
        self.onKeyboardDidShow()
    }
    
    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        handleWhenKeyboardChanged(false, notification: notification)
    }
    
    private func handleWhenKeyboardChanged(_ show : Bool, notification:Notification) {
        let userInfo = (notification as NSNotification).userInfo!
        let keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let animationDurarion = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
//        let heightTabbar = self.tabBarController != nil ? self.tabBarController?.tabBar.frame.size.height : 0
//        let heightTabbar = Utils.getCstTabBarHeight()
        let heightTabbar = 0
        
        self.onKeyboardViewChanged(show,
                                   Float(heightTabbar),
                                   Float(keyboardFrame.size.height),
                                   animationDurarion)
    }
    
    
    private func onKeyboardDidShow() {
        let lastIndexPath = (arrMessages.count > 0) ? IndexPath(row: arrMessages.count - 1, section: 0) : IndexPath(row: 0, section: 0)
        tblChat.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
    }
    
    
    private func onKeyboardViewChanged(_ show : Bool,
                                       _ heightTabbar : Float,
                                       _  heightKeyboard : Float,
                                       _ animationTime : Double) {
        let changeInHeight = (heightKeyboard - heightTabbar) * (show ? 1 : 0)
        self.cstMesssageViewBottom?.constant = CGFloat(changeInHeight)
        UIView.animate(withDuration: animationTime, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
}
