import UIKit
import CoreLocation

internal protocol RotateGestureHandlerProtocol: FocusableGestureHandlerProtocol {
    var simultaneousRotateAndPinchZoomEnabled: Bool { get set }
}

 /// `RotateGestureHandler` updates the map camera in response to 2-touch rotate gestures
 internal final class RotateGestureHandler: GestureHandler, RotateGestureHandlerProtocol {
     internal var simultaneousRotateAndPinchZoomEnabled: Bool = true
     internal var focalPoint: CGPoint?

     private let mapboxMap: MapboxMapProtocol

     private var initialBearing: CLLocationDirection?
     private var isMapRotating = false
     private var discardedRotationAngle: CGFloat = 0

     internal init(gestureRecognizer: UIRotationGestureRecognizer, mapboxMap: MapboxMapProtocol) {
         self.mapboxMap = mapboxMap
         super.init(gestureRecognizer: gestureRecognizer)
         gestureRecognizer.delegate = self
         gestureRecognizer.addTarget(self, action: #selector(handleGesture(_:)))
     }

     @objc private func handleGesture(_ gestureRecognizer: UIRotationGestureRecognizer) {
         guard let view = gestureRecognizer.view else {
             return
         }
         switch (gestureRecognizer.state, isMapRotating) {
         case (.began, _):
             discardedRotationAngle += abs(gestureRecognizer.rotation)
             gestureRecognizer.rotation = 0
             self.initialBearing = mapboxMap.cameraState.bearing
         case (.changed, false):
             guard shouldStartRotating(with: gestureRecognizer.velocity, deltaSinceStart: discardedRotationAngle + abs(gestureRecognizer.rotation)) else {
                 discardedRotationAngle += abs(gestureRecognizer.rotation)
                 gestureRecognizer.rotation = 0
                 return
             }

             isMapRotating = true
             // pretend to be pinch gesture for backwards compatibility
             delegate?.gestureBegan(for: .pinch)
             fallthrough
         case (.changed, true):
             guard let initialBearing = initialBearing else {
                 return
             }
             let rotationInDegrees = CLLocationDirection(gestureRecognizer.rotation.toDegrees() * -1)
             let midpoint = gestureRecognizer.location(in: view)

             mapboxMap.setCamera(
                 to: CameraOptions(
                    anchor: focalPoint ?? midpoint,
                    bearing: (initialBearing + rotationInDegrees).truncatingRemainder(dividingBy: 360.0))
             )
         case (.cancelled, _), (.ended, _):
             if isMapRotating {
                 delegate?.gestureEnded(for: .pinch, willAnimate: false)
             }
             isMapRotating = false
             discardedRotationAngle = 0
         default:
             break
         }
     }

     private func shouldStartRotating(with velocity: CGFloat, deltaSinceStart: CGFloat) -> Bool {
         let deltaSinceStartInDegrees = deltaSinceStart.toDegrees()
         let velocityInDegreesPerMillisecond = abs(velocity) * 0.057295779513082

         let lowVelocity = velocityInDegreesPerMillisecond < 0.04 ||
         velocityInDegreesPerMillisecond > 0.07 && deltaSinceStartInDegrees < 5 ||
         velocityInDegreesPerMillisecond > 0.15 && deltaSinceStartInDegrees < 7 ||
         velocityInDegreesPerMillisecond > 0.5 && deltaSinceStartInDegrees < 15
         let notEnoughRotation = deltaSinceStartInDegrees < 3

         return !lowVelocity && !notEnoughRotation
     }
 }

extension RotateGestureHandler: UIGestureRecognizerDelegate {
    internal func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                    shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.gestureRecognizer === gestureRecognizer &&
        otherGestureRecognizer is UIPinchGestureRecognizer &&
        simultaneousRotateAndPinchZoomEnabled
    }
}