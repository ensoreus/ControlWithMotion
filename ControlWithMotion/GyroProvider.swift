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
    private var lastHorizontalFriction: Float = 0.0
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
            guard let horizRotation = gyroData?.rotationRate.x else { return }
            let volumeShift = self.rotationToVolume(gyroRotation: vertRotation)
            self.gyroSubscriber?.volume(change: volumeShift)
            let positionShift = self.rotationToTime(gyroRotation: horizRotation)
            guard CMTimeGetSeconds(positionShift) > 0 else { return }

            if horizRotation > 0.5 {
                self.gyroSubscriber?.forward(time: positionShift)
            } else if horizRotation < -0.5 {
                self.gyroSubscriber?.back(time: positionShift)
            }
        }
    }

    func stopGyroMotionCapture() {
        motionManager?.stopGyroUpdates()
    }

    private func rotationToVolume(gyroRotation: Double) -> Float {
       roundf(Float(gyroRotation) * 10.0) / 100.0
    }

    private func rotationToTime(gyroRotation: Double) -> CMTime {
        let friction = Float(abs(gyroRotation))
        lastHorizontalFriction *= 0.1 // fade the lastHorizontalFriction away to add some resistance

        // Ensure that fresh friction higher than lastHorizontalFriction
        if lastHorizontalFriction < friction {
            let scaled = roundf(Float(friction) * 10.0) / 10.0
            let timeToSeek = CMTimeMake(value: Int64(scaled), timescale: 1)
            lastHorizontalFriction = friction
            return timeToSeek
        } else {
            return CMTimeMake(value: 0, timescale: 1)
        }






    }
}
