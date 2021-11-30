//
//  screenShotHandler.swift
//  Voala 
//
//  Created by Amr Moussa on 23/11/2021.
//

import UIKit
import Vision


class ScreenShotHandler{
    
    static let shared = ScreenShotHandler()
    private var handPoseRequest = VNDetectHumanHandPoseRequest()
    
    private init(){}
    
    func getMiddleRingMidle(img:UIImage?)->CGPoint{
        guard let cgImage = img?.cgImage else {
            return .zero
        }
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .right, options: [:])
        do {
            // Perform VNDetectHumanHandPoseRequest
            try handler.perform([handPoseRequest])
            // Continue only when a hand was detected in the frame.
            // Since we set the maximumHandCount property of the request to 1, there will be at most one observation.
            guard let observation = handPoseRequest.results?.first else {
                return .zero
            }
            
            
            let allPoints = try observation.recognizedPoints(.all)
            
            // Look for tip points.
            guard let pipPointsRaw = allPoints[.ringPIP], let mcpPointRaw = allPoints[.ringMCP] else {
                return .zero
            }
            
            // Ignore low confidence points.
            guard pipPointsRaw.confidence > 0.3 && mcpPointRaw.confidence > 0.3 else {
                return .zero
            }
            // Convert points from Vision coordinates to AVFoundation coordinates.
            let pipPOint = CGPoint(x: pipPointsRaw.location.x, y: 1 - pipPointsRaw.location.y)
            let  mcpPoint = CGPoint(x: mcpPointRaw.location.x, y: 1 - mcpPointRaw.location.y)
            let midPoint = CGPoint.midPoint(p1: pipPOint, p2: mcpPoint)
            return midPoint
        } catch {
            let error = AppError.visionError(error: error)
            print(error)
        }
        return .zero
    }
}



