//
//  FlashView.swift
//  Voala 
//
//  Created by Amr Moussa on 23/11/2021.
//

import UIKit
import AVFoundation

class FlashView: UIView {
    let flashButton = UIButton()
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
        addSubViews(flashButton,inCartButton,exitButton)
        flashButton.setImage(Images.flashImage, for: [])
        inCartButton.setImage(Images.inCartImage, for: [])
        exitButton.setImage(Images.exitImage, for: [])
        flashButton.translatesAutoresizingMaskIntoConstraints =  false
        inCartButton.translatesAutoresizingMaskIntoConstraints = false
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            inCartButton.topAnchor.constraint(equalTo: topAnchor),
            inCartButton.trailingAnchor.constraint(equalTo: trailingAnchor,constant: .npadding),
            inCartButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            inCartButton.widthAnchor.constraint(equalTo: inCartButton.heightAnchor),
            
            flashButton.topAnchor.constraint(equalTo: topAnchor),
            flashButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            flashButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            flashButton.widthAnchor.constraint(equalTo: inCartButton.heightAnchor),
            
            exitButton.topAnchor.constraint(equalTo: topAnchor),
            exitButton.leadingAnchor.constraint(equalTo: leadingAnchor,constant: .padding),
            exitButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            exitButton.widthAnchor.constraint(equalTo: exitButton.heightAnchor),
        ])
        
        translatesAutoresizingMaskIntoConstraints = false
        flashButton.addTarget(self, action: #selector(flashTapped), for:.touchUpInside)
        
    }
    
    @objc func flashTapped(){
        toggleFlash()
    }
    
    func toggleFlash() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }

        if device.hasTorch {
            do {
                try device.lockForConfiguration()

                if device.torchMode == .on {
                    device.torchMode = .off
                } else {
                    device.torchMode = .on
                }

                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
    
}

