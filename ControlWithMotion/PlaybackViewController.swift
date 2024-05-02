//
//  ViewController.swift
//  ControlWithMotion
//
//  Created by Philipp Maluta on 30.04.2024.
//

import UIKit
import AVFoundation

class PlaybackViewController: UIViewController{
    private enum Constants {
        static let tolerance = CMTimeMake(value: 1, timescale: 3)
        static let playStartPosition = CMTime(seconds: 0.0, preferredTimescale: 1)
        static let defaultVolume: Float = 0.5
        static let distanceToPause: Int = 10
        static let timeShiftSecondsThresholdToAffect: Double = 1.0
    }

    private var player = AVPlayer(playerItem: Factory.production.playerItem())
    private let gyroProvider = Factory.production.gyroProvider()
    private let pedometerProvider = Factory.production.pedometerProvider()

    var volume: Float = Constants.defaultVolume {
        didSet {
            player.volume = volume
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayer()
        gyroProvider.startGyroMotionCapture(with: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startPlayback()
    }

    private func startPlayback() {
        player.play()
        pedometerProvider.startPedometerCapture(with: self)
    }

    private func pausePlayback() {
        player.pause()
        pedometerProvider.stopPedometerCapture()
    }

    private func setupPlayer() {
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        view.layer.addSublayer(playerLayer)
    }

    private func backToBegin() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        player.seek(to: Constants.playStartPosition,
                    toleranceBefore: Constants.tolerance,
                    toleranceAfter: Constants.tolerance)
    }
}

extension PlaybackViewController: GyroSubscriber {

    private func seekBy(_ timeOffset: CMTime) {
        if CMTimeGetSeconds(timeOffset) > Constants.timeShiftSecondsThresholdToAffect {
                player.seek(to: timeOffset,
                            toleranceBefore: Constants.tolerance,
                            toleranceAfter: Constants.tolerance)
            }
    }
    
    func back(time: CMTime) {
        let timeNow = player.currentTime()
        let timeOffset = CMTimeSubtract(timeNow, time)
        seekBy(timeOffset)
    }

    func forward(time: CMTime){
        let timeNow = player.currentTime()
        let timeOffset = CMTimeAdd(timeNow, time)
        seekBy(timeOffset)
    }

    func volume(change on: Float){
        volume += on
    }

}

extension PlaybackViewController: PedometerSubscriber {
    func movedAround(meters: Int) {
        if meters >= Constants.distanceToPause {
            DispatchQueue.main.async { [weak self] in
                self?.pausePlayback()
            }
        }
    }
}
