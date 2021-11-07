/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This class is a state machine that transitions between states based on pair
    of points stream. These points are the tips for thumb and index finger.
    If the tips are closer than the desired distance, the state is "pinched", otherwise it's "apart".
    There are also "possiblePinch" and "possibeApart" states that are used to smooth out state transitions.
    During these possible states HandGestureProcessor collects the required amount of evidence before committing to a definite state.
*/

import CoreGraphics
import UIKit

class HandGestureProcessor {

    typealias PointsPair = (ringPip: CGPoint, ringMcp: CGPoint)
    typealias helperPair = (littleMcp: CGPoint?, indexMcp: CGPoint?)
    
    
    var didChangeStateClosure: (() -> Void)?
    private (set) var lastProcessedPointsPair = PointsPair(.zero, .zero)
    private (set) var lastHelperPOints = helperPair(.zero,.zero)
    private (set) var middleMcp:CGPoint = .zero
    private (set) var ringPoint:CGPoint = .zero
    private (set) var wristPoint:CGPoint = .zero

    func reset() {

    }
    
    func processPointsPair(_ pointsPair: PointsPair,helperPOints:helperPair,middleMcpPoint:CGPoint,wrist:CGPoint) {
        lastProcessedPointsPair = pointsPair
//        let distance = pointsPair.ringPip.distance(from: pointsPair.ringMcp)
        ringPoint = CGPoint.midPoint(p1: pointsPair.ringPip, p2: pointsPair.ringMcp)
        lastHelperPOints = helperPOints
        wristPoint = wrist
        middleMcp = middleMcpPoint
        
        didChangeStateClosure?()

    }
}

// MARK: - CGPoint helpers

extension CGPoint {

    static func midPoint(p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
    }
    
    func distance(from point: CGPoint) -> CGFloat {
        return hypot(point.x - x, point.y - y)
    }
}


enum AppError: Error {
    case captureSessionSetup(reason: String)
    case visionError(error: Error)
    case otherError(error: Error)
    
    static func display(_ error: Error, inViewController viewController: UIViewController) {
        if let appError = error as? AppError {
            appError.displayInViewController(viewController)
        } else {
            AppError.otherError(error: error).displayInViewController(viewController)
        }
    }
    
    func displayInViewController(_ viewController: UIViewController) {
        let title: String?
        let message: String?
        switch self {
        case .captureSessionSetup(let reason):
            title = "AVSession Setup Error"
            message = reason
        case .visionError(let error):
            title = "Vision Error"
            message = error.localizedDescription
        case .otherError(let error):
            title = "Error"
            message = error.localizedDescription
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        viewController.present(alert, animated: true, completion: nil)
    }
}
