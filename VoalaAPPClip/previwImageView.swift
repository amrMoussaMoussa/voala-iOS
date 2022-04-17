//
//  previwImageView.swift
//  VoalaaAR
//
//  Created by Amr Moussa on 03/11/2021.
//

import UIKit


class previewImageV: UIView {
    let screenShotImageView = UIImageView()
    let ringView = UIImageView()

    let upperVeiw = UpperViewo()
    let buyButton = UIButton()
    let shareButton = UIButton()
    
    let brandName = UILabel()
    var ring:Ring?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLyout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configureLyout(){
        backgroundColor = .black.withAlphaComponent(0.9)
        let safeArea = safeAreaLayoutGuide
        buyButton.translatesAutoresizingMaskIntoConstraints = false
        buyButton.backgroundColor = .white
        buyButton.setTitleColor(.black, for: [])
        buyButton.layer.cornerRadius = 25
        buyButton.clipsToBounds = true
        buyButton.setTitle("ADD TO CART", for: [])
        buyButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        
        
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.backgroundColor = .clear
        shareButton.setImage(Images.shareImage, for: [])
        
        brandName.translatesAutoresizingMaskIntoConstraints = false
        brandName.textColor = .white.withAlphaComponent(0.7)
        brandName.font = UIFont.systemFont(ofSize: 40, weight: .semibold)
        brandName.textAlignment = .center
        brandName.text = ring?.company?.name
        
        addSubview(screenShotImageView)
        screenShotImageView.addSubview(ringView)
        addSubview(upperVeiw)
        addSubview(buyButton)
        addSubview(shareButton)
        addSubview(brandName)
//        buyButton.frame = CGRect(x: 100, y: 100, width: 100, height: 50)
        ringView.frame = .init(x: 100, y: 100, width: 0, height: 0)
        let padding:CGFloat = 20
        screenShotImageView.pinToSuperViewSafeArea(in: self)
        NSLayoutConstraint.activate([
            upperVeiw.leadingAnchor.constraint(equalTo: leadingAnchor),
            upperVeiw.trailingAnchor.constraint(equalTo: trailingAnchor),
            upperVeiw.topAnchor.constraint(equalTo:safeArea.topAnchor),
            upperVeiw.heightAnchor.constraint(equalToConstant: 50),

            buyButton.trailingAnchor.constraint(equalTo: trailingAnchor,constant: -padding),
            buyButton.bottomAnchor.constraint(equalTo:safeArea.bottomAnchor, constant: -padding),
            buyButton.widthAnchor.constraint(equalToConstant: 200),
            buyButton.heightAnchor.constraint(equalToConstant: 50),
            
            shareButton.centerYAnchor.constraint(equalTo: buyButton.centerYAnchor),
            shareButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            shareButton.widthAnchor.constraint(equalToConstant: 50),
            shareButton.heightAnchor.constraint(equalToConstant: 50),
            
            brandName.centerXAnchor.constraint(equalTo: centerXAnchor),
            brandName.bottomAnchor.constraint(equalTo: buyButton.topAnchor),
            brandName.widthAnchor.constraint(equalTo:widthAnchor),
            brandName.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        upperVeiw.exitButton.addTarget(self, action: #selector(dimiss), for: .touchUpInside)
        upperVeiw.reopenButton.addTarget(self, action: #selector(dimiss), for: .touchUpInside)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func addImage(ringImage:UIImage?,handImage:UIImage?,frame:CGRect?,centerPoint:CGPoint?,angel:CGFloat?){
            DispatchQueue.main.async {[weak self] in
                guard let self = self else {return}
                self.ringView.image = ringImage
                self.screenShotImageView.image = handImage
                let xPOint = (self.screenShotImageView.frame.width*centerPoint!.x)
                let yPOint = self.screenShotImageView.frame.height*centerPoint!.y
                let centerConverted:CGPoint =  .init(x: xPOint, y:yPOint)
                self.ringView.bounds = frame!
                self.ringView.center = centerConverted
                self.ringView.transform =  CGAffineTransform(rotationAngle: angel!)
            }
        }
    
    func setRing(ring:Ring){
        self.ring = ring
        DispatchQueue.main.async {
            self.brandName.text = ring.company?.name
        }
    }
    
    func  hideForScreenShot(){
        upperVeiw.isHidden = true
        buyButton.isHidden = true
        shareButton.isHidden = true
    }
    
    func reShowYour(){
        upperVeiw.isHidden = false
        buyButton.isHidden = false
        shareButton.isHidden = false
    }
    
    @objc func dimiss(){
        isHidden = true
    }
    
}

