//
//  NetworkManager.swift
//  VoalaAPPClip
//
//  Created by Amr Moussa on 04/11/2021.
//

import UIKit

class NetworkManager{
    
    static let shared = NetworkManager()
    let ringsBaseUrl  = "http://console.voala.io/api/rings/"
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
    
    
    
    
    func getRing(ringID:String,completed:@escaping(Result<[Ring],networkError>)->()){
        let endpoint = ringsBaseUrl + ringID
        
        guard let url = URL(string: endpoint) else {
            completed(.failure(.noInternetConnection))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let _ = error {
                completed(.failure(.noInternetConnection))
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completed(.failure(.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let followers = try decoder.decode([Ring].self, from: data)
                completed(.success(followers))
            } catch {
                completed(.failure(.invalidData))
            }
        }
        
        task.resume()
    }
    
    func downloadImage(from url:String,completion:@escaping(UIImage)->()){
        
        let urlKey = NSString(string: url)
//        if let cashedImage = cashe[urlKey]{
//            completion(cashedImage)
//            return
//        }
        
        guard let validUrl = URL(string: url) else {return}
        let task = URLSession.shared.dataTask(with: validUrl){(data,respose,error) in
            //check for error
            if let _ = error {}
            
            //check response status
            guard let resonse = respose as?HTTPURLResponse , resonse.statusCode == 200 else{return }
            
            //check if data is Valid
            guard let data = data else{return}
            
            
            guard  let image = UIImage(data: data) else {return}
//            self.cashe[urlKey]  = image
            completion(image)
        }
        
        task.resume()
        
    }
    
}


public enum  networkError:String,Error {
    case noInternetConnection = "Unable to complete your request. Please check your internet connection."
    case invalidResponse = "Invalid response from the server. Please try again."
    case invalidData = "The data received from the server was invalid. Please try again."
}
