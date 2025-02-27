//
//  IntervalsLib.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2025/01/25.
//

import Foundation

let INTERVAL_KEYS: [String] = ["2♭", "2", "3♭", "3", "4", "5♭","5", "6♭", "6", "7♭","7", "8"]
let INTERVAL_NAME_TO_INT: [String :Int] = [
    "2♭": 1,
    "2": 2,
    "3♭": 3,
    "3": 4,
    "4": 5,
    "5♭": 6,
    "5": 7,
    "6♭": 8,
    "6": 9,
    "7♭": 10,
    "7": 11,
    "8": 12,
              ]

func interval_name(interval_int: Int, oriented:Bool, octave:Bool=false) -> String
{
    if (interval_int==0){
        return "1"
    }
    
    let direction = oriented ? (interval_int > 0 ? "↑" : "↓") : ""
    if (abs(interval_int) % 12 == 0){
        return direction + "8"
    }
    else {
        let quality = INTERVAL_NAME_TO_INT.filter{$1 == abs(interval_int) % 12}.map{$0.0}[0]
        let octave = (octave && abs(interval_int) / 12 != 0) ? "+8" : ""
        return direction + quality + octave
    }
}

func interval_int_from_name(name: String) -> Int
{
    let sign = name.contains("↓") ? -1 : 1
    let unsignedInt = name.replacingOccurrences(of: "↓", with: "").replacingOccurrences(of: "↑", with: "").replacingOccurrences(of: "H", with: "")
    if INTERVAL_NAME_TO_INT.keys.contains(unsignedInt) {
        return INTERVAL_NAME_TO_INT[unsignedInt]! * sign
    }
    return 0
}

func interval_filter_to_str(intervals:Set<Int>, harmonic:Bool = false) -> String
{
    let intervals_abs = Set<Int>(intervals.map{$0 > 0 ? $0 : -$0}).sorted()
    let intervals_strs = harmonic ? intervals_abs.map{"H" + interval_name(interval_int: $0, oriented: false, octave: false)} :  intervals_abs.map{helper_func(interval_abs: $0, intervals:intervals)}
    return intervals_strs.joined(separator: " ")
}

func draw_new_note(prev_note:Int, active_intervals:Set<Int>, upper_bound:Int, lower_bound:Int, largeIntevalsProba:Double) -> (Int, String)
{
    let acceptable_intervals = active_intervals.filter{(prev_note+$0 >= lower_bound) && (prev_note+$0 <= upper_bound)}
    if (acceptable_intervals.isEmpty){
        var draw_set = Set(max(prev_note-12, lower_bound)...min(prev_note+12, upper_bound))
        draw_set.remove(prev_note)
        let new_note = draw_set.randomElement()!
        return (new_note, interval_name(interval_int: new_note-prev_note, oriented: true, octave: false))
    }
    
    let rnd_interval = acceptable_intervals.randomElement()!
    var octave = Double.random(in: 0...1) < largeIntevalsProba ? 12 * (rnd_interval > 0 ? 1 : -1) : 0
    if (prev_note + rnd_interval + octave < lower_bound) || (prev_note + rnd_interval + octave > upper_bound) {
        octave = 0
    }
    
    return (prev_note + rnd_interval + octave, interval_name(interval_int: rnd_interval, oriented: true, octave: false))
}

func draw_notes(n_notes:Int, active_intervals:Set<Int>, upper_bound:Int, lower_bound:Int, largeIntevalsProba:Double, answer_oriented:Bool=true, prev_note:Int=0, first_note_in:Int=0) -> ([Int], [String])
{
    var intervals = [Int]()
    for _ in (1...n_notes-1) {
        let rnd_interval = active_intervals.randomElement()!
        let octave = Double.random(in: 0...1) < largeIntevalsProba ? 12 * (rnd_interval > 0 ? 1 : -1) : 0
        intervals.append(rnd_interval + octave)
    }
    
    let running_sum: [Int] = intervals.enumerated().map{ intervals.prefix($0).reduce($1, +) }
    let ub2 = upper_bound - max(0, running_sum.max()!)
    let lb2 = lower_bound - min(0, running_sum.min()!)
    
    var first_note: Int
    if first_note_in == 0 {
        if lb2 < ub2 {
            var draw_set = Set(lb2...ub2)
            if (draw_set.count > 1 && draw_set.contains(prev_note)){
                draw_set.remove(prev_note)
            }
            first_note = draw_set.randomElement()!
        } else {
            first_note = Int(floor(Double(lb2 + ub2) / 2))
        }
    } else {
        first_note = first_note_in
    }

    return ([first_note] + running_sum.map{first_note + $0},
            intervals.map{interval_name(interval_int: $0, oriented: answer_oriented, octave: false)})
}

func draw_random_chord(n_notes:Int, active_intervals:Set<Int>, upper_bound:Int, lower_bound:Int, largeIntevalsProba:Double, prev_note:Int=0) -> ([Int], [String])
{
    let pos_intervals = Set<Int>(active_intervals.map{$0 > 0 ? $0 : -$0})
    return draw_notes(n_notes:n_notes, active_intervals:pos_intervals, upper_bound:upper_bound, lower_bound:lower_bound, largeIntevalsProba:largeIntevalsProba, answer_oriented: false, prev_note: prev_note)
}

func helper_func(interval_abs: Int, intervals:Set<Int>) -> String
{
    var rv = interval_name(interval_int: interval_abs, oriented: false, octave: false)
    if ((intervals.contains(interval_abs)) && (!intervals.contains(-interval_abs))){
        rv = "↑" + rv
    } else if ((!intervals.contains(interval_abs)) && (intervals.contains(-interval_abs))){
        rv = "↓" + rv
    }
    return rv
}
 
