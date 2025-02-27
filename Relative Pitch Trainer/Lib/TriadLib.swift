//
//  TriadLib.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2025/01/25.
//

import Foundation

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
    
    return generate_triad_intervals(quality: quality, inversion: inversion, voicing: voicing)
}

func generate_triad_intervals(quality: String, inversion: String, voicing: String) -> ([Int], [String], Int)
{
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
