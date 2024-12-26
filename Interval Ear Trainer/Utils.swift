//
//  Utils.swift
//  My First App
//
//  Created by Nicolas on 2024/12/04.
//

import Foundation

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
        return "0"
    }
    
    let direction = oriented ? (interval_int > 0 ? "↑" : "↓") : ""
    if (abs(interval_int) % 12 == 0){
        return direction + "8"
    }
    else{
        let quality = INTERVAL_NAME_TO_INT.filter{$1 == abs(interval_int) % 12}.map{$0.0}[0]
        let octave = (octave && abs(interval_int) / 12 != 0) ? "+8" : ""//+8"
        return direction + quality + octave
    }
}

func draw_new_note(prev_note:Int, params:IntervalParameters) -> Int
{
    let acceptable_intervals = params.active_intervals.filter{(prev_note+$0 >= params.lower_bound) && (prev_note+$0 <= params.upper_bound)}
    if (acceptable_intervals.isEmpty){
        
        return Int.random(in: max(prev_note-12, params.lower_bound)..<min(prev_note+12, params.upper_bound))
    }
    
    let rnd_interval = acceptable_intervals.randomElement()!
    var octave = Double.random(in: 0...1) < params.largeIntevalsProba ? 12 * (rnd_interval > 0 ? 1 : -1) : 0
    if (prev_note + rnd_interval + octave < params.lower_bound) || (prev_note + rnd_interval + octave > params.upper_bound) {
        octave = 0
    }
    
    return prev_note + rnd_interval + octave
}

func draw_random_chord(params:IntervalParameters, n_notes:Int) -> [Int]
{
    let note_0 = Int.random(in: params.lower_bound...params.upper_bound-12)
    let pos_intervals = Set<Int>(params.active_intervals.map{$0 > 0 ? $0 : -$0})
    print(pos_intervals)
    var acceptable_intervals = pos_intervals.filter{note_0+$0 <= params.upper_bound}
    var rv = [note_0]
    for _ in (0..<n_notes-1){
        let rnd_int = acceptable_intervals.randomElement()!
        let octave = (Double.random(in: 0...1) < params.largeIntevalsProba)
                    && (note_0 + rnd_int + 12 < params.upper_bound) ? 12 : 0
        if (acceptable_intervals.count > 1){
            acceptable_intervals.remove(at:acceptable_intervals.firstIndex{$0 == rnd_int}!)
        }
        rv.append(note_0 + octave + rnd_int)
    }
    return rv.sorted()
}

let MIDI_NOTE_MAPPING: [Int: String] = [
    0:"C",
    1:"C#",
    2:"D",
    3:"D#",
    4:"E",
    5:"F",
    6:"F#",
    7:"G",
    8:"G#",
    9:"A",
    10:"A#",
    11:"B",

]

func midi_note_to_name(note_int: Int) -> String
{
    if (note_int == 0) {return " "}
    
    let octave = (note_int - 12) / 12
    let note = (note_int - 12) % 12
    let note_name = MIDI_NOTE_MAPPING[note]!
    return note_name + String(format:"%d", octave)
}

func interval_filter_to_str(intervals:Set<Int>) -> String
{
    let intervals_abs = Set<Int>(intervals.map{$0 > 0 ? $0 : -$0}).sorted()
    let intervals_strs = intervals_abs.map{helper_func(interval_abs: $0, intervals:intervals)}
    return intervals_strs.joined(separator: " ")
}

func helper_func(interval_abs: Int, intervals:Set<Int>) -> String
{
    var rv = interval_name(interval_int: interval_abs, oriented: false, octave: false)
    if ((intervals.contains(interval_abs)) && (!intervals.contains(-interval_abs))){
        rv += "↑"
    } else if ((!intervals.contains(interval_abs)) && (intervals.contains(-interval_abs))){
        rv += "↓"
    }
    return rv
}
 
func str_to_interval_filter(filter_str: String) -> Set<Int>
{
    var rv = [Int]()
    for int_str in filter_str.split(separator: " ") {
        if int_str.contains("↑"){
            let this_str: String = int_str.replacingOccurrences(of: "↑", with: "")
            rv.append(INTERVAL_NAME_TO_INT[this_str]!)
        } else if int_str.contains("↓"){
            let this_str: String = int_str.replacingOccurrences(of: "↓", with: "")
            rv.append(-INTERVAL_NAME_TO_INT[this_str]!)
        } else {
            rv.append(INTERVAL_NAME_TO_INT[String(int_str)]!)
            rv.append(-INTERVAL_NAME_TO_INT[String(int_str)]!)
        }
    }
    return Set<Int>(rv)
}

func answer_string(notes: [Int], chord: Bool, oriented: Bool) -> String
{
    var answers = [String]()
    if chord{
        for i in notes[1...] {
            answers.append(interval_name(interval_int:i-notes[0], oriented: oriented))
        }
    } else{
        for (e1, e2) in zip(notes, notes[1...]) {
            answers.append(interval_name(interval_int:e2-e1, oriented: oriented))
        }
    }
    return answers.joined(separator: "  ")
}

func answer_from_notes(notes: [Int], chord: Bool, oriented: Bool) -> [Int]
{
    var answers = [Int]()
    if chord{
        for i in notes[1...] {
            answers.append(oriented ? i-notes[0] : abs(i-notes[0]))
        }
    } else{
        for (e1, e2) in zip(notes, notes[1...]) {
            answers.append(oriented ? e2-e1 : abs(e2-e1))
        }
    }
    return answers
}

//-------------------------
// Triads
//-------------------------

let TRIAD_KEYS = ["Major", "Minor", "Diminished", "Augmented", "Lydian"]
let TRIADS: [String: [Int]] = [
    "Major":      [0, 4, 7],
    "Minor":      [0, 3, 7],
    "Diminished": [0, 3, 6],
    "Augmented":  [0, 4, 8],
    "Lydian":     [0, 4, 6],
]
    
let TRIAD_INVERSION_KEYS = ["Root position", "1st inversion", "2nd inversion"]
let TRIAD_INVERSIONS: [String: [Int]] = [
    "Root position": [0, 0, 0],
    "1st inversion": [12, 0, 0],
    "2nd inversion": [12, 12, 0],
]

let TRIAD_VOICING_KEYS = ["Close", "Spread"]
let TRIAD_VOICINGS: [String: [Int]] = [
    "Close":  [0, 0, 0],
    "Spread": [0, -12, 0],
]
    
func draw_random_triad_intervals(params:TriadParameters) -> ([Int], [String], Int)
{
    let quality   = params.active_qualities.randomElement()  ?? "Major"
    let inversion = params.active_inversions.randomElement() ?? "Root position"
    let voicing   = params.active_voicings.randomElement()   ?? "Close"
    
    var rv            = (TRIADS[quality]             ?? [0, 4, 7])
    let inversion_int = (TRIAD_INVERSIONS[inversion] ?? [0, 0, 0])
    let voicing_int   = (TRIAD_VOICINGS[voicing]     ?? [0, 0, 0])
    
    for i in 0..<rv.count {
        rv[i] += inversion_int[i] + voicing_int[i]
    }
    rv = rv.map{$0 - rv.min()!}
    let root = rv[0]
    rv = rv.sorted()
    let root_idx = rv.firstIndex(of: root)!

    return (intervals:rv, tags:[quality, inversion, voicing], root_idx:root_idx)
}

func draw_random_triad(params:TriadParameters) -> ([Int], [String], Int)
{
    let intervals_tags = draw_random_triad_intervals(params:params)
    let intervals = intervals_tags.0
    let lower_note = Int.random(in: params.lower_bound..<params.upper_bound-intervals.max()!)
    let notes = intervals.map{lower_note + $0}
    let root_note = notes[intervals_tags.2]
    
    return (notes:notes, tags:intervals_tags.1, root_note:root_note)
}
