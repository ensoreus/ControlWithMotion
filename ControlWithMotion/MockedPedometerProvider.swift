//
//  MockedPedometerProvider.swift
//  ControlWithMotion
//
//  Created by Philipp Maluta on 02.05.2024.
//

import Foundation
import CoreMotion
import AVFoundation

enum MockedPedometer {
    case steady
    case walk(distance: Int)

    func generator(subscriber: PedometerSubscriber) {
        switch self {
        case .walk(let distance):
            subscriber.movedAround(meters: distance)
        case .steady:
            break
        }
    }
}

final class MockedPedometerProvider: PedometerProtocol {

    weak var subscriber: PedometerSubscriber?
    private var timer: Timer?
    var mockedPedometer = MockedPedometer.steady

    func startPedometerCapture(with subscriber: PedometerSubscriber) {
        timer = Timer(timeInterval: 1.0, repeats: true) { [weak self] timer in
            self?.mockedPedometer.generator(subscriber: subscriber)
        }
    }

    func stopPedometerCapture() {
        timer?.invalidate()
        timer = nil
    }
}
