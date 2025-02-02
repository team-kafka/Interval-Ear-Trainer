//
//  Utils.swift
//  My First App
//
//  Created by Nicolas on 2024/12/04.
//

import Foundation

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

func rounded_date(date:Date) -> Date
{
    return Calendar.current.startOfDay(for:date)
}

enum AnswerType{
    case correct
    case incorrect
    case timeout
}

func evaluate_guess(guess:[String], answer:[String]) -> [AnswerType]
{
    var rv = [AnswerType].init(repeating: .timeout, count: answer.count)
    if answer.count < guess.count {return rv}
    for (i, g) in guess.enumerated(){
        rv[i] = g == short_answer(answer:answer[i], oriented: false) ? .correct : .incorrect
    }
    return rv
}

func short_answer(answer: String, oriented: Bool=true, abbreviate: Bool=false) -> String {
    var rv: String
    rv = answer.contains("/") ? String(answer.split(separator: "/")[0]) : answer
    if !oriented {
        do {
            let oriented_re = try Regex("[↑↓H][0-9]+")
            if rv.contains(oriented_re){
                rv = String(rv.suffix(rv.count-1))
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    return abbreviate ? String(rv.prefix(3)) : rv
}
