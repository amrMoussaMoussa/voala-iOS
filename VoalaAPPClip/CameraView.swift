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

class CameraView: UIView, SCNSceneRendererDelegate{
    private var overlayLayer = CAShapeLayer()
    private var pointsPath = UIBezierPath()
    private var  linePath = UIBezierPath()
    
    
    private var handDirection:HandDirection? {
        didSet{
            if oldValue != handDirection{
                let cut:ringCuts = handDirection == .up ? .upper:.loawer
                configureScene(cut: cut)
            }
        }
    }
    private var handType:handType?
    private var isPreviewing:Bool = false
    
    private var xAngel:Int = 90
    private var yAngel:Int = 0
    private var zAngel:CGFloat = 0
    private var ringCenterPoints:[CGPoint] = []
    var  ringView:SCNView!
    var  ringScene:SCNScene!
    var cameraNode:SCNNode!
    
    var parent:CameraViewController?
    var loadingView:UIView?
    
    var imageCaptureDelegate:imageCapturedProtocl?
    
    
    let cameraHeaderView = CameraHeaderView()
    let flashView  = FlashView()
    let previewImage = previewImageV()
    
    var scannigngView = ScainnigView()
    var currntRing:Ring?
    let screenShot = UIButton()
    let padding:CGFloat = 20
    
    let changeHandButton = ChangeHandView()
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupOverlay()
        addScnningView()
        configureView()
        configureScene()
        configurePreviewView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupOverlay()
        addScnningView()
        configureView()
        configureScene()
        configurePreviewView()
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
    
    private func configureScene(cut:ringCuts = .upper){
        guard let ring = NetworkManager.shared.currentRing else{return}
        ringScene?.rootNode.enumerateChildNodes({ node, stop in
            node.removeFromParentNode()
        })
        currntRing = ring
        previewImage.setRing(ring: ring)
        let path = cut == .upper ? ring.modelUpperHalf:ring.modelLowerHalf
        loadingView = showLoadingView()
        NetworkManager.shared.downloadRingModelUrl(ringID: String(ring.id), ringPth: path , ringCut: cut, completed: updateScene(res:))
    }
    
    private func updateScene(res:Result<URL, networkError>){
        let cut:ringCuts = handDirection == .up ? .upper:.loawer
        switch(res){
        case .success(let url):
            DispatchQueue.main.async {[weak self] in
                guard let self = self else {return}
                self.loadingView?.removeFromSuperview()
                do{self.ringScene = try SCNScene(url: url, options: nil)}catch{}
                self.ringScene.wantsScreenSpaceReflection = true
                let (min,max) = self.ringScene.rootNode.boundingBox
                let size = max-min
//                print(size)
                print("SCNVector3: \(size.length())")
                self.ringScene.rootNode.scale = cut == .loawer ? .init(0.8, 0.8, 0.8):.init(1.1, 1.1, 1.1)
                self.ringView.scene = self.ringScene
                self.ringView.isPlaying = true
                
            }
        case .failure(let err):
            print(err)
        }
    }
    
    private func configureCamera(){
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 6)
        ringScene.rootNode.addChildNode(cameraNode)
        ringView.pointOfView = cameraNode
    }
    
    private func createGeometry(){
        let geo:SCNGeometry  = SCNCone(topRadius: 0.5, bottomRadius: 0.5, height: 1)
        geo.materials.first?.diffuse.contents = UIImage(named: "earthImage")
        let gemoetryNode = SCNNode(geometry: geo)
        ringScene.rootNode.addChildNode(gemoetryNode)
    }
    
  
    
    private func rotateRing(){
//        ringScene.rootNode.childNodes.first?.runAction(SCNAction.rotateBy(x: xAngel.degreesToRadians(), y: 0.degreesToRadians() , z: 0.degreesToRadians(), duration: 0.0))

        ringScene.rootNode.childNodes.first?.runAction(SCNAction.rotateTo(x: xAngel.degreesToRadians(), y: yAngel.degreesToRadians(), z: 0, duration: 0))
//        ringScene.rootNode.childNodes.first?.rotation = .init(1, 0 ,0, xAngel.degreesToRadians())
//        ringScene.rootNode.childNodes.first?.rotation = .init(0, 0 , 1, zAngel.degreesToRadians())
        
        
    }
    
    private func setupOverlay() {
        previewLayer.addSublayer(overlayLayer)
        hideInfoVeiw()
        
        
        //        configureSCeneObject()
        screenShot.translatesAutoresizingMaskIntoConstraints = false
        let safeArea = safeAreaLayoutGuide
        addSubViews(screenShot,cameraHeaderView,flashView,changeHandButton)
        NSLayoutConstraint.activate([
            screenShot.centerXAnchor.constraint(equalTo: centerXAnchor),
            screenShot.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30),
            screenShot.widthAnchor.constraint(equalToConstant: 75),
            screenShot.heightAnchor.constraint(equalTo: screenShot.widthAnchor),
            
            
            cameraHeaderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cameraHeaderView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            cameraHeaderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cameraHeaderView.heightAnchor.constraint(equalToConstant: 50),
            
            flashView.leadingAnchor.constraint(equalTo: leadingAnchor,constant: .padding*2),
            flashView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor,constant: .npadding),
            flashView.widthAnchor.constraint(equalToConstant: 50),
            flashView.heightAnchor.constraint(equalToConstant: 50),
            
            changeHandButton.trailingAnchor.constraint(equalTo: trailingAnchor,constant: .npadding*2),
            changeHandButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor,constant: .npadding),
            changeHandButton.widthAnchor.constraint(equalToConstant: 70),
            changeHandButton.heightAnchor.constraint(equalToConstant: 100),
        ])
        bringSubviewToFront(changeHandButton)
        screenShot.setImage(UIImage(named: "btn"), for: [])
        screenShot.imageView?.contentMode = .scaleAspectFit
        screenShot.addTarget(self, action: #selector(captureScreenshot), for: .touchUpInside)
        cameraHeaderView.exitButton.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)
        scannigngView.exitButton.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)
        changeHandButton.changeLanguageButton.addTarget(self, action: #selector(changeLaguageTapped), for: .touchUpInside)
    }
    
    
    
    func showPoints(_ points: [CGPoint],midPOint:CGPoint,helperPOints:[CGPoint?],middleMcp:CGPoint,wrist:CGPoint?,color: UIColor) {
        pointsPath.removeAllPoints()
        guard isPreviewing == false else{
            pointsPath.removeAllPoints()
            return
        }
        guard ringScene != nil else{
            return
        }

        let ringRightPOistion = CGPoint.midPoint(p1:points.last ?? .zero, p2: points.first ?? .zero)
        
        let littleMcp = helperPOints.last ?? .zero
        let ringWidth = middleMcp.distance(from: littleMcp ?? .zero)
        let newRingWidth = ringWidth/1.75
        if abs(newRingWidth -  ringView.bounds.height) > 0.7 {
            ringView.bounds = .init(x: 0, y: 0, width: newRingWidth , height: newRingWidth)
        }
        
        handType = getHandType(wrist:wrist, ringMcp: points.last )
        handDirection = getHandDirection(middleMcp:middleMcp ,ringMcp: points.last, little: helperPOints.last  as? CGPoint)
        getAngleRelateiveToZAxis(ringmcpPOint: points.last, ringPiPPoint: points.first)
        getAngeRelativeToYAxis(points:points,helperPOints:helperPOints,middle:middleMcp)
        getAngelRelativeToXAxis()
        
        UpdateImageView(middlePOint: midPOint, points: points,ringPOint: ringRightPOistion)
        rotateRing()
  
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
//            handType = nil
            handDirection = nil
            hideInfoVeiw()
            scannigngView.isHidden = false
            return
        }
        
        guard handType  != nil &&   handDirection != nil else {
            return
        }
        scannigngView.isHidden = true
        ringView.transform =  CGAffineTransform(rotationAngle: zAngel)
        let newCenter =  CGPoint(x: ringPOint.x , y: ringPOint.y )
        
        if newCenter.distance(from: ringView.center) > 3 {
            if newCenter.distance(from: ringView.center) > 10 {
                ringCenterPoints = []
            }
            ringCenterPoints.append(newCenter)
            let m = ringCenterPoints.reduce(.zero, +) / CGFloat(ringCenterPoints.count)
            print("Distance:\(m.distance(from: ringView.center)) ,  Count:\(ringCenterPoints.count) ")
            print()
            ringView.center =  CGPoint(x: m.x , y: m.y )
            
        }
        showINfoView()
    }
    
    func getHandType(wrist:CGPoint?, ringMcp:CGPoint?)-> handType?{
        scannigngView.UpdateLabeltext(hand: changeHandButton.handOreiantaion)
        return changeHandButton.handOreiantaion
    }
    
    func getAngelRelativeToXAxis(){
        guard let handDirect = handDirection else{return}
        switch handDirect {
        case .up:
            xAngel = 90
        case .back:
            xAngel = -80
        }
    }
    
    private func getRing(){
        guard let ring  = NetworkManager.shared.currentRing else{return}
        NetworkManager.shared.downloadRingModelUrl(ringID:String(ring.id) , ringPth: ring.modelFull, completed: ringReceived(res:))
    }
    
    private func ringReceived(res:Result<URL, networkError>){
           switch(res){
           case .success(let url):
               print(url)
           case .failure(let error):
               print(error)
       }
    }
    
    
    
    func getAngleRelateiveToZAxis(ringmcpPOint:CGPoint?,ringPiPPoint:CGPoint?){
        guard let mcp = ringmcpPOint , let piP = ringPiPPoint else {
            return
        }
        zAngel = atan2((mcp.y - piP.y), (mcp.x - piP.x)) + (CGFloat.pi / 2)
    }
    

    func getAngeRelativeToYAxis(points:[CGPoint],helperPOints:[CGPoint?],middle:CGPoint){
        guard let littleMcp = helperPOints.last  as? CGPoint ,let indexMcp =  helperPOints.first  as? CGPoint ,let ringMCp = points.last  else {return}
        
        // calculate the distane between little and ring
        let outterDistance = littleMcp.distance(from: ringMCp)
        let innerDistance  = indexMcp.distance(from: middle)
        
        // get larger side distance and calculate minimum distance
        let angeelRatio =  min(outterDistance,innerDistance)/max(outterDistance,innerDistance)

        let angelDirection = getAngelDirection(innerDistance: innerDistance, outterDistance: outterDistance)
        yAngel = Int((1-angeelRatio)*45)*angelDirection
        
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
        addSubview(scannigngView)
        NSLayoutConstraint.activate([
            scannigngView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scannigngView.topAnchor.constraint(equalTo: topAnchor),
            scannigngView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scannigngView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        bringSubviewToFront(changeHandButton)
    }
    
    func hideInfoVeiw(){
        screenShot.isHidden = true
        cameraHeaderView.isHidden = true
        flashView.isHidden = true
    }
    
    func showINfoView(){
        screenShot.isHidden  = false
        cameraHeaderView.isHidden = false
        flashView.isHidden = false
    }
    
    
    @objc func captureScreenshot(){
        isPreviewing = true
        pointsPath.removeAllPoints()
        imageCaptureDelegate?.imageCaptured()
        screenShot.isHidden = true
        cameraHeaderView.isHidden = true
        flashView.isHidden = true
        overlayLayer.isHidden = true
        previewImage.isHidden = false
     }
    
    @objc func exitTapped(){
        parent?.dismiss(animated: true)
    }
    
    func configurePreviewView(){
        addSubview(previewImage)
        previewImage.pinToSuperViewEdges(in: self)
        previewImage.isHidden = true
        previewImage.upperVeiw.exitButton.addTarget(self, action: #selector(previewExitTapped), for:.touchUpInside)
        previewImage.upperVeiw.reopenButton.addTarget(self, action: #selector(previewExitTapped), for:.touchUpInside)
        previewImage.upperVeiw.downLoadButton.addTarget(self, action:  #selector(windowScreenshot), for:.touchUpInside)
        previewImage.shareButton.addTarget(self, action: #selector(windowScreenshot), for:.touchUpInside)
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
    
    @objc func changeLaguageTapped(){
      handType =  changeHandButton.flipHand()
      scannigngView.UpdateLabeltext(hand: handType!)
    }
    
    
   @objc  func windowScreenshot(){
       previewImage.hideForScreenShot()
        let layer = UIApplication.shared.keyWindow!.layer
        let scale = UIScreen.main.scale
        // Creates UIImage of same size as view
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        // THIS IS TO SAVE SCREENSHOT TO PHOTOS
        let items: [Any] = [screenshot!]
        let activityCotroller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        parent?.present(activityCotroller, animated: true)
       previewImage.reShowYour()
    }
    
    func getZAngel()->CGFloat{
        return zAngel
    }
    

}

extension Int {
    func degreesToRadians() -> CGFloat {
        return CGFloat(self) * CGFloat.pi / 180.0
    }
}



extension SCNVector3 {
    func length() -> Float {
        return sqrtf(x * x + y * y + z * z)
    }
}
func - (l: SCNVector3, r: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(l.x - r.x, l.y - r.y, l.z - r.z)
}


extension CGPoint {
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    static func /(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }
}
