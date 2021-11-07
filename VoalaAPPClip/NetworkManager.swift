//
//  NetworkManager.swift
//  VoalaAPPClip
//
//  Created by Amr Moussa on 04/11/2021.
//

import Foundation


class NetworkManager{
    
    static let shared = NetworkManager()
    var ringID:String?
    
    private init (){}
    
    
    func setRingID(url:String){
        if let range = url.range(of: "ringId=") {
            let substring = url[range.upperBound...]
            ringID = String(substring)
        }
        else {
          print("String not present")
        }
        
        
    }
    
    
}
