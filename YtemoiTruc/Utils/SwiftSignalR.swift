//
//  SignalR.swift
//  YtemoiTruc
//
//  Created by Ta Huy Hung on 15/10/2021.
//

import Foundation
import SwiftR

public class SwiftSignalR {
    static var shared = SwiftSignalR()
    
    var chatHub: Hub!
    var connection: SignalR!
    var name: String!
    
    init(){
        
    }
    
    public func startSignalR(){
        let nhanvienId = Utils.getUserInfo().id
        connection = SignalR(Key.signalRHubUrl)
        
        chatHub = Hub(Key.serverHubChat)
        
        getMessFromSignalR()
        
        connection.addHub(chatHub)
        startConnection()
        
        
        chatHub.on(Key.receiveSVG) { [weak self] args in
            print(args ?? "")
        }
         // SignalR events
        
        connection.starting = { [weak self] in
            print("starting")
        }
        
        connection.reconnecting = { [weak self] in
            print("reconnecting")
        }
        
        connection.connected = { [weak self] in
            print("connected")
            
            
            do{
                let string = "{ \"loai\" : \"appnvyt_dangky\", \"kieu\" : \"hỏi\",\"nhanvienid\" : \"\(nhanvienId ?? "")\" }"
                
                print(string)
                
                try self?.chatHub.invoke(Key.sendTo, arguments: [string] ){ result, error in
                    print("result: \(result ?? "")")
                    print("error: \(error ?? "")")
                }
            }catch {
                print("catch error: \(error)")
            }
            
        }
        
        connection.reconnected = { [weak self] in
            print("reconnected")
        }
        
        connection.disconnected = { [weak self] in
            print("disconnected")
        }
        
        connection.connectionSlow = { print("Connection slow...") }

        connection.error = { [weak self] error in
            print("Error: \(String(describing: error))")

            // Here's an example of how to automatically reconnect after a timeout.
            //
            // For example, on the device, if the app is in the background long enough
            // for the SignalR connection to time out, you'll get disconnected/error
            // notifications when the app becomes active again.
            
            if let source = error?["source"] as? String, source == "TimeoutException" {
                print("Connection timed out. Restarting...")
                self?.connection.start()
            }
        }
    }
    
    public func getMessFromSignalR(){
        chatHub.on(Key.receiveSVG) { info in
            print("info: \(info ?? [Any]()) ")
            let stringBanTin = info?[0] as! String
            print(stringBanTin)
            Utils.setNewsString(stringBanTin)
        }
        
        chatHub.on(Key.mess) { message in
            print("message: \(message ?? [Any]()) ")
        }
    }
    
    public func startConnection(){
        connection.start()
    }
    
    public func reconnectConnection(){
        connection.start()
    }
    
    public func stopConnection(){
        connection.stop()
    }
    
}
