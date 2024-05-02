//
//  Factory.swift
//  ControlWithMotion
//
//  Created by Philipp Maluta on 30.04.2024.
//

import Foundation

import CoreMotion
import AVFoundation

enum Factory {
    enum Environment {
        case unittesting
        case production

        var baseUrl: String {
            switch self {
            case .unittesting:
                return Bundle.path(forResource: videoPath, ofType: "mp4", inDirectory:"")!

            case .production:
                return "http://commondatastorage.googleapis.com"

            }
        }

        private var videoPath: String {
            switch self {
            case .production:
                "/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4"
            case .unittesting:
                "WeAreGoingOnBullrun"
            }
        }

        var videoUrl: URL {
            let path = self == .production ? baseUrl + videoPath : baseUrl
            guard let url = URL(string: path) else {
                fatalError("Check out the video URL correctness")
            }
            return url
        }
    }

    case production
    case unittesting

    func gyroProvider() -> GyroProviderProtocol {
        switch self {
        case .production:
            guard let gprovider = GyroProvider() else { fatalError("Gyro not found on this device")}
            return gprovider
        case .unittesting:
            return MockedGyroProvider()
        }
    }

    func pedometerProvider() -> PedometerProtocol {
        switch self {
        case .production:
            return PedometerProvider()
        case .unittesting:
            return MockedPedometerProvider()
        }
    }

    func playerItem() -> AVPlayerItem {
        switch self {
        case .production:
            return AVPlayerItem(url: Environment.production.videoUrl)
        case .unittesting:
            return AVPlayerItem(url: Environment.unittesting.videoUrl)
        }
    }
}
