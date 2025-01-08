//
//  LIsteningModePlayer.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2025/01/06.
//

import Foundation
import MediaPlayer

class ListeningModePlayer {
    
    static let player = MidiPlayer()
    var timer: Timer?
    var playing: Bool
    var notes: [Int]
    
    init() {
        self.timer = nil
        self.playing = false
        self.notes = [0]
    }
    
    func start(params: Parameters, sequenceGenerator: SequenceGenerator) {
        self.playing = true
        timer?.invalidate()
        if (params.type == .scale_degree) {
            ListeningModePlayer.player.playNotes(notes: scale_notes(scale: params.scale, key: params.key, upper_bound: params.upper_bound, lower_bound: params.lower_bound), duration: params.delay_sequence*0.8)
            timer = Timer.scheduledTimer(withTimeInterval:params.delay_sequence * 0.8 * 7, repeats: false) { t in
                self.loopFunction(params:params, sequenceGenerator: sequenceGenerator)
            }
        } else {
            self.loopFunction(params:params, sequenceGenerator: sequenceGenerator)
        }
    }
    
    func stop(){
        self.playing = false
        timer?.invalidate()
    }
    
    func loopFunction(params:Parameters, sequenceGenerator: SequenceGenerator) {
        var total_delay = params.delay
        total_delay += play_sequence(params:params, sequenceGenerator: sequenceGenerator)
        timer = Timer.scheduledTimer(withTimeInterval:total_delay, repeats: false) { t in
            self.loopFunction(params:params, sequenceGenerator: sequenceGenerator)
        }
    }
    
    func play_sequence(params:Parameters, sequenceGenerator: SequenceGenerator) -> Double {
        var delay: Double
        var duration: Double
        var new_notes: [Int]
        
        (new_notes, duration, delay, _, _) = sequenceGenerator.generateSequence(params: params, n_notes:params.n_notes, chord:params.is_chord,  prev_note:params.n_notes == 1 ? notes.last ?? 0 : notes.first ?? 0)
        ListeningModePlayer.player.playNotes(notes: new_notes, duration: duration, chord: params.is_chord)
        notes = new_notes
        return delay
    }
}
