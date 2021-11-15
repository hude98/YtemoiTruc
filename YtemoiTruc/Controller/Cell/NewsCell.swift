//
//  NewsCell.swift
//  YtemoiTruc
//
//  Created by Ta Huy Hung on 09/10/2021.
//

import UIKit

class NewsCell: UITableViewCell {
    @IBOutlet weak var cstMessageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var lblPatientName: UILabel!
    @IBOutlet weak var lblPatientRoom: UILabel!
    @IBOutlet weak var lblPatientBed: UILabel!
    @IBOutlet weak var tvMessages: UITextView!
    @IBOutlet weak var tfSendMessage: UITextField!
    @IBOutlet weak var btnCallPatient: UIButton!
    @IBOutlet weak var btnMessagePatient: UIButton!
    @IBOutlet weak var btnDetailMessage: UIButton!
    @IBOutlet weak var btnStopFollowingPatient: UIButton!
    @IBOutlet weak var lblNewsState: PaddingLabel!
    
    var delegate : ListNewsDelegate?
    var index = 0
    var date = ""
    var time = ""
    
    @IBAction func callPatientPressed(_ sender: Any) {
        delegate?.goToCallDeviceVC(index)
    }
    
    @IBAction func messagePatientPressed(_ sender: Any) {
        changeMessageViewHeight(50)
    }
    
    @IBAction func onSendMessagePressed(_ sender: Any) {
        delegate?.requestSendMessageApi(tfSendMessage.text ?? "",index)
        changeMessageViewHeight(0)
        tfSendMessage.endEditing(true)
        tfSendMessage.text = ""
    }
    
    @IBAction func getDetailMessagePressed(_ sender: Any) {
        delegate?.goToDetailMessageVC(index)
    }
    
    @IBAction func stopFollowingPatientPressed(_ sender: Any) {
        delegate?.requestDeleteNewsApi(index)
        delegate?.deleteCell(index)
    }
    
    
    func bindData(_ news : News){
        var times = 3
        lblPatientName.text = news.patientName
        lblPatientRoom.text = news.room
        lblPatientBed.text = news.bed
        lblNewsState.text = showNewsState(news.newsState)
        tvMessages.text = ""
        for i in (0...news.dateTimes.count - 1).reversed() {
            if times == 0 {
                break
            }
            if times > news.dateTimes.count {
                times = news.dateTimes.count
            }
            date = getDateTime(news.dateTimes[i], "date")
            time = getDateTime(news.dateTimes[i], "time")
            tvMessages.text += "\(date) \(time) : \(news.messages[i]) \n"
            times -= 1
        }
    }
    
    func doThingsBeforeInit(){
        btnCallPatient.setTitle("", for: .normal)
        btnMessagePatient.setTitle("", for: .normal)
        btnDetailMessage.setTitle("", for: .normal)
        btnStopFollowingPatient.setTitle("", for: .normal)
        changeMessageViewHeight(0)
    }
    
    func changeMessageViewHeight(_ height : CGFloat){
        cstMessageViewHeight.constant = height
    }
    
    func getDateTime(_ dateAndTime : String,_ type : String) -> String{
        let subStrDate = dateAndTime.prefix(10)
        let date = String(subStrDate)
        
        let start = dateAndTime.index(dateAndTime.startIndex, offsetBy: 11)
        let end = dateAndTime.index(dateAndTime.startIndex, offsetBy: 15)
        let range = start...end
        let time = String(dateAndTime[range])
        
        if type == "date" {
            return date
        }
        else{
            return time
        }
    }
    
    func showNewsState(_ newsState : String) -> String{
        if newsState == "người xử lý" {
            lblNewsState.backgroundColor = Utils.getColorFrom(hex: "28A745")
            return newsState
        }
        else if newsState == "tự động xử lý"{
            lblNewsState.backgroundColor = Utils.getColorFrom(hex: "007BFF")
            return newsState
        }
        else {
            lblNewsState.backgroundColor = Utils.getColorFrom(hex: "DC3545")
            return newsState
        }
    }
    
    @objc func handleNewsState(){
        if lblNewsState.text != "người xử lý" {
            lblNewsState.backgroundColor = Utils.getColorFrom(hex: "28A745")
            lblNewsState.text = "người xử lý"
        }
        
        delegate?.requestChangeNewsStateApi(index)
    }
    
}
