//
//  MockedGyroProvider.swift
//  ControlWithMotion
//
//  Created by Philipp Maluta on 30.04.2024.
//

import Foundation
import CoreMotion
import AVFoundation

enum MockedGyro {
    case steady
    case tiltingZ
    case tiltingX

    func generator(subscriber: GyroSubscriber) {
        switch self {
        case .tiltingX:
            subscriber.volume(change: 0.1)
        case .tiltingZ:
            subscriber.forward(time: CMTime(value: CMTimeValue(0.1), timescale: 1))
        case .steady:
            break
        }
    }
    func interval() -> TimeInterval {
        switch self {
        case .tiltingX:
            return 0.2
        case .tiltingZ:
            return 0.2
        case .steady:
            return 0.0
        }
    }
}

final class MockedGyroProvider: GyroProviderProtocol {

    weak var subscriber: GyroSubscriber?
    private var timer: Timer?
    var mockedGyro = MockedGyro.steady

    func startGyroMotionCapture(with subscriber: GyroSubscriber) {
        timer = Timer(timeInterval: mockedGyro.interval(), repeats: true) { [weak self] timer in
            self?.mockedGyro.generator(subscriber: subscriber)
        }
    }
    
    func stopGyroMotionCapture() {
        timer?.invalidate()
        timer = nil
    }
}
