//
//  UIView+Ext.swift
//  Voala App Clip
//
//  Created by Amr Moussa on 22/11/2021.
//

import UIKit


 extension UIView {
    
    
    func addSubViews(_ views:UIView...){
        for view in views {addSubview(view)}
    }
    
    
    func pinToSuperViewEdges(in view:UIView){
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func pinToSuperViewSafeArea(in view:UIView){
        let safeArea = view.safeAreaLayoutGuide
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            topAnchor.constraint(equalTo: safeArea.topAnchor),
            trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
        
    }
    
    func pinToSuperViewEdgesWithPadding(in view:UIView,padding:CGFloat){
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: padding),
            topAnchor.constraint(equalTo: view.topAnchor,constant: padding),
            trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -padding),
            bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -padding)
        ])
    }
    
    func RoundCorners(){
        layer.cornerRadius = 10
        clipsToBounds = true
        layer.masksToBounds = true    
    }
    
    
    func AddStroke(color:UIColor,strokeWidth:CGFloat = 2){
       layer.borderWidth = strokeWidth
        layer.borderColor = color.cgColor
    }
     
    func changeStroke(color:UIColor){
        layer.borderColor = color.cgColor
    }
    
    func roundShape(){
        layer.cornerRadius = frame.width / 2
        clipsToBounds = true
        layer.masksToBounds = true
    }
    
    func roundShapeWithHeight(){
        layer.cornerRadius = frame.height / 2
        clipsToBounds = true
        layer.masksToBounds = true
    }
    
    func showLoadingView() -> UIView {
        let containerView = UIView(frame: bounds)
        addSubview(containerView)
        
        containerView.backgroundColor = .systemBackground
        containerView.alpha = 0
        containerView.pinToSuperViewEdges(in: self)
        UIView.animate(withDuration: 0.25) { containerView.alpha = 0.8 }
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        containerView.addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        activityIndicator.startAnimating()
        return containerView
    }
    
    func showImageLoadingLoadingView(color:UIColor) -> UIView {
        let containerView = UIView(frame: bounds)
        addSubview(containerView)
        
        containerView.backgroundColor = .clear
        containerView.alpha = 0
        
        containerView.pinToSuperViewEdges(in: self)
        
        
        UIView.animate(withDuration: 0.25) { containerView.alpha = 0.8 }
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        containerView.addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = color
        
       
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        
        
        activityIndicator.startAnimating()
        return containerView
    }

   
    

    
    func anchorWithPadding(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, trailing: NSLayoutXAxisAnchor?, padding: UIEdgeInsets = .zero, size: CGSize = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }
        
        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
        }
        
        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }

    
    @objc func handleErrorAlert(){
        let view = subviews.last
        view?.removeFromSuperview()
    }
    
    func addShadow(){
        
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        layer.shadowRadius = 10
        layer.masksToBounds = false
    }
    
    func onTapDissmisKeyboard(VC:UIViewController){
        let tap = UITapGestureRecognizer(target: VC, action: #selector(UIInputViewController.dismissKeyboard))
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        
        addGestureRecognizer(tap)
    }
    
    func removeAllSubViews(){
        subviews.forEach {
            $0.removeFromSuperview()
        }
    }
     
     func takeScreenshot() -> UIImage {

         // Begin context
         UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)

         // Draw view in that context
         drawHierarchy(in: self.bounds, afterScreenUpdates: true)

         // And finally, get image
         let image = UIGraphicsGetImageFromCurrentImageContext()
         UIGraphicsEndImageContext()

         if (image != nil)
         {
             return image!
         }
         return UIImage()
     }
}
