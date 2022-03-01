//
//  RingViewController.swift
//  VoalaaAR
//
//  Created by Amr Moussa on 07/11/2021.
//

import UIKit
import SceneKit
import CoreMedia


class RingViewController: UIViewController {
    
    let upperView = RIngViewUpperView()
    let infoView = RingInfoView()
    var  ringView:SCNView!
    var  ringScene:SCNScene!
    var cameraNode:SCNNode!
    let tryOnButton = UIButton()
    let buyButton = UIButton()
    let exitButton = UIButton()
    
    var loadingView:UIView?
    
    var currentRing:Ring?
    
    
    
    
    let padding:CGFloat = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUpperView()
        configureBuyButton()
        configureTryButton()
        configureInfoView()
        configureView()
        getRingFromDB()
        configureNotificationHandler()
        configureExitButon()
    }
    
    deinit{
       removeNotificationHandler()
    }
    
    
    private func configureUpperView(){
        view.addSubview(upperView)
        let SA = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            upperView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            upperView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            upperView.topAnchor.constraint(equalTo: SA.topAnchor, constant: 10),
            upperView.heightAnchor.constraint(equalToConstant: 60),
        ])
        
        
    }
    
    private func configureBuyButton(){
        buyButton.translatesAutoresizingMaskIntoConstraints = false
        buyButton.backgroundColor = .systemGray2
        buyButton.layer.borderColor = UIColor.label.cgColor
        buyButton.layer.borderWidth = 2
        buyButton.setTitle(" ADD TO CART", for: [])
        buyButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        view.addSubview(buyButton)
        NSLayoutConstraint.activate([
            buyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: padding),
            buyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -padding),
            buyButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding),
            buyButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        buyButton.addTarget(self, action: #selector(buyButtonTapped), for: .touchUpInside)
    }
    
    
    private func configureInfoView(){
        view.addSubview(infoView)
        NSLayoutConstraint.activate([
            infoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoView.bottomAnchor.constraint(equalTo: tryOnButton.topAnchor, constant: -padding),
            infoView.heightAnchor.constraint(equalToConstant: 70),
            infoView.widthAnchor.constraint(equalTo: view.heightAnchor,multiplier: 0.8),
        ])
        
    }
    
    private func configureTryButton(){
        overrideUserInterfaceStyle = .light
        tryOnButton.translatesAutoresizingMaskIntoConstraints = false
        tryOnButton.backgroundColor = .black
        tryOnButton.layer.borderColor = UIColor.label.cgColor
        tryOnButton.layer.borderWidth = 2
        tryOnButton.setTitle(" Try Ring On", for: [])
        tryOnButton.setImage(Images.logo, for: [])
        tryOnButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        view.addSubview(tryOnButton)
        NSLayoutConstraint.activate([
            tryOnButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: padding),
            tryOnButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -padding),
            tryOnButton.bottomAnchor.constraint(equalTo: buyButton.topAnchor, constant: -padding),
            tryOnButton.heightAnchor.constraint(equalToConstant: 50)
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
            ringView.topAnchor.constraint(equalTo: upperView.bottomAnchor),
            ringView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ringView.bottomAnchor.constraint(equalTo: tryOnButton.topAnchor,constant: -padding),
        ])
    }
    
    private func configureExitButon(){
        view.addSubview(exitButton)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        exitButton.setImage(Images.xFill, for: [])
        NSLayoutConstraint.activate([
            exitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor ),
            exitButton.topAnchor.constraint(equalTo: upperView.bottomAnchor),
            exitButton.heightAnchor.constraint(equalToConstant: 50),
            exitButton.widthAnchor.constraint(equalTo: exitButton.heightAnchor),
        ])
        exitButton.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)
    }
    
    @objc func exitTapped(){
        dismiss(animated: true)
    }
    
    private func getRingFromDB(){
        guard let ringID  = NetworkManager.shared.ringID else{
            return
        }
        loadingView = ringView.showLoadingView()
        NetworkManager.shared.getRing(ringID: ringID,completed: getRingModel(res:))
    }
    
    private func getRingModel(res:Result<[Ring], networkError>) {
        weak var _self = self
        DispatchQueue.main.async {
            self.loadingView?.removeFromSuperview()
            switch(res){
            case .success(let rings):
                _self?.currentRing = rings.first
                _self?.download3DModel()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func download3DModel(){
        guard let ring = currentRing else{return}
        loadingView = ringView.showLoadingView()
        NetworkManager.shared.downloadRingModelUrl(ringID: String(ring.id), ringPth: ring.modelFull, completed: updateScence(res:))
        upperView.update(companyName: ring.company?.name)
        infoView.updateRingInfo(ringName: ring.name, ringPrice: ring.price)
    }
    
    private func updateScence(res:Result<URL, networkError>){
        guard let ring = currentRing else{return}
        
        
        NetworkManager.shared.downloadRingModelUrl(ringID: String(ring.id), ringPth: ring.modelUpperHalf,ringCut: .upper ,completed: {_ in })
        
        
        NetworkManager.shared.downloadRingModelUrl(ringID: String(ring.id), ringPth: ring.modelLowerHalf,ringCut: .loawer   , completed: {_ in})
        weak var _self = self
        DispatchQueue.main.async {
            self.loadingView?.removeFromSuperview()
            switch(res){
            case .success(let url):
                _self?.configureScene(url: url)
            case .failure(let error):
                print(error)
            }
        }

    }
    
    private func configureScene(url:URL) {
        do{
        ringScene = try SCNScene(url: url, options: nil)
        ringScene.wantsScreenSpaceReflection = true
        ringView.scene = ringScene
        ringView.isPlaying = true
        ringScene.rootNode.scale = .init(0.5, 0.5, 0.5)
        }catch{
            print("can not load Ring from local url")
        }
    }
    
    private func configureCamera(){
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 5)
        ringScene.rootNode.addChildNode(cameraNode)
        ringView.pointOfView = cameraNode
    }
    
    @objc func buyButtonTapped(){
        guard let ring = currentRing else {return}
        if let url = URL(string: ring.link) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc func tryOnTapped(){
        self.performSegue(withIdentifier: segues.showCameraSegue, sender: self)
    }
    
    
    
    private func configureNotificationHandler(){
        NotificationCenter.default.addObserver(self, selector: #selector(ringUpdated(_:)), name: .ringUpdated, object: nil)
    }
    
    private func removeNotificationHandler(){
        NotificationCenter.default.removeObserver(self, name: .ringUpdated, object: nil)
    }
    
    @objc func ringUpdated(_ notification: Notification){
        getRingFromDB()
    }
    
    
}






class RIngViewUpperView: UIView {
    let hSTack = UIStackView()
    let menuButton = UIButton()
    let companyName = UILabel()
    
    let searchButton = UIButton()
    let bottomView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLyout()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLyout(){
        menuButton.imageView?.tintColor = .systemGray2
        menuButton.setImage(Images.MenuImage, for: [])
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        menuButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        companyName.textColor = .label.withAlphaComponent(0.8)
        companyName.text = "YOUR BRAND NAME"
        companyName.textAlignment = .center
        companyName.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        
        hSTack.addArrangedSubview(menuButton)
        hSTack.addArrangedSubview(companyName)
        hSTack.addArrangedSubview(searchButton)
        
        hSTack.axis = .horizontal
        hSTack.distribution = .fillProportionally
        hSTack.translatesAutoresizingMaskIntoConstraints = false
        
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.backgroundColor = .systemGray4
        
        //
        let padding:CGFloat = 10
        addSubview(bottomView)
        NSLayoutConstraint.activate([
            bottomView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 3),
        ])
        
        addSubview(hSTack)
        NSLayoutConstraint.activate([
            hSTack.leadingAnchor.constraint(equalTo: leadingAnchor, constant:padding ),
            hSTack.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            hSTack.bottomAnchor.constraint(equalTo: bottomView.topAnchor),
            hSTack.widthAnchor.constraint(equalTo: widthAnchor),
        ])
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func update(companyName:String?){
        self.companyName.text = companyName ?? "YOUR BRAND NAME"
    }
    
}


import UIKit


class RingInfoView: UIView {
    let vStack = UIStackView()
    
    let nameLebel = UILabel ()
    let priceLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLyout()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLyout(){
        nameLebel.text = ""
        nameLebel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        nameLebel.textColor = .gray
        nameLebel.textAlignment = .center
        priceLabel.text = "$ "
        priceLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        priceLabel.textColor = .systemGray3
        priceLabel.textAlignment = .center
        addSubview(vStack)
        vStack.pinToSuperViewEdgesWithPadding(in: self, padding: 0)
        vStack.axis = .vertical
        vStack.distribution = .fillProportionally
        vStack.addArrangedSubview(nameLebel)
        vStack.addArrangedSubview(priceLabel)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    func updateRingInfo(ringName:String,ringPrice:Double){
        nameLebel.text = ringName
        priceLabel.text = "$ \(String(ringPrice))"
    }
    
}

