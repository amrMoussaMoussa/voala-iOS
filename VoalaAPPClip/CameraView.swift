/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The camera view shows the feed from the camera, and renders the points
     returned from VNDetectHumanHandpose observations.
*/

import UIKit
import AVFoundation

enum handType {
    case right
    case left
}

enum HandDirection{
    case up
    case back
}
class CameraView: UIView {

    private var overlayLayer = CAShapeLayer()
    private var pointsPath = UIBezierPath()
    private let imageView = UIImageView()
    
    private var handDirection:HandDirection?
    private var handType:handType?
    private var imageAngel:CGFloat = 0
    
//    private var isRecentlyChangeHands:Bool = true
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }

    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupOverlay()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupOverlay()
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        if layer == previewLayer {
            overlayLayer.frame = layer.bounds
        }
    }

    private func setupOverlay() {
        previewLayer.addSublayer(overlayLayer)
        addSubview(imageView)
        imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    }
    
    func showPoints(_ points: [CGPoint],midPOint:CGPoint,helperPOints:[CGPoint],wrist:CGPoint? ,color: UIColor) {
        pointsPath.removeAllPoints()
        let ringWidth = (helperPOints.first?.distance(from: helperPOints.last ?? .zero) ?? .zero)/2
//        imageView.frame = CGRect(x: 0, y: 0, width: ringWidth, height: ringWidth)
        imageView.bounds = .init(x: 0, y: 0, width: ringWidth , height: ringWidth )
        let ringRightPOistion = CGPoint.midPoint(p1:points.last ?? .zero, p2: points.first ?? .zero)
        
        if  handType == nil{ handType = getHandType(wrist:wrist, ringMcp: points.last )}
        
        handDirection = getHandDirection(middleMcp: helperPOints.last, little: helperPOints.first)
        getAngleRelateiveToXAxis(ringmcpPOint: points.first, ringPiPPoint: points.last)
        UpdateImageView(middlePOint: midPOint, helperPoints: helperPOints,ringPOint: ringRightPOistion)
        for point in points {
            pointsPath.move(to: point)
            pointsPath.addArc(withCenter: point, radius: 5, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        }
        
        for point in helperPOints {
            pointsPath.move(to: point)
            pointsPath.addArc(withCenter: point, radius: 5, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        }
        
        pointsPath.move(to: midPOint)
        pointsPath.addArc(withCenter: midPOint, radius: 5, startAngle: 0, endAngle: .pi, clockwise: true)
        
        pointsPath.move(to: wrist ?? .zero)
        pointsPath.addArc(withCenter: wrist ?? .zero, radius: 5, startAngle: 0, endAngle: .pi, clockwise: true)
        
        overlayLayer.fillColor = color.cgColor
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        overlayLayer.path = pointsPath.cgPath
        CATransaction.commit()
    }
    
    func getHandDirection(middleMcp:CGPoint?,little:CGPoint?) -> HandDirection? {
        guard let middleMcp = middleMcp , let littleMcp = little,let handType = handType else{
            return nil
        }
        
        if handType == .right {
            return littleMcp.x > middleMcp.x  ? .up:.back
        }else  {
            return littleMcp.x < middleMcp.x  ? .up:.back
        }
    }
    func UpdateImageView(middlePOint:CGPoint,helperPoints:[CGPoint],ringPOint:CGPoint){
        guard helperPoints.count != 0 else {
            imageView.image = nil
            handType = nil
            handDirection = nil
            return
        }
        guard handType  != nil &&   handDirection != nil else {
            return
        }
        
        imageView.image = handDirection == .up ?  Images.ringUpImage : Images.ringBackImage
        
        imageView.transform =  CGAffineTransform(rotationAngle: imageAngel)
        imageView.contentMode = handDirection == .up ? .scaleAspectFit:.scaleAspectFit
        imageView.center =  CGPoint(x: ringPOint.x, y: ringPOint.y)
        
        
    }
    
    func getHandType(wrist:CGPoint? , ringMcp:CGPoint?)-> handType?{
        
        guard let wrist = wrist,let ringMcp = ringMcp  else {
            return nil
        }
       
        if wrist.x > ringMcp.x {
            print("right")
            return .right
        }else{
            print("left")
            return .left
        }
        
        
    }
    
    func getAngleRelateiveToXAxis(ringmcpPOint:CGPoint?,ringPiPPoint:CGPoint?){
        guard let mcp = ringmcpPOint , let piP = ringPiPPoint else {
            return
        }
        
        imageAngel = atan2((mcp.y - piP.y), (mcp.x - piP.x)) + (CGFloat.pi / 2)
        print(imageAngel)
//        let degree = -(imageAngel*CGFloat(180)) / CGFloat(Double.pi)
//        print(degree)
    }
    
 
}
