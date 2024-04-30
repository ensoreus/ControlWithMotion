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
        print("VOLUM: \(player.volume)")
    }

    fileprivate func setupPlayer() {
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        view.layer.addSublayer(playerLayer)
    }

    private func backToBegin() {
      //  player.pause()
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        seek = CMTime(seconds: 0, preferredTimescale: 1)
    }
}

extension PlaybackViewController: GyroSubscriber {

    func back(time: CMTime){

    }
    func forward(time: CMTime){

    }
    func volume(change on: Float){
        volume += on
    }

}

