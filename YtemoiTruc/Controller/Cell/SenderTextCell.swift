//
//  SenderTextCell.swift
//  ytemoi_app_yta
//
//  Created by Ta Huy Hung on 16/06/2021.
//

import UIKit

class SenderTextCell: UITableViewCell {
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblSenderName: UILabel!
    @IBOutlet weak var tvMessage: UITextView!
    @IBOutlet weak var lblTime: UILabel!
//
//
//    func bindData(_ message : String, _ datetime : String){
//        lblDate.text = getDateTime(datetime, "date")
//        lblSenderName.text = "Thông báo"
//        tvMessage.text = message
//        lblTime.text = getDateTime(datetime, "time")
//        getFlexibleTextViewSize()
//    }
//
//
//    func getFlexibleTextViewSize(){
//        let fixedWidth = tvMessage.frame.size.width
//        let newSize = tvMessage.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
//        tvMessage.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
//    }
//
//
//    func getDateTime(_ dateAndTime : String,_ type : String) -> String{
//        let subStrDate = dateAndTime.prefix(10)
//        let date = String(subStrDate)
//
//        let start = dateAndTime.index(dateAndTime.startIndex, offsetBy: 11)
//        let end = dateAndTime.index(dateAndTime.startIndex, offsetBy: 15)
//        let range = start...end
//        let time = String(dateAndTime[range])
//
//        if type == "date" {
//            return date
//        }
//        else{
//            return time
//        }
//    }
//    
    
    
}

