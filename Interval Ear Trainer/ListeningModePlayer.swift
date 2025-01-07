//
//  LIsteningModePlayer.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2025/01/06.
//

import Foundation
import MediaPlayer

class ListeningModePlayer: ObservableObject {
    
    var player: MidiPlayer
    var timer: Timer?
    var playing: Bool
    var sequenceGenerator: SequenceGenerator
    var params: Parameters
    
    init(params: Parameters, sequenceGenerator: SequenceGenerator) {
        self.player = MidiPlayer()
        self.timer = nil
        self.params = params
        self.sequenceGenerator = sequenceGenerator
        self.playing = false
    }

    func start() {
        timer?.invalidate()
        playing = true
        updateNowPlaying()
        if (params.type == .scale_degree) {
            player.playNotes(notes: scale_notes(scale: params.scale, key: params.key, upper_bound: params.upper_bound, lower_bound: params.lower_bound), duration: params.delay_sequence*0.8)
            timer = Timer.scheduledTimer(withTimeInterval:params.delay_sequence * 0.8 * 7, repeats: false) { t in
                self.loopFunction()
            }
        } else {
            self.loopFunction()
        }
    }
    
    func stop(){
        timer?.invalidate()
        playing = false
        updateNowPlaying()
    }

    func loopFunction() {
        var total_delay = params.delay
        total_delay += play_sequence()
        timer = Timer.scheduledTimer(withTimeInterval:total_delay, repeats: false) { t in
            self.loopFunction()
        }
    }
    
    func play_sequence() -> Double {
        var delay: Double
        var duration: Double
        var notes: [Int] = [0, 0]
        
        (notes, duration, delay, _, _) = sequenceGenerator.generateSequence(params: params, n_notes:params.n_notes, chord:params.is_chord)
        player.playNotes(notes: notes, duration: duration, chord: params.is_chord)

        return delay
    }
    
    private func updateNowPlaying() {
        //print("calling updateNowPlaying")
        // Define Now Playing Info
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = "IET"
        //nowPlayingInfo[MPMediaItemPropertyMediaType] = MPMediaType.anyAudio.rawValue
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}
