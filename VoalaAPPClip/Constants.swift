//
//  Constants.swift
//  VoalaaAR
//
//  Created by Amr Moussa on 26/10/2021.
//

import UIKit


struct Images {
    static let ringUpImage = UIImage(named: "ringUp")
    static let ringBackImage = UIImage(named: "ringBack")
    static let ring2 = UIImage(named: "ring2")
    static let logo = UIImage(named: "logoImage")
    static let MenuImage = UIImage(systemName: "line.3.horizontal",withConfiguration: UIImage.SymbolConfiguration(scale:.large))
    static let exitImage = UIImage(named: "exit")
    static let downloadImage = UIImage(named: "Download")
    static let reopenImage = UIImage(named: "reopen")
    static let shareImage = UIImage(named: "share")
    static let flashImage = UIImage(named: "flash")
    static let inCartImage = UIImage(named: "inCart")
    static let xFill = UIImage(systemName: "x.circle.fill",withConfiguration: UIImage.SymbolConfiguration(scale:.large))
    
    static let rigthHand = UIImage(systemName: "hand.point.right",withConfiguration: UIImage.SymbolConfiguration(pointSize: 100, weight: .bold, scale: .large))
    static let lefthHand = UIImage(systemName: "hand.point.left",withConfiguration: UIImage.SymbolConfiguration(pointSize: 100, weight: .bold, scale: .large))
}


struct segues{
    static let showCameraSegue = "showCameraSegue"
    static let HometoRingVC = "HometoRingVC"
}
