//
//  ChangeHandView.swift
//  Voala
//
//  Created by Amr Moussa on 11/04/2022.
//

import UIKit


class ChangeHandView: UIView {
    let footerLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let changeLanguageButton :UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.tintColor = .white
        return button
    }()
    
    var handOreiantaion:handType = .left {
        didSet {
            handOreiantaion == .left ? setRightHandedView():setLeftHanedView()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLyout()
        setRightHandedView()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLyout(){
        translatesAutoresizingMaskIntoConstraints = false
        addSubViews(footerLabel,changeLanguageButton)
        NSLayoutConstraint.activate([
            changeLanguageButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            changeLanguageButton.topAnchor.constraint(equalTo: topAnchor),
            changeLanguageButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            changeLanguageButton.heightAnchor.constraint(equalToConstant: 50),
            
            footerLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            footerLabel.topAnchor.constraint(equalTo: changeLanguageButton.bottomAnchor),
            footerLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            footerLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    func flipHand() -> handType{
        handOreiantaion = handOreiantaion == .left ? .right:.left
        return handOreiantaion
    }
    
   private  func setLeftHanedView(){
        changeLanguageButton.setImage(Images.lefthHand, for: [])
        footerLabel.text = "Left \n Hand"
    }
    
    private  func setRightHandedView(){
        changeLanguageButton.setImage(Images.rigthHand, for: [])
        footerLabel.text = "Right \n Hand"
    }

}

