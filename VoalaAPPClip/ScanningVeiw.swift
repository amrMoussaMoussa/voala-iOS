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
    
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLyout()
        
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
//        gifImageView?.animationImages = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLyout(){
        backgroundColor = .black.withAlphaComponent(0.6)
        
        addSubview(headlinelLabel)
        headlinelLabel.textColor = .white
        headlinelLabel.numberOfLines = 0
        headlinelLabel.text = "Point your hand in front of camera"
        headlinelLabel.font = UIFont.systemFont(ofSize: 40, weight: .semibold)
        headlinelLabel.textAlignment = .center
        headlinelLabel.translatesAutoresizingMaskIntoConstraints = false
        let padding:CGFloat = 20
        NSLayoutConstraint.activate([
            headlinelLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            headlinelLabel.topAnchor.constraint(equalTo: topAnchor, constant: padding*3),
            headlinelLabel.trailingAnchor.constraint(equalTo: trailingAnchor,constant: -padding),
            headlinelLabel.heightAnchor.constraint(equalToConstant: 200),
        ])
        
        addSubview(footerLabel)
        footerLabel.textColor = .white
        footerLabel.numberOfLines = 1
        footerLabel.text = "loading ..."
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
                gifImageView.topAnchor.constraint(equalTo: headlinelLabel.bottomAnchor, constant: padding),
                gifImageView.trailingAnchor.constraint(equalTo: trailingAnchor,constant: -padding*2),
                gifImageView.heightAnchor.constraint(equalTo:gifImageView.widthAnchor)
            ])
            gifImageView.animationDuration = 5
            gifImageView.animationRepeatCount = 0
            gifImageView.startAnimating()
        }
        translatesAutoresizingMaskIntoConstraints = false
        
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


extension UIView{
    func pinToSuperViewEdgesWithPadding(in view:UIView,padding:CGFloat){
           translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([
               leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: padding),
               topAnchor.constraint(equalTo: view.topAnchor,constant: padding),
               trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -padding),
               bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -padding)
           ])
       }
    
}
