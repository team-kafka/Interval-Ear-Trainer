//
//  LIsteningModePlayer.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2025/01/06.
//

import Foundation
import MediaPlayer

class ListeningModePlayer: ObservableObject {
    
    static let player = MidiPlayer()
    var timer: Timer?
    var playing: Bool
    var sequenceGenerator: SequenceGenerator
    
    init(params: Parameters, sequenceGenerator: SequenceGenerator) {
        self.timer = nil
        self.sequenceGenerator = sequenceGenerator
        self.playing = false
    }
    
    func start(params: Parameters) {
        self.playing = true
        timer?.invalidate()
        if (params.type == .scale_degree) {
            ListeningModePlayer.player.playNotes(notes: scale_notes(scale: params.scale, key: params.key, upper_bound: params.upper_bound, lower_bound: params.lower_bound), duration: params.delay_sequence*0.8)
            timer = Timer.scheduledTimer(withTimeInterval:params.delay_sequence * 0.8 * 7, repeats: false) { t in
                self.loopFunction(params:params)
            }
        } else {
            self.loopFunction(params:params)
        }
    }
    
    func stop(){
        self.playing = false
        timer?.invalidate()
    }
    
    func loopFunction(params:Parameters) {
        var total_delay = params.delay
        total_delay += play_sequence(params:params)
        timer = Timer.scheduledTimer(withTimeInterval:total_delay, repeats: false) { t in
            self.loopFunction(params:params)
        }
    }
    
    func play_sequence(params:Parameters) -> Double {
        var delay: Double
        var duration: Double
        var notes: [Int] = [0, 0]
        
        (notes, duration, delay, _, _) = sequenceGenerator.generateSequence(params: params, n_notes:params.n_notes, chord:params.is_chord)
        ListeningModePlayer.player.playNotes(notes: notes, duration: duration, chord: params.is_chord)
        
        return delay
    }
}
