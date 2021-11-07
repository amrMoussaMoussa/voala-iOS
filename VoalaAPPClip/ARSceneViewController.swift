//
//  ARSceneViewController.swift
//  VoalaaAR
//
//  Created by Amr Moussa on 29/10/2021.
//

import UIKit
import ARKit
import Vision


class ARSceneViewController: UIViewController, ARSCNViewDelegate  {
    private var sceneView: ARsceneView { view as! ARsceneView }
    private var handPoseRequest = VNDetectHumanHandPoseRequest()
    
    private var lastObservationTimestamp = Date()
    private var gestureProcessor = HandGestureProcessor()
    
    private var viewportSize: CGSize!
    
    override var shouldAutorotate: Bool { return false }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        
        viewportSize = sceneView.frame.size
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = []
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        var pipPOint: CGPoint?
        var mcpPoint: CGPoint?
        var littleMcp:CGPoint?
        var middleMcp:CGPoint?
        var wrist:CGPoint?
        // Get the capture image (which is a cvPixelBuffer) from the current ARFrame
        guard let capturedImage = sceneView.session.currentFrame?.capturedImage else { return }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: capturedImage,
                                            orientation: .leftMirrored,options: [:])
        
        defer {
            DispatchQueue.main.sync {
                self.processPoints(ringPip: pipPOint, ringMcp: mcpPoint,littleMcp: littleMcp,midlleMcp: middleMcp,wrist:wrist)
            }
        }
        
        
        
        do {
            // Perform VNDetectHumanHandPoseRequest
            try handler.perform([handPoseRequest])
            // Continue only when a hand was detected in the frame.
            // Since we set the maximumHandCount property of the request to 1, there will be at most one observation.
            guard let observation = handPoseRequest.results?.first else {
                return
            }
            ////
            
            // Get points for thumb and index finger.
            
            
            let ringPoints = try observation.recognizedPoints(.ringFinger)
            
            
            
            // get helper points
            // little finger.
            let littleFinger = try observation.recognizedPoints(.littleFinger)
            let middleFinger = try observation.recognizedPoints(.middleFinger)
            let wristPOint = try observation.recognizedPoints(.all)
            
            // Look for tip points.
            guard let pipPointsRaw = ringPoints[.ringPIP], let mcpPointRaw = ringPoints[.ringMCP],let wristRaw = wristPOint[.wrist] else {
                return
            }
            
            guard let littleMcpPointsRaw = littleFinger[.littleMCP], let middleMcpPointRaw = middleFinger[.middleMCP] else {
                return
            }
            
            // Ignore low confidence points.
            guard pipPointsRaw.confidence > 0.3 && mcpPointRaw.confidence > 0.3 && littleMcpPointsRaw.confidence > 0.3 && middleMcpPointRaw.confidence > 0.3 && wristRaw.confidence > 0.3 else {
                return
            }
            // Convert points from Vision coordinates to AVFoundation coordinates.
            pipPOint = CGPoint(x: pipPointsRaw.location.x, y: 1 - pipPointsRaw.location.y)
            mcpPoint = CGPoint(x: mcpPointRaw.location.x, y: 1 - mcpPointRaw.location.y)
            littleMcp = CGPoint(x: littleMcpPointsRaw.location.x, y: 1 - littleMcpPointsRaw.location.y)
            middleMcp = CGPoint(x: middleMcpPointRaw.location.x, y: 1 - middleMcpPointRaw.location.y)
            wrist = CGPoint(x: wristRaw.location.x, y: 1 - wristRaw.location.y)
            
        } catch {
            print("Failed to perform image request.")
        }
        
    }
    
    func processPoints(ringPip: CGPoint?, ringMcp: CGPoint?,littleMcp:CGPoint?,midlleMcp:CGPoint?,wrist:CGPoint?) {
        // Check that we have both points.
        guard let ringPip = ringPip, let ringMcp = ringMcp ,let littleMcp = littleMcp ,let middleMcp = midlleMcp , let wrist = wrist else {
            // If there were no observations for more than 2 seconds reset gesture processor.
            if Date().timeIntervalSince(lastObservationTimestamp) > 2 {
                gestureProcessor.reset()
            }
//            cameraView.showPoints([], midPOint: .zero, helperPOints: [], wrist: wrist, color: .clear)
            print("no observations")
            return
        }
        
        // Convert points from AVFoundation coordinates to UIKit coordinates.
//        let previewLayer = cameraView.previewLayer
//        let previewLayer  = sceneView.layer
//        let ringPipPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: ringPip)
//        let ringMcpPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: ringMcp)
//        let littleMcpPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: littleMcp)
//        let middleMcpPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: middleMcp)
//        let wristPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: wrist)
        // Process new points
//        gestureProcessor.processPointsPair((ringPipPointConverted, ringMcpPointConverted), helperPOints: (littleMcpPointConverted,middleMcpPointConverted),wrist:wristPointConverted)
        
        print(ringMcp,ringMcp,ringPip,wrist)
    }
    
    
    
}
