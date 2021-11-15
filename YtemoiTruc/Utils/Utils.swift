//
//  Utils.swift
//  YtemoiTruc
//
//  Created by Ta Huy Hung on 08/10/2021.
//

import Foundation
import UIKit

class Utils: NSObject {
    static var listNewsdelegate : ListNewsDelegate? = nil
    static var detailMessdelegate : DetailMessageDelegate? = nil
    
    class func sendPostRequest(urlString: String,
                               headers: [String:String],
                               postDictionary: [String:Any],
                               completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        if let jsonData = try? JSONSerialization.data(withJSONObject: postDictionary, options: .fragmentsAllowed) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            }
            if let url = URL(string: urlString) {
                var request = URLRequest(url: url)
                for (key, value) in headers {
                    request.addValue(value, forHTTPHeaderField: key)
                }
                request.httpMethod = "POST"
                request.httpBody = jsonData
                let task = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
                task.resume()
                
            } else {
                print("could not open url, it was nil")
            }
        }
    }
    
    
    
    //OS VERSION
    class func getMainWindow() -> UIWindow? {
        if(getOsVersion() >= 13) {
            return UIApplication.shared.windows.filter({$0.isKeyWindow}).first
        }
        else {
            return UIApplication.shared.delegate?.window ?? nil
        }
    }
    
    class func getOsVersion() -> Int {
        let systemVersion = UIDevice.current.systemVersion
        return (systemVersion as NSString).integerValue
    }
    
    
    
    //USER INFO
    class func setUserInfo(_ user : User){
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(user) {
            UserDefaults.standard.set(encoded, forKey: Key.user)
        }
    }
    
    class func getUserInfo() -> User{
        if let user = UserDefaults.standard.object(forKey: Key.user) as? Data {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode(User.self, from: user) {
                return decoded
            }
        }
        return User()
    }
    
    class func removeUserInfo(){
        UserDefaults.standard.removeObject(forKey: Key.user)
    }
    
    
    
    //FIREBASE REGISTRATION TOKEN
    class func setFirebaseRegistrationToken(_ fcm : String) {
        UserDefaults.standard.set(fcm, forKey: Key.firebaseFcmToken)
    }

    class func getFirebaseRegistrationToken() -> String{
        return UserDefaults.standard.string(forKey: Key.firebaseFcmToken) ?? ""
    }
    
    class func removeFirebaseRegistrationToken(){
        UserDefaults.standard.removeObject(forKey: Key.firebaseFcmToken)
    }
    
    
    
    //NEWS
    class func setNewsString(_ newsString : String){
        var news : News?
        var jsonString = newsString
        jsonString = jsonString
            .replacingOccurrences(of: "ObjectId(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "ISODate(", with: "")
        let data = jsonString.data(using: .utf8)
        var json: NSDictionary? = nil
        if let data = data {
            json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.fragmentsAllowed) as? NSDictionary
            print("json : \(json ?? NSDictionary())")
        }
        news = News.getNews(json?["bantin"] as! NSDictionary)
        listNewsdelegate?.updateArrNews(news!)
        detailMessdelegate?.updateMessage(news!)
    }
    
    
    class func getColorFrom(hex : String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    
}

