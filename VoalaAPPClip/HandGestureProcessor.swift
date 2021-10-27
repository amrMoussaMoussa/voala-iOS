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
//    enum State {
//        case possiblePinch
//        case pinched
//        case possibleApart
//        case apart
//        case unknown
//    }
    
    typealias PointsPair = (ringPip: CGPoint, ringMcp: CGPoint)
    typealias helperPair = (littleMcp: CGPoint, middleMcp: CGPoint)
    
//    private var state = State.unknown {
//        didSet {
//            didChangeStateClosure?(state)
//        }
//    }
//    private var pinchEvidenceCounter = 0
//    private var apartEvidenceCounter = 0
//    private let pinchMaxDistance: CGFloat
//    private let evidenceCounterStateTrigger: Int
    
    var didChangeStateClosure: (() -> Void)?
    private (set) var lastProcessedPointsPair = PointsPair(.zero, .zero)
    private (set) var lastHelperPOints = helperPair(.zero,.zero)
    private (set) var midPOint:CGPoint = .zero
    private (set) var wristPoint:CGPoint = .zero
    init(pinchMaxDistance: CGFloat = 40, evidenceCounterStateTrigger: Int = 3) {
//        self.pinchMaxDistance = pinchMaxDistance
//        self.evidenceCounterStateTrigger = evidenceCounterStateTrigger
    }
    
    func reset() {
//        state = .unknown
//        pinchEvidenceCounter = 0
//        apartEvidenceCounter = 0
    }
    
    func processPointsPair(_ pointsPair: PointsPair,helperPOints:helperPair,wrist:CGPoint) {
        lastProcessedPointsPair = pointsPair
//        let distance = pointsPair.ringPip.distance(from: pointsPair.ringMcp)
        midPOint = CGPoint.midPoint(p1: pointsPair.ringPip, p2: pointsPair.ringMcp)
        lastHelperPOints = helperPOints
        wristPoint = wrist
        didChangeStateClosure?()
//        if distance < pinchMaxDistance {
//            // Keep accumulating evidence for pinch state.
//            pinchEvidenceCounter += 1
//            apartEvidenceCounter = 0
//            // Set new state based on evidence amount.
//            state = (pinchEvidenceCounter >= evidenceCounterStateTrigger) ? .pinched : .possiblePinch
//        } else {
//            // Keep accumulating evidence for apart state.
//            apartEvidenceCounter += 1
//            pinchEvidenceCounter = 0
//            // Set new state based on evidence amount.
//            state = (apartEvidenceCounter >= evidenceCounterStateTrigger) ? .apart : .possibleApart
//        }
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
