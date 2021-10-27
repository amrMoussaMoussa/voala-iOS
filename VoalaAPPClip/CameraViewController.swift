//
//  ViewController.swift
//  VoalaAPPClip
//
//  Created by Amr Moussa on 25/10/2021.
//
import UIKit
import AVFoundation
import Vision

class CameraViewController: UIViewController {

    private var cameraView: CameraView { view as! CameraView }
    
    private let videoDataOutputQueue = DispatchQueue(label: "CameraFeedDataOutput", qos: .userInteractive)
    private var cameraFeedSession: AVCaptureSession?
    private var handPoseRequest = VNDetectHumanHandPoseRequest()
    
    private let drawOverlay = CAShapeLayer()
    private let drawPath = UIBezierPath()
    private var evidenceBuffer = [HandGestureProcessor.PointsPair]()
    private var lastDrawPoint: CGPoint?
    private var isFirstSegment = true
    private var lastObservationTimestamp = Date()
    
    private var gestureProcessor = HandGestureProcessor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawOverlay.frame = view.layer.bounds
        drawOverlay.lineWidth = 5
        drawOverlay.backgroundColor = #colorLiteral(red: 0.9999018312, green: 1, blue: 0.9998798966, alpha: 0.5).cgColor
        drawOverlay.strokeColor = #colorLiteral(red: 0.6, green: 0.1, blue: 0.3, alpha: 1).cgColor
        drawOverlay.fillColor = #colorLiteral(red: 0.9999018312, green: 1, blue: 0.9998798966, alpha: 0).cgColor
        drawOverlay.lineCap = .round
        view.layer.addSublayer(drawOverlay)
        // This sample app detects one hand only.
        handPoseRequest.maximumHandCount = 1
        // Add state change handler to hand gesture processor.
        gestureProcessor.didChangeStateClosure = { [weak self] in
            self?.handleGestureStateChange(/*state: state*/)
        }
        // Add double tap gesture recognizer for clearing the draw path.
//        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
//        recognizer.numberOfTouchesRequired = 1
//        recognizer.numberOfTapsRequired = 2
//        view.addGestureRecognizer(recognizer)
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
        session.commitConfiguration()
        cameraFeedSession = session
}
    
    func processPoints(ringPip: CGPoint?, ringMcp: CGPoint?,littleMcp:CGPoint?,midlleMcp:CGPoint?,wrist:CGPoint?) {
        // Check that we have both points.
        guard let ringPip = ringPip, let ringMcp = ringMcp ,let littleMcp = littleMcp ,let middleMcp = midlleMcp , let wrist = wrist else {
            // If there were no observations for more than 2 seconds reset gesture processor.
            if Date().timeIntervalSince(lastObservationTimestamp) > 2 {
                gestureProcessor.reset()
            }
            cameraView.showPoints([], midPOint: .zero, helperPOints: [], wrist: wrist, color: .clear)
            return
        }
        
        // Convert points from AVFoundation coordinates to UIKit coordinates.
        let previewLayer = cameraView.previewLayer
        let ringPipPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: ringPip)
        let ringMcpPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: ringMcp)
        let littleMcpPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: littleMcp)
        let middleMcpPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: middleMcp)
        let wristPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: wrist)
        // Process new points
        gestureProcessor.processPointsPair((ringPipPointConverted, ringMcpPointConverted), helperPOints: (littleMcpPointConverted,middleMcpPointConverted),wrist:wristPointConverted)
    }
    
    private func handleGestureStateChange(/*state: HandGestureProcessor.State*/) {
        let pointsPair = gestureProcessor.lastProcessedPointsPair
        let midPoint = gestureProcessor.midPOint
        let helperPOints = gestureProcessor.lastHelperPOints
        let wrist  = gestureProcessor.wristPoint
        let tipsColor: UIColor = .red
//        switch state {
//        case .possiblePinch, .possibleApart:
//            // We are in one of the "possible": states, meaning there is not enough evidence yet to determine
//            // if we want to draw or not. For now, collect points in the evidence buffer, so we can add them
//            // to a drawing path when required.
//            evidenceBuffer.append(pointsPair)
//            tipsColor = .orange
//        case .pinched:
//            // We have enough evidence to draw. Draw the points collected in the evidence buffer, if any.
//            for bufferedPoints in evidenceBuffer {
//                updatePath(with: bufferedPoints, isLastPointsPair: false)
//            }
//            // Clear the evidence buffer.
//            evidenceBuffer.removeAll()
//            // Finally, draw the current point.
//            updatePath(with: pointsPair, isLastPointsPair: false)
//            tipsColor = .green
//        case .apart, .unknown:
//            // We have enough evidence to not draw. Discard any evidence buffer points.
//            evidenceBuffer.removeAll()
//            // And draw the last segment of our draw path.
//            updatePath(with: pointsPair, isLastPointsPair: true)
//            tipsColor = .red
//        }
        cameraView.showPoints([pointsPair.ringPip, pointsPair.ringMcp], midPOint: midPoint, helperPOints: [helperPOints.littleMcp,helperPOints.middleMcp], wrist: wrist ,color: tipsColor)
    }
    
    private func updatePath(with points: HandGestureProcessor.PointsPair, isLastPointsPair: Bool) {
        // Get the mid point between the tips.
        let (thumbTip, indexTip) = points
        let drawPoint = CGPoint.midPoint(p1: thumbTip, p2: indexTip)

        if isLastPointsPair {
            if let lastPoint = lastDrawPoint {
                // Add a straight line from the last midpoint to the end of the stroke.
                drawPath.addLine(to: lastPoint)
            }
            // We are done drawing, so reset the last draw point.
            lastDrawPoint = nil
        } else {
            if lastDrawPoint == nil {
                // This is the beginning of the stroke.
                drawPath.move(to: drawPoint)
                isFirstSegment = true
            } else {
                let lastPoint = lastDrawPoint!
                // Get the midpoint between the last draw point and the new point.
                let midPoint = CGPoint.midPoint(p1: lastPoint, p2: drawPoint)
                if isFirstSegment {
                    // If it's the first segment of the stroke, draw a line to the midpoint.
                    drawPath.addLine(to: midPoint)
                    isFirstSegment = false
                } else {
                    // Otherwise, draw a curve to a midpoint using the last draw point as a control point.
                    drawPath.addQuadCurve(to: midPoint, controlPoint: lastPoint)
                }
            }
            // Remember the last draw point for the next update pass.
            lastDrawPoint = drawPoint
        }
        // Update the path on the overlay layer.
        drawOverlay.path = drawPath.cgPath
    }
    
    @IBAction func handleGesture(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else {
            return
        }
        evidenceBuffer.removeAll()
        drawPath.removeAllPoints()
        drawOverlay.path = drawPath.cgPath
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        var pipPOint: CGPoint?
        var mcpPoint: CGPoint?
        var littleMcp:CGPoint?
        var middleMcp:CGPoint?
        var wrist:CGPoint?
        
        defer {
            DispatchQueue.main.sync {
                self.processPoints(ringPip: pipPOint, ringMcp: mcpPoint,littleMcp: littleMcp,midlleMcp: middleMcp,wrist:wrist)
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
            cameraFeedSession?.stopRunning()
            let error = AppError.visionError(error: error)
            DispatchQueue.main.async {
                error.displayInViewController(self)
            }
        }
    }
}



