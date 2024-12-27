//
//  Parameters.swift
//  My First App
//
//  Created by Nicolas on 2024/12/06.
//

import Foundation

struct IntervalParameters {
    var upper_bound: Int = 107
    var lower_bound: Int = 64
    var active_intervals: Set<Int> = [-1, -2, -3, -4, -5, -6, -7, -8, -9, -10, -11, -12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
    var delay: Double = 2.8
    var delay_sequence: Double = 0.6
    var largeIntevalsProba: Double = 0.0
}

struct TriadParameters {
    var upper_bound: Int = 107
    var lower_bound: Int = 64
    var active_qualities: Set<String> = Set<String>(TRIADS.keys)
    var active_inversions: Set<String> = Set<String>(TRIAD_INVERSIONS.keys)
    var active_voicings: Set<String> = Set<String>(TRIAD_VOICINGS.keys)
    var delay: Double = 2.8
    var delay_arpeggio: Double = 0.6
}
