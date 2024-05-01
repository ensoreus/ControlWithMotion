//
//  ViewController.swift
//  ControlWithMotion
//
//  Created by Philipp Maluta on 30.04.2024.
//

import UIKit
import AVFoundation

class PlaybackViewController: UIViewController{
    private var player = AVPlayer(playerItem: Factory.production.playerItem())
    private let gyroProvider = Factory.production.gyroProvider()
    var seek: CMTime = CMTime(value: 0, timescale: 1) {
        didSet{
            player.seek(to: seek)
        }
    }
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
      //  player.pause()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        seek = CMTime(seconds: 0, preferredTimescale: 1)
    }
}

extension PlaybackViewController: GyroSubscriber {

    fileprivate func seekBy(_ timeOffset: CMTime) {
            if CMTimeGetSeconds(timeOffset) > 1 {
                 player.seek(to: timeOffset, toleranceBefore: CMTimeMake(value: 1, timescale: 3), toleranceAfter: CMTime(value: 1, timescale: 3))
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

