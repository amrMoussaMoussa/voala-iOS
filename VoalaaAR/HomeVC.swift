//
//  HomeVC.swift
//  Voala
//
//  Created by Amr Moussa on 28/11/2021.
//

import UIKit

class HomeVC: UIViewController,
              UICollectionViewDelegate, UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout{
    
    var cellSize:CGSize!
    var items:[Ring] = []
    
    var AMCollectionView:UICollectionView!
    var layout = UICollectionViewFlowLayout()
    
    let upperView = RIngViewUpperView()
    var loadingView:UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        getRings()
    }
    
    
    func configureView(){
        overrideUserInterfaceStyle = .light
        upperView.translatesAutoresizingMaskIntoConstraints = false
        
        AMCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        AMCollectionView.register(HomeRingCell.self, forCellWithReuseIdentifier:HomeRingCell.cellID)
        AMCollectionView.delegate = self
        AMCollectionView.dataSource = self
        AMCollectionView.translatesAutoresizingMaskIntoConstraints = false
        AMCollectionView.showsVerticalScrollIndicator  = false

        
        let safeArea = view.safeAreaLayoutGuide
        view.addSubViews(upperView,AMCollectionView)
        NSLayoutConstraint.activate([
            upperView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            upperView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            upperView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            upperView.heightAnchor.constraint(equalToConstant: 60),
            
            AMCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: .padding),
            AMCollectionView.topAnchor.constraint(equalTo: upperView.bottomAnchor, constant: .padding),
            AMCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: .npadding),
            AMCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: .npadding),
        ])
    
    }
    
    
    func UpadateItem(items:[Ring]){
        self.items = items
        self.upperView.update(companyName: items.first?.company?.name ?? "Voala")
        self.AMCollectionView.reloadData()
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = AMCollectionView.dequeueReusableCell(withReuseIdentifier: HomeRingCell.cellID, for: indexPath) as! HomeRingCell
        cell.setRing(ring: items[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ring = items[indexPath.row]
        NetworkManager.shared.ringID = String(ring.id)
        NetworkManager.shared.currentRing = ring
        performSegue(withIdentifier: segues.HometoRingVC, sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = AMCollectionView.frame.size.width - 20
        return CGSize(width: width/2, height: 250)
    }
    
    private func getRings(){
        guard let ringID = NetworkManager.shared.ringID else{return}
        loadingView = view.showLoadingView()
        NetworkManager.shared.getRing(ringID: ringID, completed: viewRings(res:))
    }
    
    private func viewRings(res:Result<[Ring], networkError>){
        weak var _self =  self
        DispatchQueue.main.async {
            _self?.loadingView?.removeFromSuperview()
            switch(res){
            case .success(let rings):
                _self?.UpadateItem(items: rings)
            case .failure(let error):
                print(error)
            }
            
        }
    }
    
    
}






class HomeRingCell:UICollectionViewCell{
    static let cellID = "HomeRingCell"
    
    
    
    let ringImage = UIImageView()
    let ringName = UILabel()
    let ringPrice = UILabel()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(){
        contentView.RoundCorners()
        contentView.AddStroke(color: .systemGray6)
        addSubViews(ringImage,ringName,ringPrice)
        
        ringName.translatesAutoresizingMaskIntoConstraints = false
        ringName.textAlignment = .center
        ringName.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        ringName.textColor = .black
        ringName.numberOfLines = 2

        ringPrice.translatesAutoresizingMaskIntoConstraints = false
        ringPrice.textAlignment = .center
        ringPrice.textColor = .systemGray4
        
        ringImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            ringPrice.leadingAnchor.constraint(equalTo: leadingAnchor),
            ringPrice.bottomAnchor.constraint(equalTo: bottomAnchor),
            ringPrice.trailingAnchor.constraint(equalTo: trailingAnchor),
            ringPrice.heightAnchor.constraint(equalToConstant: 40),
            
            ringName.leadingAnchor.constraint(equalTo: leadingAnchor),
            ringName.bottomAnchor.constraint(equalTo: ringPrice.topAnchor),
            ringName.trailingAnchor.constraint(equalTo: trailingAnchor),
            ringName.heightAnchor.constraint(equalToConstant: 50),
    
            ringImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            ringImage.topAnchor.constraint(equalTo: topAnchor),
            ringImage.trailingAnchor.constraint(equalTo: trailingAnchor),
            ringImage.bottomAnchor.constraint(equalTo:ringName.topAnchor,constant: .npadding),
        ])
    }
    
    func setRing(ring:Ring){
        ringImage.downloadImage(fromURL: ring.topDownPerspective ?? "")
        DispatchQueue.main.async {
            self.ringName.text = ring.name
            self.ringPrice.text = "€ \(String(ring.price))"
        }
    }
    
}
