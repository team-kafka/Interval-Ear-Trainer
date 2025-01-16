//
//  Utils.swift
//  My First App
//
//  Created by Nicolas on 2024/12/04.
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

func draw_notes(n_notes:Int, active_intervals:Set<Int>, upper_bound:Int, lower_bound:Int, largeIntevalsProba:Double, answer_oriented:Bool=true, prev_note:Int=0) -> ([Int], [String])
{
    var intervals = [Int]()
    for _ in (1...n_notes-1) {
        let rnd_interval = active_intervals.randomElement()!
        let octave = Double.random(in: 0...1) < largeIntevalsProba ? 12 * (rnd_interval > 0 ? 1 : -1) : 0
        intervals.append(rnd_interval + octave)
    }
    
    let running_sum: [Int] = intervals.enumerated().map { intervals.prefix($0).reduce($1, +) }
    let ub2 = upper_bound - max(0, running_sum.max()!)
    let lb2 = lower_bound - min(0, running_sum.min()!)
    
    var first_note: Int
    if lb2 < ub2 {
        var draw_set = Set(lb2...ub2)
        if (draw_set.count > 1 && draw_set.contains(prev_note)){
            draw_set.remove(prev_note)
        }
        first_note = draw_set.randomElement()!
    } else {
        first_note = Int(floor(Double(lb2 + ub2) / 2))
    }

    return ([first_note] + running_sum.map{first_note + $0},
            intervals.map{interval_name(interval_int: $0, oriented: answer_oriented, octave: false)})
}

func draw_random_chord(n_notes:Int, active_intervals:Set<Int>, upper_bound:Int, lower_bound:Int, largeIntevalsProba:Double, prev_note:Int=0) -> ([Int], [String])
{
    let pos_intervals = Set<Int>(active_intervals.map{$0 > 0 ? $0 : -$0})
    return draw_notes(n_notes:n_notes, active_intervals:pos_intervals, upper_bound:upper_bound, lower_bound:lower_bound, largeIntevalsProba:largeIntevalsProba, answer_oriented: false, prev_note: prev_note)
}

let NOTE_KEYS = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
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

func interval_answer_string(notes: [Int], chord: Bool, oriented: Bool) -> String
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
    return answers.joined(separator: " ")
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

let TRIAD_VOICING_KEYS = ["Close", "Open"]
let TRIAD_VOICINGS: [String: [Int]] = [
    "Close":  [0, 0, 0],
    "Open": [0, -12, 0],
]
    
func draw_random_triad_intervals(active_qualities: Set<String>, active_inversions: Set<String>, active_voicings: Set<String>) -> ([Int], [String], Int)
{
    let quality   = active_qualities.randomElement()  ?? "Major"
    let inversion = active_inversions.randomElement() ?? "Root position"
    let voicing   = active_voicings.randomElement()   ?? "Close"
    
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

func draw_random_triad(active_qualities: Set<String>, active_inversions: Set<String>, active_voicings: Set<String>, upper_bound:Int, lower_bound:Int) -> ([Int], [String], Int)
{
    let intervals_tags = draw_random_triad_intervals(active_qualities:active_qualities, active_inversions:active_inversions, active_voicings:active_voicings)
    let intervals = intervals_tags.0
    let lower_note = Int.random(in: lower_bound..<upper_bound-intervals.max()!)
    let notes = intervals.map{lower_note + $0}
    let root_note = notes[intervals_tags.2]
    
    return (notes:notes, tags:intervals_tags.1, root_note:root_note)
}

func triad_qualities_to_str(active_qualities: Set<String>) -> String
{
    let sorted_qualities = TRIAD_KEYS.filter{active_qualities.contains($0)}
    let qualities = sorted_qualities.map{$0.prefix(3)}
    return qualities.joined(separator: " ")
}

func triad_filters_to_str(active_qualities: Set<String>, active_inversions: Set<String>, active_voicings: Set<String>) -> String
{
    let sorted_qualities  = TRIAD_KEYS.filter{active_qualities.contains($0)}
    let sorted_inversions = TRIAD_INVERSION_KEYS.filter{active_inversions.contains($0)}
    let sorted_voicings   = TRIAD_VOICING_KEYS.filter{active_voicings.contains($0)}
    
    return sorted_qualities.joined(separator: "/") + "|" + sorted_inversions.joined(separator: "/") + "|" + sorted_voicings.joined(separator: "/")
}

func triad_filters_from_str(filter_str: String) -> (Set<String>, Set<String>, Set<String>)
{
    if filter_str.isEmpty { return (Set<String>(), Set<String>(), Set<String>()) }
 
    let split_str = filter_str.split(separator: "|")
    
    if split_str.count != 3 { return (Set<String>(), Set<String>(), Set<String>()) }
    
    let qualities  = Set(split_str[0].split(separator: "/").map{String($0)})
    let inversions = Set(split_str[1].split(separator: "/").map{String($0)})
    let voicings   = Set(split_str[2].split(separator: "/").map{String($0)})
    
    return (qualities, inversions, voicings)
}

//-------------------------
// Scale degrees
//-------------------------

let SCALE_KEYS = ["Major", "Harmonic Minor", "Relative Minor", "Melodic Minor", "Dorian"]
let SCALES: [String: [Int]] = [
    "Major":          [0, 2, 4, 5, 7, 9, 11],
    "Harmonic Minor": [0, 2, 3, 5, 7, 8, 11],
    "Relative Minor": [0, 2, 3, 5, 7, 8, 10],
    "Melodic Minor":  [0, 2, 3, 5, 7, 9, 11],
    "Dorian":         [0, 2, 3, 5, 7, 9, 10]
]

//let SCALE_DEGREE_KEYS = ["1", "2", "3", "4", "5", "6", "7"]
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

func rounded_date(date:Date) -> Date
{
    return Calendar.current.startOfDay(for:date)//-TimeInterval(3600*24*2))
}


func compare_intervals(lhs:String, rhs:String) -> Bool
{
    if lhs == rhs { return true }
    if lhs.replacingOccurrences(of: "♭", with: "") == rhs.replacingOccurrences(of: "♭", with: ""){
        if lhs.hasSuffix("♭") {
            return true
        } else {
            return false
        }
    }
    if lhs < rhs {
        return true
    } else {
        return false
    }
}

enum AnswerType{
    case correct
    case incorrect
    case timeout
}

func evaluate_guess(guess:[String], answer:[String]) -> [AnswerType]
{
    var rv = [AnswerType].init(repeating: .timeout, count: answer.count)
    
    for (i, g) in guess.enumerated(){
        if g == short_answer(answer:answer[i], oriented: false){
            rv[i] = .correct
        } else {
            rv[i] = .incorrect
        }
    }
    return rv
}

func short_answer(answer: String, oriented: Bool = true) -> String {
    let rv = String(answer.split(separator: "/")[0])
    if !oriented {
        return rv.replacingOccurrences(of: "↑", with: "").replacingOccurrences(of: "↓", with: "")
    }
    return rv
}
