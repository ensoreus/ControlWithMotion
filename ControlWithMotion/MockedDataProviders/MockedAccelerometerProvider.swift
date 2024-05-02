//
//  MockedAccelerometerProvider.swift
//  ControlWithMotion
//
//  Created by Philipp Maluta on 02.05.2024.
//

import Foundation

import CoreMotion
import AVFoundation

enum MockedAccelerometer {
    case steady
    case shaking

    func generator(subscriber: AccelerometerSubscriber) {
        switch self {
        case .shaking:
            subscriber.shaked()
        case .steady:
            break
        }
    }
}

final class MockedAccelerometerProvider: AccelerometerProtocol {
    private var isCaptured = false
    weak var subscriber: PedometerSubscriber?
    var mockedPedometer = MockedPedometer.steady

    func startAccelerometerMotionCapture(with: AccelerometerSubscriber) {
        DispatchQueue.main.async { [weak self] in
            guard ((self?.isCaptured) != nil) else { return }
            guard let subscriber = self?.subscriber else { return }
            self?.mockedPedometer.generator(subscriber: subscriber)
        }
    }

    func stopAccelerometerMotionCapture() {
        isCaptured = false
    }
}
