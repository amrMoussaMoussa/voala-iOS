//
//  ScanningVeiw.swift
//  VoalaAPPClip
//
//  Created by Amr Moussa on 02/11/2021.
//

import UIKit


class ScainnigView: UIView {
    let headlinelLabel = UILabel()
    let footerLabel = UILabel()
    var gifImageView:UIImageView?
    
    let exitButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLyout()
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLyout(){
        backgroundColor = .white.withAlphaComponent(0.2)
        
        let safeArea = safeAreaLayoutGuide
        addSubview(exitButton)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        exitButton.setImage(Images.exitImage, for: [])
        NSLayoutConstraint.activate([
            exitButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            exitButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            exitButton.widthAnchor.constraint(equalToConstant: 50),
            exitButton.heightAnchor.constraint(equalTo: exitButton.widthAnchor),
        ])

        
        addSubview(headlinelLabel)
        headlinelLabel.textColor = .white
        headlinelLabel.numberOfLines = 0
        headlinelLabel.text = "PLACE YOUR HAND IN THE MIDDLE OF THE SCREEN"
        headlinelLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        headlinelLabel.textAlignment = .center
        headlinelLabel.translatesAutoresizingMaskIntoConstraints = false
        let padding:CGFloat = 20
       
        
        addSubview(footerLabel)
        footerLabel.textColor = .white
        footerLabel.numberOfLines = 1
        footerLabel.text = "Scanning hand ..."
        footerLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        footerLabel.textAlignment = .center
        footerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            footerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            footerLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant:-padding),
            footerLabel.trailingAnchor.constraint(equalTo: trailingAnchor,constant: -padding),
            footerLabel.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        
        if let gifImageView = UIImageView.fromGif( resourceName: "hand_guide") {
        addSubview(gifImageView)
            gifImageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                gifImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding*2),
                gifImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
                gifImageView.trailingAnchor.constraint(equalTo: trailingAnchor,constant: -padding*2),
                gifImageView.heightAnchor.constraint(equalTo:gifImageView.widthAnchor),
                
                headlinelLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
                headlinelLabel.topAnchor.constraint(equalTo: gifImageView.bottomAnchor,constant: padding/2),
                headlinelLabel.trailingAnchor.constraint(equalTo: trailingAnchor,constant: -padding),
                headlinelLabel.heightAnchor.constraint(equalToConstant: 100),
                
            ])
            gifImageView.animationDuration = 5
            gifImageView.animationRepeatCount = 0
            gifImageView.startAnimating()
        }
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    func UpdateLabeltext(hand:handType){
        headlinelLabel.text =  hand == .left ? "PLACE YOUR LEFT HAND IN THE MIDDLE OF THE SCREEN":"PLACE YOUR RIGHT HAND IN THE MIDDLE OF THE SCREEN"
    }
    
    
}



extension UIImageView {
    static func fromGif(resourceName: String) -> UIImageView? {
        guard let path = Bundle.main.path(forResource: resourceName, ofType: "gif") else {
            print("Gif does not exist at that path")
            return nil
        }
        let url = URL(fileURLWithPath: path)
        guard let gifData = try? Data(contentsOf: url),
            let source =  CGImageSourceCreateWithData(gifData as CFData, nil) else { return nil }
        var images = [UIImage]()
        let imageCount = CGImageSourceGetCount(source)
        for i in 0 ..< imageCount {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(UIImage(cgImage: image))
            }
        }
        let gifImageView = UIImageView()
        gifImageView.animationImages = images
        return gifImageView
    }
}

