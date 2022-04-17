//
//  FlashView.swift
//  Voala 
//
//  Created by Amr Moussa on 23/11/2021.
//

import UIKit


class CameraHeaderView: UIView {
    
    let inCartButton = UIButton()
    let exitButton = UIButton()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLyout()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLyout(){
        addSubViews(inCartButton,exitButton)
        inCartButton.setImage(Images.inCartImage, for: [])
        exitButton.setImage(Images.exitImage, for: [])
        inCartButton.translatesAutoresizingMaskIntoConstraints = false
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            inCartButton.topAnchor.constraint(equalTo: topAnchor),
            inCartButton.trailingAnchor.constraint(equalTo: trailingAnchor,constant: .npadding),
            inCartButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            inCartButton.widthAnchor.constraint(equalTo: inCartButton.heightAnchor),
            
         
            
            exitButton.topAnchor.constraint(equalTo: topAnchor),
            exitButton.leadingAnchor.constraint(equalTo: leadingAnchor,constant: .padding),
            exitButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            exitButton.widthAnchor.constraint(equalTo: exitButton.heightAnchor),
        ])
        
        translatesAutoresizingMaskIntoConstraints = false
       
        
    }
    
   
    
}

