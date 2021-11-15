//
//  OtpViewController.swift
//  ytemoiQRCode
//
//  Created by Ta Huy Hung on 30/09/2021.
//

import UIKit

class OtpViewController: UIViewController {
    var qrData: QRData? = nil
    var phoneNumber : String?
    @IBOutlet weak var edtOtpCode: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addDoneButton(to: edtOtpCode)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func goToNextViewBtnPressed(_ sender: Any) {
        if edtOtpCode.text == "" {
            showToast(message: "Bạn chưa nhập mã OTP!")
            return
        }
        requestCheckRightInfoApi()
    }
    
    private func requestCheckRightInfoApi(){
        let url = "https://ytemoi.com/api/ncb/app_truc"
        let headers = ["Content-Type" : "application/json"] as [String : String]
        let params = ["loai": Key.appQRCode,
                      "qrcode": qrData?.codeString ?? "",
                      "sdt": phoneNumber ?? "",
                      "otp": edtOtpCode.text!,
                      "apptoken" : Utils.getFirebaseRegistrationToken(),
                      "typedevice" : Key.ios] as [String : Any]
        
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
                let jsonString = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.fragmentsAllowed) as! String
                let data = jsonString.data(using: .utf8)
                var json: NSDictionary? = nil
                if let data = data {
                    json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.fragmentsAllowed) as? NSDictionary
                }
                let result = json?["ketqua"]
                if result as! String == "Success" {
                    DispatchQueue.main.async {
                        let nurseCallVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ListNewsViewController") as! ListNewsViewController
                        let nv = json?["nv"] as! NSDictionary
                        let id = nv["idNhanVien"] as! String
                        let sipGlobal = nv["SoSipGlobal"] as! String
                        let sipGlobalPass = nv["SoSipGlobalPass"] as! String
                        let name = nv["HoTenNhanVien"] as! String
                        let faculty = nv["Khoa"] as! String
                        let user = User(id: id, name: name, sipGlobal: sipGlobal, sipGlobalPass: sipGlobalPass, faculty: faculty)
                        Utils.setUserInfo(user)
                        self.navigationController?.pushViewController(nurseCallVC, animated: true)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        let message = json?["error"]
                        self.showToast(message: message as! String)
                    }
                }
                
            } catch let error {
                print("Error parsing json: \(error)")
            }
        }
        
    }
    
    
    
}
