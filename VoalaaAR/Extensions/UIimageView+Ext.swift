//
//  UIimageView+Ext.swift
//  VoalaaAR
//
//  Created by Amr Moussa on 08/11/2021.
//

import UIKit

extension UIImageView{
    func downloadImage(fromURL url: String) {
         NetworkManager.shared.downloadImage(from: url) { [weak self] (image) in
         guard let self = self else { return }
         DispatchQueue.main.async {
            self.image = image
            self.contentMode = .scaleAspectFit
         }    
     }
       
    }
}
