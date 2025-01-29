//
//  SequenceGenerator.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2024/12/29.
//

import Foundation
import SwiftUI

class SequenceGenerator {
    func generateSequence(params: Parameters, n_notes:Int, chord:Bool, prev_note:Int=0) -> ([Int], Double, Double, [String], Int) {
        return ([], 0, 0, [], 0)
    }
}

class IntervalGenerator : SequenceGenerator{
    
    override func generateSequence(params: Parameters, n_notes:Int, chord:Bool, prev_note:Int=0) -> ([Int], Double, Double, [String], Int) {
        var notes = [Int].init(repeating: 0, count: n_notes)
        var note_duration : Double = params.delay_sequence
        var seq_duration: Double = 0.0
        var answers = [String]()
        
        if (n_notes == 1) {
            if (prev_note == 0) {
                notes.append(0)
                answers.append("")
                notes[0] = Int.random(in: params.lower_bound..<params.upper_bound)
                (notes[1], answers[0]) = draw_new_note(prev_note: notes[0], active_intervals: params.active_intervals, upper_bound: params.upper_bound, lower_bound: params.lower_bound, largeIntevalsProba: params.largeIntevalsProba)
                note_duration = params.delay_sequence
                seq_duration = params.delay_sequence
            }
            else {
                notes.append(0)
                notes[0] = prev_note
                answers.append("")
                (notes[1], answers[0]) = draw_new_note(prev_note: prev_note, active_intervals: params.active_intervals, upper_bound: params.upper_bound, lower_bound: params.lower_bound, largeIntevalsProba: params.largeIntevalsProba)
                note_duration = params.delay_sequence
                seq_duration = 0.0
            }
        } else if chord{
            (notes, answers) = draw_random_chord(n_notes: n_notes, active_intervals: params.active_intervals, upper_bound: params.upper_bound, lower_bound: params.lower_bound, largeIntevalsProba: params.largeIntevalsProba, prev_note: prev_note)
            answers = answers.map { "H" + $0 }
            note_duration = params.delay * 0.5
            seq_duration = 0.0
        } else {
            (notes, answers) = draw_notes(n_notes: n_notes, active_intervals: params.active_intervals, upper_bound: params.upper_bound, lower_bound: params.lower_bound, largeIntevalsProba: params.largeIntevalsProba, prev_note: prev_note)
            note_duration = params.delay_sequence
            seq_duration = params.delay_sequence * Double(n_notes-1)
        }
        return (notes, note_duration, seq_duration, answers, 0)
    }
}

class TriadGenerator : SequenceGenerator{
    
    override func generateSequence(params: Parameters, n_notes:Int, chord:Bool, prev_note:Int=0) -> ([Int], Double, Double, [String], Int) {
        let seq_duration = chord ? 0.0 : params.delay_sequence * 2.0  // x n_notes - 1 (triad)
        let note_duration = chord ? params.delay * 0.5 : params.delay_sequence
        
        let res = draw_random_triad(active_qualities: params.active_qualities, active_inversions: params.active_inversions, active_voicings: params.active_voicings, upper_bound: params.upper_bound, lower_bound: params.lower_bound)

        let notes = res.0
        let quality = (res.1)[0]
        let inversion = (res.1)[1]
        let voicing = (res.1)[2] + " position"
        let root_note = res.2
        let answer_str = [quality, inversion, voicing].joined(separator: "/")
        
        return (notes, note_duration, seq_duration, [answer_str], root_note)
    }
}

class ScaleDegreeGenerator : SequenceGenerator{
    
    override func generateSequence(params: Parameters, n_notes:Int, chord:Bool, prev_note:Int=0) -> ([Int], Double, Double, [String], Int) {
        var notes = [Int]()
        var answers = [String]()

        (notes, answers) = draw_random_scale_degrees(n_notes:n_notes, scale:params.scale, active_degrees:params.active_scale_degrees, key:params.key, upper_bound:params.upper_bound, lower_bound:params.lower_bound, large_interval_proba:params.largeIntevalsProba, prev_note: prev_note)

        let duration = params.delay_sequence
        let delay = params.delay_sequence * Double(n_notes-1) 
        
        return (notes, duration, delay, answers, 0)
    }
}
