//
//  Linphone.swift
//  YtemoiTruc
//
//  Created by Ta Huy Hung on 16/10/2021.
//

import Foundation
import linphonesw

public class Linphone{
    static var shared = Linphone()
    
    private var linphoneCore : Core?
    
    init(){
        
    }
    
    public func setLinphoneCore(_ linphoneCore : Core){
        self.linphoneCore = linphoneCore
    }
    
    public func getLinphoneCore() -> Core?{
        return linphoneCore
    }
    
}

