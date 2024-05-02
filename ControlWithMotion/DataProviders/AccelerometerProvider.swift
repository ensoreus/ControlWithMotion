//
//  AccelerometerProvider.swift
//  ControlWithMotion
//
//  Created by Philipp Maluta on 02.05.2024.
//

import Foundation
import CoreMotion

protocol AccelerometerSubscriber: AnyObject {
    func shaked()
}

protocol AccelerometerProtocol {
    func startAccelerometerMotionCapture(with subscriber: AccelerometerSubscriber)
    func stopAccelerometerMotionCapture()
}

final class AccelerometereProvider: AccelerometerProtocol {
    private enum Constants {
        static let motionUpdateInterval = 0.02
        static let accelerationMagnitudeToAffect = 2.0
    }

    private var motionManager: CMMotionManager
    weak var accelerometerSubscriber: AccelerometerSubscriber?

    init?() {
        guard let motionManager = Factory.production.motionManager() else { return nil }
        self.motionManager = motionManager
        guard motionManager.isAccelerometerAvailable else { return nil }
        motionManager.deviceMotionUpdateInterval = Constants.motionUpdateInterval
    }

    func startAccelerometerMotionCapture(with subscriber: AccelerometerSubscriber) {
        self.accelerometerSubscriber = subscriber
        motionManager.startAccelerometerUpdates(to: OperationQueue.main) { [weak self]
            (data, error) in
            guard let acceleration = data?.acceleration else { return }
            let totalAcceleration = sqrt(pow(acceleration.x, 2) + pow(acceleration.y, 2) + pow(acceleration.z, 2))

            if totalAcceleration >= Constants.accelerationMagnitudeToAffect {
                self?.accelerometerSubscriber?.shaked()
            }
        }
    }

    func stopAccelerometerMotionCapture() {
        motionManager.stopAccelerometerUpdates()
    }
}
