//
//  previwImageView.swift
//  VoalaaAR
//
//  Created by Amr Moussa on 03/11/2021.
//

import UIKit


class PreviewImageView: UIViewController {
    
    let exitButton = UIButton()
    let ringIMage = UIImageView()
    let handImage = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLyout()
    }
    
    private func configureLyout(){
        view.backgroundColor = .clear
        exitButton.setImage(UIImage(systemName: "xmark"), for: [])
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        exitButton.imageView?.tintColor = .white
        exitButton.imageView?.contentMode = .scaleToFill
        
//
//        ringIMage.translatesAutoresizingMaskIntoConstraints = false
//        ringIMage.contentMode = .scaleAspectFit
        ringIMage.contentMode = .center
        
        handImage.translatesAutoresizingMaskIntoConstraints = false
        handImage.contentMode = .scaleToFill
        handImage.backgroundColor = .red
        
        
        
        view.addSubview(handImage)
        view.addSubview(ringIMage)
        view.addSubview(exitButton)
        
        let padding:CGFloat = 20
        
        handImage.pinToSuperViewEdgesWithPadding(in: view, padding: 0)
        ringIMage.pinToSuperViewEdgesWithPadding(in: view, padding: 0)
        
        NSLayoutConstraint.activate([
            exitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            exitButton.topAnchor.constraint(equalTo: view.topAnchor, constant: padding),
            exitButton.widthAnchor.constraint(equalToConstant: 75),
            exitButton.heightAnchor.constraint(equalTo: exitButton.widthAnchor),
        ])
        exitButton.addTarget(self, action: #selector(dimiss), for: .touchUpInside)
    }
    
    @objc func dimiss(){
        dismiss(animated: true)
    }
    
    func addImage(ringImage:UIImage?,handImage:UIImage?,frame:CGRect?,center:CGPoint?,angel:CGFloat?){
        DispatchQueue.main.async {
            self.ringIMage.image = ringImage
            print("cameraframe: \(ringImage?.size)")
            self.handImage.image = handImage
            self.ringIMage.bounds = frame!
            self.ringIMage.center = center!
            self.ringIMage.transform =  CGAffineTransform(rotationAngle: angel!)
        }
    }
    
    
}






class previewImageV: UIView {
    
    let exitButton = UIButton()
    let buyButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLyout()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLyout(){
        backgroundColor = .clear
        exitButton.setImage(UIImage(systemName: "xmark"), for: [])
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        exitButton.imageView?.tintColor = .systemGray5
        exitButton.imageView?.contentMode = .scaleToFill
        exitButton.backgroundColor = .black.withAlphaComponent(0.5)
        exitButton.layer.cornerRadius = 20
        exitButton.clipsToBounds = true
        
        buyButton.translatesAutoresizingMaskIntoConstraints = false
        buyButton.backgroundColor = .black
        buyButton.layer.cornerRadius = 25
        buyButton.clipsToBounds = true
        buyButton.setTitle("Buy 100$", for: [])
        buyButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        
        addSubview(exitButton)
        addSubview(buyButton)
//        buyButton.frame = CGRect(x: 100, y: 100, width: 100, height: 50)
        
        let padding:CGFloat = 20
        
        NSLayoutConstraint.activate([
            exitButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            exitButton.topAnchor.constraint(equalTo: topAnchor, constant: padding*1.5),
            exitButton.widthAnchor.constraint(equalToConstant: 40),
            exitButton.heightAnchor.constraint(equalTo: exitButton.widthAnchor),

            buyButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            buyButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
            buyButton.widthAnchor.constraint(equalToConstant: 200),
            buyButton.heightAnchor.constraint(equalToConstant: 50),
        ])
        exitButton.addTarget(self, action: #selector(dimiss), for: .touchUpInside)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc func dimiss(){
        isHidden = true
    }
    
}

