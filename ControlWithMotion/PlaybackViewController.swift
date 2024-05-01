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
    }

    private var player = AVPlayer(playerItem: Factory.production.playerItem())
    private let gyroProvider = Factory.production.gyroProvider()

    var volume: Float = 0.5 {
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
        player.play()
    }

    fileprivate func setupPlayer() {
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

    fileprivate func seekBy(_ timeOffset: CMTime) {
            if CMTimeGetSeconds(timeOffset) > 1 {
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

