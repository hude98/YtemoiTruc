//
//  News.swift
//  YtemoiTruc
//
//  Created by Ta Huy Hung on 09/10/2021.
//

import Foundation

struct News : Codable{
    var id : String!
    var patientName : String!
    var room : String!
    var bed : String!
    var dateTimes : [String]!
    var messages : [String]!
    var autoDateTime : String!
    var autoMessage : String!
    var listIdMedicalStaff : [String]!
    var sip : String!
    var newsState: String!
    
    public init(_ id: String, _ patientName: String, _ room : String,
                _ bed : String, _ dateTimes : [String], _ messages : [String],
                _ autoDateTime : String, _ autoMessage : String, _ listIdMedicalStaff : [String], _ sip : String, _ newsState : String) {
        self.id = id
        self.patientName = patientName
        self.room = room
        self.bed = bed
        self.dateTimes = dateTimes
        self.messages = messages
        self.autoDateTime = autoDateTime
        self.autoMessage = autoMessage
        self.listIdMedicalStaff = listIdMedicalStaff
        self.sip = sip
        self.newsState = newsState
    }
    
    
    static func getNews(_ news: NSDictionary) -> News {
        return News(news["_id"] as? String ?? "",
                    news["data_bantin_benhnhan"] as? String ?? "",
                    news["data_bantin_buong"] as? String ?? "",
                    news["data_bantin_giuong"] as? String ?? "",
                    news["data_bantin_dsgio"] as? [String] ?? [String](),
                    news["data_bantin_dstin"] as? [String] ?? [String](),
                    news["data_bantin_thoigiantudong"] as? String ?? "",
                    news["data_bantin_buoctudong"] as? String ?? "",
                    news["data_bantin_dsnhanvienyte"] as? [String] ?? [String](),
                    news["data_bantin_sosip"] as? String ?? "",
                    news["data_bantin_trangthaibantin"] as? String ?? "")
    }
    
    
    static func getListFromJson(_ json: Array<NSDictionary>) ->  [News] {
        var newsList: [News] = [News]()
        
        if json.count > 0 {
            for i in 0...json.count - 1{
                let newsObj = json[i]
                let news = News.getNews(newsObj)
                newsList.append(news)
            }
        }
        
        return newsList;
    }
    
}






