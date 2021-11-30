//
//  UpperView.swift
//  Voala App Clip
//
//  Created by Amr Moussa on 21/11/2021.

import UIKit

class UpperViewo: UIView {
    let exitButton = UIButton()
    let reopenButton = UIButton()
    let downLoadButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLyout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLyout(){
        addSubViews(exitButton,reopenButton,downLoadButton)
        exitButton.setImage(Images.exitImage, for: [])
        reopenButton.setImage(Images.reopenImage, for: [])
        downLoadButton.setImage(Images.downloadImage, for: [])
        
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        reopenButton.translatesAutoresizingMaskIntoConstraints = false
        downLoadButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            exitButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant:.padding ),
            exitButton.topAnchor.constraint(equalTo: topAnchor),
            exitButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            exitButton.widthAnchor.constraint(equalTo: exitButton.heightAnchor),
            
            reopenButton.topAnchor.constraint(equalTo: topAnchor),
            reopenButton.trailingAnchor.constraint(equalTo: trailingAnchor,constant: .npadding),
            reopenButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            reopenButton.widthAnchor.constraint(equalTo: reopenButton.heightAnchor),
            
            downLoadButton.trailingAnchor.constraint(equalTo: reopenButton.leadingAnchor, constant: .npadding),
            downLoadButton.topAnchor.constraint(equalTo: topAnchor),
            downLoadButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            downLoadButton.widthAnchor.constraint(equalTo: downLoadButton.heightAnchor)
        ])
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    
}


extension CGFloat{
    static let padding:CGFloat = 10
    static let npadding:CGFloat = -10
}
