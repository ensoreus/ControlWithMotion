//
//  PedometerProvider.swift
//  ControlWithMotion
//
//  Created by Philipp Maluta on 01.05.2024.
//

import CoreMotion
import Foundation

protocol PedometerSubscriber: AnyObject {
    func movedAround(meters: Int)
}

protocol PedometerProtocol {
    func startPedometerCapture(with subscriber: PedometerSubscriber)
    func stopPedometerCapture()
}

final class PedometerProvider: PedometerProtocol {

    private var pedometer: CMPedometer?
    weak var pedometerSubscriber: PedometerSubscriber?

    init() {
        pedometer = CMPedometer()
        if CMPedometer.authorizationStatus() != .authorized {
            // Just to ack for permission. No other way to do it fancy
            pedometer?.queryPedometerData(from: .now, to: .now, withHandler: { _, _ in })
        }
    }

    func startPedometerCapture(with subscriber: PedometerSubscriber) {
        pedometerSubscriber = subscriber
        pedometer?.startUpdates(from: .now, withHandler: { [weak self] data, error in
            guard let data = data else { return }
            guard let distance = data.distance else { return }
            self?.pedometerSubscriber?.movedAround(meters: Int(truncating: distance))
        })
    }
    
    func stopPedometerCapture() {
        pedometer?.stopUpdates()
    }

}
