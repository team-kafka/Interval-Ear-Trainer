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
    let direction = oriented ? (interval_int > 0 ? "↑ " : "↓ ") : ""
    if ( abs(interval_int) % 12 == 0){
        return direction + "8"
    }
    else{
        let quality = INTERVAL_NAME_TO_INT.filter{$1 == abs(interval_int) % 12}.map{$0.0}[0]
        let octave = abs(interval_int) / 12 == 0 ? "" : " (+8)"
        return direction + quality + octave
    }
    
}

func draw_new_note(prev_note:Int, params:Parameters) -> Int
{
    let raw_interval = params.active_intervals.randomElement() ?? 0
    let octave = Double.random(in: 0...1) < params.largeIntevalsProba ? 12 : 0
    let interval = raw_interval > 0 ? raw_interval + octave : raw_interval - octave
    
    if (prev_note + interval > params.upper_bound) || (prev_note + interval < params.lower_bound){ // next note outside of range
        if (prev_note - interval > params.upper_bound) || (prev_note - interval < params.lower_bound){ // reflection outside of range
            return draw_new_note(prev_note: prev_note, params: params) // reject
        }
        else{
            return prev_note - interval
        }
    }
    return prev_note + interval
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
