//
//  FlashView.swift
//  VoalaAPPClip
//
//  Created by Amr Moussa on 10/04/2022.
//

import UIKit
import AVFoundation

class FlashView: UIView {
    
    let flashButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLyout()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLyout(){
        translatesAutoresizingMaskIntoConstraints = false
        addSubViews(flashButton)
        flashButton.setImage(Images.flashImage, for: [])
        flashButton.translatesAutoresizingMaskIntoConstraints =  false
        flashButton.pinToSuperViewEdges(in: self)
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

