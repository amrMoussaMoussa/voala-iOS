//
//  RingOptionsView.swift
//  VoalaaAR
//
//  Created by Amr Moussa on 08/11/2021.
//

import UIKit

protocol optionRingSelectedProtocol{
    func optionRingSelected(ring:Ring)
}

class RingOptionsView: UIView, UICollectionViewDelegate, UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout {
    
    var items:[Ring] = []
    var ringsCV:UICollectionView!
    var layout = UICollectionViewFlowLayout()
    
    var lastSelectedIndex:Int = 0
    var opptionRingSelected:optionRingSelectedProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLyout()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLyout(){
        backgroundColor = .clear
        layout.scrollDirection = .horizontal
        ringsCV = UICollectionView(frame: bounds, collectionViewLayout: layout)
        ringsCV.register(RingCell.self, forCellWithReuseIdentifier:RingCell.cellID)
        ringsCV.delegate = self
        ringsCV.dataSource = self
        addSubview(ringsCV)
        ringsCV.pinToSuperViewEdgesWithPadding(in: self, padding: 0)
        ringsCV.backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setRigns(rings:[Ring]){
        items = rings
        DispatchQueue.main.async {
            self.ringsCV.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = ringsCV.dequeueReusableCell(withReuseIdentifier: RingCell.cellID, for: indexPath) as! RingCell
        cell.setRing(ring: items[indexPath.row], image: Images.ring2)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let lastCell = ringsCV.cellForItem(at: .init(row: lastSelectedIndex, section: 0)) as! RingCell
        lastCell.setNotselected()
        
        let cell = ringsCV.cellForItem(at: indexPath) as! RingCell
        cell.setAsSelected()
        opptionRingSelected?.optionRingSelected(ring: items[indexPath.row])
        lastSelectedIndex = indexPath.row
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
    
    
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let CVSize = ringsCV.frame.size
        return CGSize(width: CVSize.height, height: CVSize.height)
    }
    
    
}


class RingCell:UICollectionViewCell{
    
    static let cellID = "RingCell"
    
    let ringImage = UIImageView()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure(){
        backgroundColor = .clear
        addSubview(ringImage)
        ringImage.backgroundColor = .clear
        ringImage.pinToSuperViewEdgesWithPadding(in: self, padding: 0)
    }
    
    func setRing(ring:Ring?,image:UIImage?){
        guard let ring = ring  else{return}
        ringImage.downloadImage(fromURL: ring.topDownPerspective!)
    }
    
    func setAsSelected(){
        backgroundColor = .white.withAlphaComponent(0.4)
    }
    
    func setNotselected(){
        backgroundColor = .clear
    }
    
    
}



struct Ring:Codable{
    let id:Int
    let name:String
    let productGroupId:Int
    let topDownPerspective:String?
    let bottomUpPerspective:String?
    let sidePerspective:String?
    let modelFull:String
    let modelUpperHalf:String
    let modelLowerHalf:String
    let price:Double
    let link:String
    let companyId:Int
    let company:Company?
}


struct Company:Codable{
    let id:Int
    let name:String
    let rings:[Ring]
}
