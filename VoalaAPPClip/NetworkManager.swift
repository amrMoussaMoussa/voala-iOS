//
//  NetworkManager.swift
//  VoalaAPPClip
//
//  Created by Amr Moussa on 04/11/2021.
//

import UIKit

enum ringCuts:String{
    case full = "Full"
    case upper = "Upper"
    case loawer = "Lower"
}

class NetworkManager{
    
    static let shared = NetworkManager()
    let ringsBaseUrl  = "https://console.voala.io/api/rings/"
    var ringID:String?
    var currentRing:Ring?
    var optionRingd:[Ring] = []
    
    private init (){}
    
    
    func setRingID(ringID:String?){
        self.ringID = ringID
    }
    
    func getRing(ringID:String,completed:@escaping(Result<[Ring],networkError>)->()){
        let endpoint = ringsBaseUrl + ringID
        
        guard let url = URL(string: endpoint) else {
            completed(.failure(.noInternetConnection))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self](data, response, error) in
            guard let self = self else {return}
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
                let rings = try decoder.decode([Ring].self, from: data)
                self.currentRing = rings.first
                self.optionRingd = rings.reversed()
                completed(.success(rings))
            } catch (let err){
                print(err)
                completed(.failure(.invalidData))
            }
        }
        
        task.resume()
    }
    
    func downloadImage(from url:String,completion:@escaping(UIImage)->()){
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
    
    func downloadRingModelUrl(ringID:String,ringPth:String,ringCut:ringCuts = .full,completed:@escaping(Result<URL,networkError>)->()){
        guard !FileManager.default.fileExists(atPath: getDocumentsDirectory().appendingPathComponent("Ring\(ringCut.rawValue)_\(ringID).usdz").path)else{
            completed(.success(getDocumentsDirectory().appendingPathComponent("Ring\(ringCut.rawValue)_\(ringID).usdz")))
            return
        }
        
        guard let url = URL(string: ringPth) else {
            completed(.failure(.noInternetConnection))
            return
        }
        let task = URLSession.shared.downloadTask(with: url) { (localUrl, response, error) in
            if let _ = error {
                completed(.failure(.noInternetConnection))
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(.failure(.invalidResponse))
                return
            }
            
            guard let localURL = localUrl  else {
                completed(.failure(.invalidData))
                return
            }
            
            let fileURL = self.getDocumentsDirectory().appendingPathComponent("Ring\(ringCut.rawValue)_\(ringID).usdz")
            do {
                try FileManager.default.copyItem(at: localURL, to: fileURL)
                completed(.success(fileURL))
            } catch {
                completed(.failure(.invalidData))
            }
        }
        task.resume()
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}


public enum  networkError:String,Error {
    case noInternetConnection = "Unable to complete your request. Please check your internet connection."
    case invalidResponse = "Invalid response from the server. Please try again."
    case invalidData = "The data received from the server was invalid. Please try again."
}
