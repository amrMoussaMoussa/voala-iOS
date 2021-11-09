/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 The camera view shows the feed from the camera, and renders the points
 returned from VNDetectHumanHandpose observations.
 */

import UIKit
import AVFoundation
import SceneKit


enum handType {
    case right
    case left
}

enum HandDirection{
    case up
    case back
}

class CameraView: UIView, SCNSceneRendererDelegate, optionRingSelectedProtocol{
  
    
    
    private var overlayLayer = CAShapeLayer()
    private var pointsPath = UIBezierPath()
    private var  linePath = UIBezierPath()
    private let imageView = UIImageView()
    
    private var handDirection:HandDirection?
    private var handType:handType?
    private var isPreviewing:Bool = false
    
    
    
    private var xAngel:Int = 90
    private var yAngel:Int = 0
    private var zAngel:CGFloat = 0
    
    var  ringView:SCNView!
    var  ringScene:SCNScene!
    var cameraNode:SCNNode!
    
    var imageCaptureDelegate:imageCapturedProtocl?
    
    let previewImage = previewImageV()
    
    var scannigngView:ScainnigView?
    let ringInfoLabel = RingNameLabel()
    
    
    let ringOptionView = RingOptionsView()
    var currntRing:Ring?
    
    let screenShot = UIButton()
    
    let padding:CGFloat = 20
    
    
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupOverlay()
        configureView()
        configureScene()
        configureCamera()
        configurePreviewView()
//        createGeometry()
//        creatRing()
        rotateRing()
        setOPtionRings()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupOverlay()
        configureView()
        configureScene()
        configureCamera()
        configurePreviewView()
//        createGeometry()
//        creatRing()
        rotateRing()
        setOPtionRings()
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        if layer == previewLayer {
            overlayLayer.frame = layer.bounds
        }
    }
    
    private func  configureView(){
        ringView = SCNView()
        ringView.allowsCameraControl = true
        ringView.autoenablesDefaultLighting = true
        ringView.backgroundColor = .clear
        ringView.contentMode = .scaleAspectFill
        ringView.frame = .init(x: 100, y: 100, width: 0, height: 0)
        addSubview(ringView)
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
        cameraNode.position = SCNVector3(0, 0, 4)
        ringScene.rootNode.addChildNode(cameraNode)
        ringView.pointOfView = cameraNode
//        let camera = SCNCamera()
//        camera.zFar = 1
//        ringScene.rootNode.childNodes.first?.camera = camera
        
    }
    
    private func createGeometry(){
        let geo:SCNGeometry  = SCNCone(topRadius: 0.5, bottomRadius: 0.5, height: 1)
        geo.materials.first?.diffuse.contents = UIImage(named: "earthImage")
        let gemoetryNode = SCNNode(geometry: geo)
        ringScene.rootNode.addChildNode(gemoetryNode)
    }
    
    private func creatRing(){
        
//       ringScene = SCNScene(named: "Ring.obj")
    }
    
    private func rotateRing(){
//        ringScene.rootNode.childNodes.first?.runAction(SCNAction.rotateBy(x: xAngel.degreesToRadians(), y: 0.degreesToRadians() , z: 0.degreesToRadians(), duration: 0.0))
        
        ringScene.rootNode.childNodes.first?.runAction(SCNAction.rotateTo(x: xAngel.degreesToRadians(), y: yAngel.degreesToRadians(), z: 0, duration: 0))
//        ringScene.rootNode.childNodes.first?.rotation = .init(1, 0 ,0, xAngel.degreesToRadians())
//        ringScene.rootNode.childNodes.first?.rotation = .init(0, 0 , 1, zAngel.degreesToRadians())
        
        
    }
    
    private func setupOverlay() {
        previewLayer.addSublayer(overlayLayer)
        addSubview(imageView)
        imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        addSubview(ringInfoLabel)
        ringInfoLabel.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        ringInfoLabel.text = "Diamond Ring 100$"
        ringInfoLabel.isHidden = true
        screenShot.isHidden = true
        ringOptionView.isHidden = true
//        configureSCeneObject()
        
        screenShot.translatesAutoresizingMaskIntoConstraints = false
        addSubview(screenShot)
        NSLayoutConstraint.activate([
            screenShot.centerXAnchor.constraint(equalTo: centerXAnchor),
            screenShot.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30),
            screenShot.widthAnchor.constraint(equalToConstant: 75),
            screenShot.heightAnchor.constraint(equalTo: screenShot.widthAnchor)
        ])
        screenShot.setImage(UIImage(named: "btn"), for: [])
//        UIImageWriteToSavedPhotosAlbum(UIImage(named: "btn")!, nil, nil, nil)
        screenShot.imageView?.contentMode = .scaleAspectFit
        screenShot.addTarget(self, action: #selector(captureScreenshot), for: .touchUpInside)
        
        addSubview(ringOptionView)
        
        NSLayoutConstraint.activate([
            ringOptionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            ringOptionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            ringOptionView.bottomAnchor.constraint(equalTo: screenShot.topAnchor, constant: -10),
            ringOptionView.heightAnchor.constraint(equalToConstant: 100),
        ])
        ringOptionView.opptionRingSelected = self
        
    }
    
    func configureSCeneObject(){
        addSubview(ringView)
        ringView.frame =  CGRect(x: 100, y: 100, width: 100, height: 100)
        cameraNode = ringView.pointOfView
        //        sceneObject.frame =  frame
        ringView.delegate = self
        ringView.contentMode = .scaleAspectFit
        //
        //        sceneObject.showsStatistics = true
        //        sceneObject.debugOptions = .showWorldOrigin
        
        
        
        
////         2: Add camera node
        
       
//        cameraNode.camera?.zFar = 1000
//        cameraNode.camera?.zNear = 0
        // 3: Place camera

//        cameraNode?.position = SCNVector3(x: 0  , y: 0, z: 3.3)
//        // 4: Set camera on scene
//
        
        
        // 5: Adding light to scene
       
        
        // 6: Creating and adding ambien light to scene
//        let ambientLightNode = SCNNode()
//        ambientLightNode.light = SCNLight()
//        ambientLightNode.light?.type = .ambient
//        ambientLightNode.light?.color = UIColor.darkGray
//        scene?.rootNode.addChildNode(ambientLightNode)
        
        // If you don't want to fix manually the lights
        ringView.autoenablesDefaultLighting = true
        
        // Allow user to manipulate camera
        ringView.allowsCameraControl = true
        
        // Show FPS logs and timming
        // sceneView.showsStatistics = true
        
        // Set background color
        ringView.backgroundColor = UIColor.white
        
        // Allow user translate image
//        sceneObject.cameraControlConfiguration.allowsTranslation = false
        ringScene?.rootNode.childNodes.first?.rotation = .init(1, 0, 0, 90.degreesToRadians())
        
        // Set scene settings
        ringView.scene = ringScene
//        scene?.rootNode.position = .init(0, -1, 0)
//
//        scene?.rootNode.childNodes.first?.rotation = .init(1, 0, 0, 75.degreesToRadians())
        cameraNode = ringView.pointOfView
        cameraNode?.position = SCNVector3(x: 0  , y: 0, z: 3.3)
        ringScene?.rootNode.addChildNode(cameraNode!)

        
    }
    
    func showPoints(_ points: [CGPoint],midPOint:CGPoint,helperPOints:[CGPoint?],middleMcp:CGPoint,wrist:CGPoint?,color: UIColor) {
        pointsPath.removeAllPoints()
        guard isPreviewing == false else{
            pointsPath.removeAllPoints()
            return
        }
       
        let ringWidth = points.first?.distance(from: points.last ?? .zero) ?? .zero
        
//        let ringWidth = getRingWidth(helperPOints:helperPOints,ringMcp:points.last!)
        //        imageView.frame = CGRect(x: 0, y: 0, width: ringWidth, height: ringWidth)
        imageView.bounds = .init(x: 0, y: 0, width: ringWidth , height: ringWidth )
        ringView.bounds = .init(x: 0, y: 0, width: ringWidth*1.5 , height: ringWidth)
        
        
        
        let ringRightPOistion = CGPoint.midPoint(p1:points.last ?? .zero, p2: points.first ?? .zero)
        
        
        
         handType = getHandType(wrist:wrist, ringMcp: points.last )
        // Fallback on earlier versions
        
        handDirection = getHandDirection(middleMcp:middleMcp ,ringMcp: points.last, little: helperPOints.last  as? CGPoint)
//        handDirection == .up ? (cameraNode.position.z = 4):(cameraNode.position.z = 2)
        getAngleRelateiveToZAxis(ringmcpPOint: points.last, ringPiPPoint: points.first)
        getAngeRelativeToYAxis(points:points,helperPOints:helperPOints,middle:middleMcp)
        getAngelRelativeToXAxis()
        
        UpdateImageView(middlePOint: midPOint, points: points,ringPOint: ringRightPOistion)
        rotateRing()
        
//
//////
//        for point in points {
//            pointsPath.move(to: point)
//            pointsPath.addArc(withCenter: point, radius: 5, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
//        }
//
//        for point in helperPOints {
//            guard let pointt = point else{continue}
//            pointsPath.move(to: pointt)
//            pointsPath.addArc(withCenter: pointt, radius: 5, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
//        }
//
//        pointsPath.move(to: midPOint)
//        pointsPath.addArc(withCenter: midPOint, radius: 5, startAngle: 0, endAngle: .pi, clockwise: true)
//
//        pointsPath.move(to: wrist ?? .zero)
//        pointsPath.addArc(withCenter: wrist ?? .zero, radius: 5, startAngle: 0, endAngle: .pi, clockwise: true)
//
//        pointsPath.move(to: middleMcp)
//        pointsPath.addArc(withCenter: middleMcp, radius: 5, startAngle: 0, endAngle: .pi, clockwise: true)
        
        pointsPath.move(to: midPOint)
        pointsPath.addArc(withCenter: CGPoint(x: ringInfoLabel.center.x, y: ringInfoLabel.center.y + 20 ), radius: 2, startAngle: 0, endAngle: .pi, clockwise: true)
        
        
        overlayLayer.fillColor = color.cgColor
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        overlayLayer.path = pointsPath.cgPath
        CATransaction.commit()
    }
    
    func getRingWidth(){
        
    }
    
    func getHandDirection(middleMcp:CGPoint,ringMcp:CGPoint?,little:CGPoint?) -> HandDirection? {
        guard let ringMcp = ringMcp ,let handType = handType else{
            return nil
        }
        
      
        let handComparingPOint = ringMcp
        
        if handType == .right {
            return handComparingPOint.x > middleMcp.x  ? .up:.back
        }else  {
            return handComparingPOint.x < middleMcp.x  ? .up:.back
        }
    }
    func UpdateImageView(middlePOint:CGPoint,points:[CGPoint],ringPOint:CGPoint){
        guard points.count != 0 else {
            imageView.image = nil
            handType = nil
            handDirection = nil
            ringInfoLabel.isHidden  = true
            screenShot.isHidden = true
            ringOptionView.isHidden  = true
            addScnningView()
            return
        }
        
      
        
        guard handType  != nil &&   handDirection != nil else {
            return
        }
        
        
        
        scannigngView?.removeFromSuperview()
        scannigngView?.gifImageView?.animationImages = nil
        scannigngView = nil
        
        
        ringView.transform =  CGAffineTransform(rotationAngle: zAngel)
        ringView.center =  CGPoint(x: ringPOint.x , y: ringPOint.y )
        
        
        
        ringInfoLabel.center = CGPoint(x: ringPOint.x - 50 , y: ringPOint.y - 200 )
        ringInfoLabel.isHidden  = false
        screenShot.isHidden  = false
        ringOptionView.isHidden = false
        

    }
    
    func getHandType(wrist:CGPoint?, ringMcp:CGPoint?)-> handType?{
        
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
    
    func getAngelRelativeToXAxis(){
        guard let handDirect = handDirection else{return}
        print(handDirect)
        print(handType)
        switch handDirect {
        case .up:
            xAngel = 90
        case .back:
            xAngel = -90
        }
    }
    
    
    private func setOPtionRings(){
        NetworkManager.shared.getRing(ringID: "1") {[weak self] res in
            guard let self = self else {return}
            switch(res){
            case .success(let rings):
                #warning("to be change to current ring from DB Not option rings ")
                self.currntRing = rings.first
                self.ringOptionView.setRigns(rings: rings + rings)
            case .failure(let err):
                print(err)
            }
        }
    }
    
    func getAngleRelateiveToZAxis(ringmcpPOint:CGPoint?,ringPiPPoint:CGPoint?){
        guard let mcp = ringmcpPOint , let piP = ringPiPPoint else {
            return
        }
        
        zAngel = atan2((mcp.y - piP.y), (mcp.x - piP.x)) + (CGFloat.pi / 2)
    }
    
//ringmcpPOint: points.last, ringPiPPoint: points.first
    func getAngeRelativeToYAxis(points:[CGPoint],helperPOints:[CGPoint?],middle:CGPoint){
        guard let littleMcp = helperPOints.last  as? CGPoint ,let indexMcp =  helperPOints.first  as? CGPoint ,let ringMCp = points.last  else {return}
        
        // calculate the distane between little and ring
        let outterDistance = littleMcp.distance(from: ringMCp)
        let innerDistance  = indexMcp.distance(from: middle)
//        print(indexMcp,middle,ringMCp,littleMcp)
        
        // get larger side distance and calculate minimum distance
        let angeelRatio =  min(outterDistance,innerDistance)/max(outterDistance,innerDistance)
//        print(angeelRatio)
//        handType == .right ? (handDirection == .up ? -1:1):(handDirection == .up ? :)
        #warning("chango to lef and right hand oreintation")
        let angelDirection = getAngelDirection(innerDistance: innerDistance, outterDistance: outterDistance)
        print(angelDirection)
        yAngel = Int((1-angeelRatio)*45)*angelDirection
        print(yAngel)
        
    }
    
    func getAngelDirection(innerDistance:CGFloat,outterDistance:CGFloat)-> Int{
        guard let handDirection = handDirection , let handType = handType else { return 0 }
        switch(handType){
        case .right:
         let angel =    handDirection == .up ? (outterDistance < innerDistance ? -1:1):(outterDistance < innerDistance ? 1:-1)
            return angel
        case .left:
          let angel =   handDirection == .back ? (outterDistance < innerDistance ? -1:1):(outterDistance < innerDistance ? 1:-1)
            return angel
        }
    }
    
    func addScnningView(){
        guard scannigngView == nil else{return}
        let scaingView = ScainnigView()
        addSubview(scaingView)
        NSLayoutConstraint.activate([
            scaingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scaingView.topAnchor.constraint(equalTo: topAnchor),
            scaingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scaingView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        scannigngView = scaingView
    }
    
    
    
    @objc func captureScreenshot(){
        isPreviewing = true
        pointsPath.removeAllPoints()
        imageCaptureDelegate?.imageCaptured()
        ringInfoLabel.isHidden = true
        screenShot.isHidden = true
        overlayLayer.isHidden = true
        ringOptionView.isHidden = true
        previewImage.isHidden = false
        
        
     }
    
    func configurePreviewView(){
        addSubview(previewImage)
        previewImage.pinToSuperViewEdgesWithPadding(in: self, padding: 0 )
        previewImage.isHidden = true
        previewImage.exitButton.addTarget(self, action: #selector(previewExitTapped), for:.touchUpInside)
        previewImage.buyButton.addTarget(self, action: #selector(buyButtonTapped), for: .touchUpInside)
    }
    
    @objc func previewExitTapped(){
        isPreviewing = false
        overlayLayer.isHidden = false
        imageCaptureDelegate?.imagePreiviewCanceled()
    }
    
    @objc func buyButtonTapped(){
        guard let ring = currntRing else {return}
        if let url = URL(string: ring.link) {
            UIApplication.shared.open(url)
        }
    }
    
    
    func optionRingSelected(ring: Ring) {
        let newRing = SCNScene(named: "Ring.obj")
        ringScene = newRing
        ringView.scene = newRing
    }

}
extension Int {
    func degreesToRadians() -> CGFloat {
        return CGFloat(self) * CGFloat.pi / 180.0
    }
}


extension UIView {

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
