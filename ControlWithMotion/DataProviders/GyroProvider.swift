//
//  GyroProvider.swift
//  ControlWithMotion
//
//  Created by Philipp Maluta on 30.04.2024.
//

import Foundation
import AVFoundation
import CoreMotion

protocol GyroSubscriber: AnyObject {
    func back(time: CMTime)
    func forward(time: CMTime)
    func volume(change on: Float)
}

protocol GyroProviderProtocol {
    func startGyroMotionCapture(with subscriber: GyroSubscriber)
    func stopGyroMotionCapture()
}


final class GyroProvider: GyroProviderProtocol {
    private enum Constants {
        static let gyroUpdateInterval = 0.1
        static let positiveGyroThreshold = 0.5
        static let negativeGyroThreshold = -0.5
        static let volumeSensibilityNominator: Float = 10.0
        static let volumeSensibilityDenominator: Float = 100.0
        static let playbackSensibilityNominator: Float = 10
        static let playbackSensibilityDenominator: Float = 10
        static let horizontalFrictionAttenuator: Float = 0.1
        static let zeroTimeShift = CMTimeMake(value: 0, timescale: 1)
    }
    
    private var lastHorizontalFriction: Float = 0.0
    private var motionManager: CMMotionManager?

    weak var gyroSubscriber: GyroSubscriber?

    init?() {
        guard let motionManager = Factory.production.motionManager() else { return nil }
        self.motionManager = motionManager
        guard motionManager.isGyroAvailable else { return nil }
    }

    func startGyroMotionCapture(with subscriber: GyroSubscriber) {
        gyroSubscriber = subscriber
        motionManager?.gyroUpdateInterval = Constants.gyroUpdateInterval
        motionManager?.startGyroUpdates(to: OperationQueue.main) { (gyroData: CMGyroData?, NSError)->Void in
            guard let vertRotation = gyroData?.rotationRate.y else { return }
            guard let horizRotation = gyroData?.rotationRate.x else { return }
            let volumeShift = self.rotationToVolume(gyroRotation: vertRotation)
            self.gyroSubscriber?.volume(change: volumeShift)
            let positionShift = self.rotationToTime(gyroRotation: horizRotation)
            guard CMTimeGetSeconds(positionShift) > 0 else { return }

            if horizRotation > Constants.positiveGyroThreshold {
                self.gyroSubscriber?.forward(time: positionShift)
            } else if horizRotation < Constants.negativeGyroThreshold {
                self.gyroSubscriber?.back(time: positionShift)
            }
        }
    }

    func stopGyroMotionCapture() {
        motionManager?.stopGyroUpdates()
    }

    private func rotationToVolume(gyroRotation: Double) -> Float {
       roundf(Float(gyroRotation) * Constants.volumeSensibilityNominator) / Constants.volumeSensibilityDenominator
    }

    private func rotationToTime(gyroRotation: Double) -> CMTime {
        let friction = Float(abs(gyroRotation))
        // fade the lastHorizontalFriction away to add some resistance
        lastHorizontalFriction *= Constants.horizontalFrictionAttenuator

        // Ensure that fresh friction higher than lastHorizontalFriction
        if lastHorizontalFriction < friction {
            let scaled = roundf(Float(friction) * Constants.playbackSensibilityNominator) / Constants.playbackSensibilityDenominator
            let timeToSeek = CMTimeMake(value: Int64(scaled), timescale: 1)
            lastHorizontalFriction = friction
            return timeToSeek
        } else {
            return Constants.zeroTimeShift
        }
    }
}
