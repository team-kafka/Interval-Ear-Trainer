//
//  SequenceGenerator.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2024/12/29.
//

import Foundation
import SwiftUI

class SequenceGenerator {
    func generateSequence(params: Parameters, n_notes:Int, chord:Bool, prev_note:Int=0) -> ([Int], Double, Double, String, Int) {
        return ([], 0, 0, "", 0)
    }
    
    func generateFilterString(params: Parameters) -> String{
       return ""
    }
    
    func generateLabelString(params: Parameters) -> String{
        return ""
    }
}

class IntervalGenerator : SequenceGenerator{
    
    override func generateSequence(params: Parameters, n_notes:Int, chord:Bool, prev_note:Int=0) -> ([Int], Double, Double, String, Int) {
        var notes = [Int].init(repeating: 0, count: n_notes)
        var duration : Double = params.delay_sequence
        var delay: Double = 0.0
        var answer_str = ""
        
        if (n_notes == 1) {
            if (prev_note == 0) {
                notes.append(0)
                notes[0] = Int.random(in: params.lower_bound..<params.upper_bound)
                (notes[1], answer_str) = draw_new_note(prev_note: notes[0], active_intervals: params.active_intervals, upper_bound: params.upper_bound, lower_bound: params.lower_bound, largeIntevalsProba: params.largeIntevalsProba)
                duration = params.delay_sequence
                delay = params.delay_sequence
            }
            else {
                notes.append(0)
                notes[0] = prev_note
                (notes[1], answer_str) = draw_new_note(prev_note: prev_note, active_intervals: params.active_intervals, upper_bound: params.upper_bound, lower_bound: params.lower_bound, largeIntevalsProba: params.largeIntevalsProba)
                duration = params.delay_sequence
                delay = 0.0
            }
        } else if chord{
            (notes, answer_str) = draw_random_chord(n_notes: n_notes, active_intervals: params.active_intervals, upper_bound: params.upper_bound, lower_bound: params.lower_bound, largeIntevalsProba: params.largeIntevalsProba)
            duration = params.delay * 0.5
            delay = 0.0
        } else {
            let prev_note = notes[0]
            (notes, answer_str) = draw_notes(n_notes: n_notes, active_intervals: params.active_intervals, upper_bound: params.upper_bound, lower_bound: params.lower_bound, largeIntevalsProba: params.largeIntevalsProba, prev_note: prev_note)
            duration = params.delay_sequence
            delay = params.delay_sequence * Double(n_notes-1) * 0.5
        }
        return (notes, duration, delay, answer_str, 0)
    }
    
    override func generateFilterString(params: Parameters) -> String{
        return interval_filter_to_str(intervals: params.active_intervals)
    }
    
    override func generateLabelString(params: Parameters) -> String{
        return interval_filter_to_str(intervals: params.active_intervals)
    }
}

class TriadGenerator : SequenceGenerator{
    
    override func generateSequence(params: Parameters, n_notes:Int, chord:Bool, prev_note:Int=0) -> ([Int], Double, Double, String, Int) {
        let delay = chord ? 0.0 : params.delay_sequence * 2.0 * 0.5 // x n_notes - 1 (triad) and x 0.5 (tempo = 120)
        let duration = chord ? params.delay * 0.5 : params.delay_sequence
        
        let res = draw_random_triad(active_qualities: params.active_qualities, active_inversions: params.active_inversions, active_voicings: params.active_voicings, upper_bound: params.upper_bound, lower_bound: params.lower_bound)

        let notes = res.0
        let quality = (res.1)[0]
        let inversion = (res.1)[1]
        let voicing = (res.1)[2] + " position"
        let root_note = res.2
        let answer_str = [quality, inversion, voicing].joined(separator: "/")
        
        return (notes, duration, delay, answer_str, root_note)
    }
    
    override func generateFilterString(params: Parameters) -> String{
        return triad_filters_to_str(active_qualities: params.active_qualities, active_inversions: params.active_inversions, active_voicings: params.active_voicings)
    }
    
    override func generateLabelString(params: Parameters) -> String{
        return triad_qualities_to_str(active_qualities: params.active_qualities)
    }
}

class ScaleDegreeGenerator : SequenceGenerator{
    
    override func generateSequence(params: Parameters, n_notes:Int, chord:Bool, prev_note:Int=0) -> ([Int], Double, Double, String, Int) {
        var notes = [Int]()
        var answers = [String]()

        (notes, answers) = draw_random_scale_degrees(n_notes:n_notes, scale:params.scale, active_degrees:params.active_scale_degrees, key:params.key, upper_bound:params.upper_bound, lower_bound:params.lower_bound, large_interval_proba:params.largeIntevalsProba)

        let answer_str = answers.joined(separator: " ")
        let duration = params.delay_sequence
        let delay = params.delay_sequence * Double(n_notes-1) * 0.5
        
        return (notes, duration, delay, answer_str, 0)
    }
    
    override func generateFilterString(params: Parameters) -> String{
        return scale_degree_filter_to_str(intervals: params.active_scale_degrees)
    }
    
    override func generateLabelString(params: Parameters) -> String{
        return params.key + " " + SCALE_SHORT_NAMES[params.scale]!
    }
}
