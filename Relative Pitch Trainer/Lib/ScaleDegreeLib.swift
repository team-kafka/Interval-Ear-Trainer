//
//  ScaleDegreeLib.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2025/01/25.
//

import Foundation

let SCALE_KEYS = ["Major", "Harmonic Minor", "Relative Minor", "Melodic Minor", "Dorian"]
let SCALES: [String: [Int]] = [
    "Major":          [0, 2, 4, 5, 7, 9, 11],
    "Harmonic Minor": [0, 2, 3, 5, 7, 8, 11],
    "Relative Minor": [0, 2, 3, 5, 7, 8, 10],
    "Melodic Minor":  [0, 2, 3, 5, 7, 9, 11],
    "Dorian":         [0, 2, 3, 5, 7, 9, 10]
]

let SCALE_DEGREE_KEYS = ["1", "2", "3", "4", "5", "6", "7"]
let SCALE_DEGREE_KEYS_W_ALT = ["1", "2♭","2", "3♭","3", "4", "5", "6♭", "6", "7♭", "7"]
let SCALE_DEGREES = [
    "1" : 0,
    "2" : 1,
    "3" : 2,
    "4" : 3,
    "5" : 4,
    "6" : 5,
    "7" : 6
]

let SCALE_SHORT_NAMES: [String: String] = [
    "Major":          "Maj",
    "Harmonic Minor": "Harm Min",
    "Relative Minor": "Rel Min",
    "Melodic Minor":  "Mel Min",
    "Dorian":         "Dor"
]

let SCALE_DELAY: Double = 0.2

func scale_degree_name(degree_int: Int) -> String
{
    let quality = SCALE_DEGREES.filter{$1 == degree_int}.map{$0.0}[0]
    return quality
}

func scale_degree_answer_str(degrees: [Int], scale:String) -> String
{
    let ans_array = degrees.map{interval_name(interval_int:SCALES[scale]![$0], oriented:false)}
    return ans_array.joined(separator: " ")
}

func middle_note(key: String, upper_bound:Int, lower_bound:Int) -> Int{
    let mid_note = Int((upper_bound + lower_bound) / 2)
    let pitch_int = MIDI_NOTE_MAPPING.filter{$1 == key}.map{$0.0}[0]
    
    return Int(floor(Double(mid_note - pitch_int) / 12)) * 12 + pitch_int
}

func draw_random_scale_degrees(n_notes:Int, scale:String, active_degrees:Set<Int>, key:String, upper_bound:Int, lower_bound:Int, large_interval_proba:Double, prev_note:Int) -> ([Int], [String])
{
    var notes = [Int]()
    var answers = [String]()
    var this_prev_note:Int = prev_note
    
    for _ in 0..<n_notes
    {
        var new_note:Int
        var new_answer:String
        (new_note, new_answer) = draw_random_scale_degree(scale:scale, active_degrees:active_degrees, key:key, upper_bound:upper_bound, lower_bound:lower_bound, large_interval_proba:large_interval_proba, prev_note:this_prev_note)
        notes.append(new_note)
        answers.append(new_answer)
        this_prev_note = new_note
    }
    return (notes, answers)
}

func draw_random_scale_degree(scale:String, active_degrees:Set<Int>, key:String, upper_bound:Int, lower_bound:Int, large_interval_proba:Double, prev_note:Int) -> (Int, String)
{
    let mid_note = middle_note(key: key, upper_bound: upper_bound, lower_bound: lower_bound)

    var draw_choices = active_degrees
    if ((active_degrees.count > 1) && prev_note != 0){
        let prev_int = (prev_note - mid_note) % 12 + ((prev_note - mid_note) % 12 < 0 ? 12 : 0)
        let prev_degree = SCALES[scale]!.firstIndex(of: prev_int) ?? -1
        draw_choices.remove(prev_degree)
    }

    let this_degree = draw_choices.randomElement() ?? 0
    let octave: Int = (Double.random(in: 0...1) < large_interval_proba ? 12 : 0) * (Double.random(in: 0...1) < 0.5 ? 1 : -1)
    let raw_int = SCALES[scale]![this_degree]
    let new_note = mid_note + raw_int + octave

    return (new_note, interval_name(interval_int:raw_int, oriented:false))
}

func scale_degree_filter_to_str(intervals:Set<Int>) -> String
{
    if intervals.isEmpty { return "" }
    
    let degrees_str = SCALE_DEGREES.filter{intervals.contains($1)}.keys//.map(String($0))
    return degrees_str.joined(separator: " ")
}

func str_to_scale_degree_filter(filter_str: String) -> Set<Int>
{
    if (filter_str == "") {
        return Set<Int>()
    }
    var rv = Set<Int>()
    let degrees_str = filter_str.split(separator: " ")
    for d in degrees_str {
        if (SCALE_DEGREES.keys.contains(String(d))) {
            rv.insert(SCALE_DEGREES[String(d)]!)
        }
    }
    return rv
}

func scale_notes(scale:String, key:String, upper_bound:Int, lower_bound:Int) -> [Int]
{
    let mid_note: Int = middle_note(key: key, upper_bound: upper_bound, lower_bound: lower_bound)
    var notes = SCALES[scale] ?? []
    notes.append(12)
    return notes.map{mid_note + $0}
}
