//
//  RingViewController.swift
//  VoalaaAR
//
//  Created by Amr Moussa on 07/11/2021.
//

import UIKit
import SceneKit


class RingViewController: UIViewController {
   
    var  ringView:SCNView!
    var  ringScene:SCNScene!
    var cameraNode:SCNNode!
    let tryOnButton = UIButton()
    
    let padding:CGFloat = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureButton()
        configureView()
        configureScene()
        configureCamera()
    }
    
    
    private func configureButton(){
        tryOnButton.translatesAutoresizingMaskIntoConstraints = false
        tryOnButton.backgroundColor = .systemBackground
        tryOnButton.layer.borderColor = UIColor.label.cgColor
        tryOnButton.layer.borderWidth = 2
        tryOnButton.setTitle("Try Ring On", for: [])
        tryOnButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        view.addSubview(tryOnButton)
        NSLayoutConstraint.activate([
            tryOnButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: padding),
            tryOnButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -padding),
            tryOnButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding),
            tryOnButton.heightAnchor.constraint(equalToConstant: 70)
        ])
        tryOnButton.addTarget(self, action: #selector(tryOnTapped), for: .touchUpInside)
    }
    
    private func configureView(){
        ringView = SCNView()
        ringView.allowsCameraControl = true
        ringView.autoenablesDefaultLighting = true
        ringView.backgroundColor = .clear
        ringView.contentMode = .scaleAspectFit
        view.addSubview(ringView)
        ringView.translatesAutoresizingMaskIntoConstraints  = false
        NSLayoutConstraint.activate([
            ringView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ringView.topAnchor.constraint(equalTo: view.topAnchor),
            ringView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ringView.bottomAnchor.constraint(equalTo: tryOnButton.topAnchor,constant: -padding),
        ])
    }
    
    private func configureScene(){
        let ringName = NetworkManager.shared.ringID == "2" ? "Ring.obj":"RoseGolddiamond.usdz"
        ringScene = SCNScene(named: ringName)
        ringView.scene = ringScene
        ringView.isPlaying = true
    }
    
    private func configureCamera(){
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 1, 6)
        ringScene.rootNode.addChildNode(cameraNode)
        ringView.pointOfView = cameraNode
    }
   
    @objc func tryOnTapped(){
        self.performSegue(withIdentifier: segues.showCameraSegue, sender: self)
    }

}
