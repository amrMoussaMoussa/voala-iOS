//
//  RingNameLabel.swift
//  VoalaAPPClip
//
//  Created by Amr Moussa on 02/11/2021.
//

import UIKit


class RingNameLabel: UILabel {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLyout()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLyout(){
        AddStroke(color: .white)
        textColor = .white
        textAlignment  = .center
        font = UIFont.systemFont(ofSize: 15, weight: .semibold)
    }
   
    
}

