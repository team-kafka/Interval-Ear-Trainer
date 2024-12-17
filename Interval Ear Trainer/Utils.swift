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

func interval_name(interval_int: Int, oriented:Bool) -> String
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
        let octave = abs(interval_int) / 12 == 0 ? "" : ""//+8"
        return direction + quality + octave
    }
}


func draw_new_note(prev_note:Int, params:Parameters) -> Int
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
    let octave = (note_int - 12) / 12
    let note = (note_int - 12) % 12
    let note_name = MIDI_NOTE_MAPPING[note]!
    return note_name + String(format:"%d", octave)
}
