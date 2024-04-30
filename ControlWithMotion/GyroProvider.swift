//
//  GyroProvider.swift
//  ControlWithMotion
//
//  Created by Philipp Maluta on 30.04.2024.
//

import Foundation
import AVFoundation
import CoreMotion

protocol AccelerometerSubscriber: AnyObject {
    func shaked()
}

protocol PedometerSubscriber: AnyObject {
    func movedAround(meters: Int)
}

protocol GyroSubscriber: AnyObject {
    func back(time: CMTime)
    func forward(time: CMTime)
    func volume(change on: Float)
}

protocol GyroMotionTrackerProtocol {
    func startGyroMotionCapture(with subscriber: GyroSubscriber)
    func stopGyroMotionCapture()
}

protocol AccelerometerTrackerProtocol {
    func startAccelerometerMotionCapture(with: AccelerometerSubscriber)
    func stopAccelerometerMotionCapture()
}

protocol GyroProviderProtocol: GyroMotionTrackerProtocol { }

final class GyroProvider: GyroProviderProtocol {
    
    private var motionManager: CMMotionManager?
    weak var gyroSubscriber: GyroSubscriber?
    weak var accelerometerSubscriber: AccelerometerSubscriber?
    weak var pedometerSubscriber: PedometerSubscriber?

    init?() {
        motionManager = CMMotionManager()
        guard ((motionManager?.isGyroAvailable) != nil) else { return nil }
    }

    func startGyroMotionCapture(with subscriber: GyroSubscriber) {
        gyroSubscriber = subscriber
        motionManager?.gyroUpdateInterval = 0.1
        motionManager?.startGyroUpdates(to: OperationQueue.main) { (gyroData: CMGyroData?, NSError)->Void in
            guard let vertRotation = gyroData?.rotationRate.y else { return }
            let value = self.rotationTo(volume: vertRotation)
            self.gyroSubscriber?.volume(change: value)
        }
    }

    func stopGyroMotionCapture() {
        motionManager?.stopGyroUpdates()
    }

    private func rotationTo(volume: Double) -> Float {
        return roundf(Float(volume) * 10.0) / 100.0
    }

}
