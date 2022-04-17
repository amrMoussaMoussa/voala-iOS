//
//  ViewController.swift
//  VoalaAPPClip
//
//  Created by Amr Moussa on 25/10/2021.
//
import UIKit
import AVFoundation
import Vision
protocol imageCapturedProtocl{
    func imageCaptured()
    func imagePreiviewCanceled()
}

class CameraViewController: UIViewController, imageCapturedProtocl ,AVCapturePhotoCaptureDelegate{
    
    

    private var cameraView: CameraView { view as! CameraView }
    
    private let videoDataOutputQueue = DispatchQueue(label: "CameraFeedDataOutput", qos: .userInteractive)
    private var cameraFeedSession: AVCaptureSession?
    private let photoOutput = AVCapturePhotoOutput()
    private var handPoseRequest = VNDetectHumanHandPoseRequest()
    
    private let drawPath = UIBezierPath()
    private var evidenceBuffer = [HandGestureProcessor.PointsPair]()
    private var lastDrawPoint: CGPoint?
    private var isFirstSegment = true
    private var lastObservationTimestamp = Date()
    
    private var gestureProcessor = HandGestureProcessor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // This sample app detects one hand only.
        cameraView.parent = self
        
        
        handPoseRequest.maximumHandCount = 1
        
        // Add state change handler to hand gesture processor.
        gestureProcessor.didChangeStateClosure = { [weak self] in
            self?.handleGestureStateChange(/*state: state*/)
        }
        configureCaptureImage()
    }
    
    func configureCaptureImage(){
        cameraView.imageCaptureDelegate = self
        photoOutput.accessibilityFrame = view.frame
    }
    
    func imageCaptured() {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func imagePreiviewCanceled(){
        cameraFeedSession?.startRunning()
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else {
            cameraFeedSession?.stopRunning()
            return
            
        }
        let previewImage = UIImage(data: imageData)
        let ringImage = cameraView.ringView.takeScreenshot()
        let HandImage = previewImage
        let ringViewFrame = cameraView.ringView.bounds
        let ringViewcenterPOint = ScreenShotHandler.shared.getMiddleRingMidle(img: previewImage)
        let ringOrientationAngel = cameraView.getZAngel()
        cameraView.previewImage.addImage(ringImage: ringImage, handImage: HandImage, frame: ringViewFrame, centerPoint: ringViewcenterPOint, angel: ringOrientationAngel)
        cameraFeedSession?.stopRunning()
    }

            
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        do {
            if cameraFeedSession == nil {
                cameraView.previewLayer.videoGravity = .resizeAspectFill
                try setupAVSession()
                cameraView.previewLayer.session = cameraFeedSession
            }
            cameraFeedSession?.startRunning()
        } catch {
            AppError.display(error, inViewController: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        cameraFeedSession?.stopRunning()
        super.viewWillDisappear(animated)
    }
    
  
    
    func setupAVSession() throws {
        // Select a front facing camera, make an input.
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            throw AppError.captureSessionSetup(reason: "Could not find a front facing camera.")
        }
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            throw AppError.captureSessionSetup(reason: "Could not create video device input.")
        }
        
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.high
        
        // Add a video input.
        guard session.canAddInput(deviceInput) else {
            throw AppError.captureSessionSetup(reason: "Could not add video device input to the session")
        }
        session.addInput(deviceInput)
        
        let dataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(dataOutput) {
            session.addOutput(dataOutput)
            // Add a video data output.
            dataOutput.alwaysDiscardsLateVideoFrames = true
            dataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            dataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            throw AppError.captureSessionSetup(reason: "Could not add video data output to the session")
        }
        
        
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        } else {
            throw AppError.captureSessionSetup(reason: "Could not add photo output to the session")
        }
        
        session.commitConfiguration()
        cameraFeedSession = session
}
    
    func processPoints(ringPip: CGPoint?, ringMcp: CGPoint?,littleMcp:CGPoint?,midlleMcp:CGPoint?,indexMcp:CGPoint?,wrist:CGPoint?) {
        // Check that we have both points.
        guard let ringPip = ringPip, let ringMcp = ringMcp ,let middleMcp = midlleMcp , let wrist = wrist else {
            // If there were no observations for more than 2 seconds reset gesture processor.
            if Date().timeIntervalSince(lastObservationTimestamp) > 2 {
                gestureProcessor.reset()
            }
            cameraView.showPoints([], midPOint: .zero, helperPOints: [],middleMcp: .zero ,wrist: wrist, color: .clear)
            return
        }
        let previewLayer = cameraView.previewLayer
       
        var littleMcpConverted:CGPoint?
        var indexMcpConverted:CGPoint?
        
        if let litlleMcpPOint = littleMcp{
        littleMcpConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: litlleMcpPOint )
        }
        
        if let indexMcpPOint = indexMcp{
            indexMcpConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: indexMcpPOint )
        }
        // Convert points from AVFoundation coordinates to UIKit coordinates.
       
        let ringPipPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: ringPip)
        let ringMcpPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: ringMcp)
      
        let middleMcpPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: middleMcp)
        let wristPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: wrist)
        // Process new points
        gestureProcessor.processPointsPair((ringPipPointConverted, ringMcpPointConverted), helperPOints: (littleMcpConverted,indexMcpConverted),middleMcpPoint: middleMcpPointConverted,wrist:wristPointConverted)
    }
    
    private func handleGestureStateChange(/*state: HandGestureProcessor.State*/) {
        let pointsPair = gestureProcessor.lastProcessedPointsPair
        let midPoint = gestureProcessor.ringPoint
        let helperPOints = gestureProcessor.lastHelperPOints
        let wrist  = gestureProcessor.wristPoint
        let middleMcp = gestureProcessor.middleMcp
        let tipsColor: UIColor = .white

        cameraView.showPoints([pointsPair.ringPip, pointsPair.ringMcp], midPOint: midPoint, helperPOints: [helperPOints.indexMcp,helperPOints.littleMcp], middleMcp:middleMcp,wrist: wrist,color: tipsColor)
    }
    
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        var pipPOint: CGPoint?
        var mcpPoint: CGPoint?
        var middleMcp:CGPoint?
        
        var littleMcp:CGPoint?
        var indexMcp:CGPoint?
        
        var wrist:CGPoint?
        
        defer {
            DispatchQueue.main.sync {
                self.processPoints(ringPip: pipPOint, ringMcp: mcpPoint,littleMcp: littleMcp,midlleMcp: middleMcp, indexMcp: indexMcp,wrist:wrist)
            }
        }
        

        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        do {
            // Perform VNDetectHumanHandPoseRequest
            try handler.perform([handPoseRequest])
            // Continue only when a hand was detected in the frame.
            // Since we set the maximumHandCount property of the request to 1, there will be at most one observation.
            guard let observation = handPoseRequest.results?.first else {
                return
            }
       
//            let ringPoints = try observation.recognizedPoints(.ringFinger)
    
//            let littleFinger = try observation.recognizedPoints(.littleFinger)
//            let middleFinger = try observation.recognizedPoints(.middleFinger)
//            let indexFinger = try observation.recognizedPoints(.indexFinger)
            let wristPOint = try observation.recognizedPoints(.all)
            
            // Look for tip points.
            guard let pipPointsRaw = wristPOint[.ringPIP], let mcpPointRaw = wristPOint[.ringMCP],let wristRaw = wristPOint[.wrist] else {
                return
            }
            
            guard  let middleMcpPointRaw = wristPOint[.middleMCP] else {
                return
            }
             
            if  let littleMcpPointsRaw = wristPOint[.littleMCP],littleMcpPointsRaw.confidence > 0.3{
                littleMcp = CGPoint(x: littleMcpPointsRaw.location.x , y: 1 - littleMcpPointsRaw.location.y)
            }
            
            if let indexMcpPointRaw = wristPOint[.indexMCP],indexMcpPointRaw.confidence > 0.3 {
                indexMcp = CGPoint(x: indexMcpPointRaw.location.x , y: 1 - indexMcpPointRaw.location.y)
            }
            
            
            // Ignore low confidence points.
            guard pipPointsRaw.confidence > 0.3 && mcpPointRaw.confidence > 0.3  && middleMcpPointRaw.confidence > 0.3 && wristRaw.confidence > 0.3 else {
                return
            }
            // Convert points from Vision coordinates to AVFoundation coordinates.
            pipPOint = CGPoint(x: pipPointsRaw.location.x, y: 1 - pipPointsRaw.location.y)
            mcpPoint = CGPoint(x: mcpPointRaw.location.x, y: 1 - mcpPointRaw.location.y)
            middleMcp = CGPoint(x: middleMcpPointRaw.location.x, y: 1 - middleMcpPointRaw.location.y)
            wrist = CGPoint(x: wristRaw.location.x, y: 1 - wristRaw.location.y)
        } catch {
            cameraFeedSession?.stopRunning()
            let error = AppError.visionError(error: error)
            DispatchQueue.main.async {
                error.displayInViewController(self)
            }
        }
    }
}



