//
//  Parameters.swift
//  My First App
//
//  Created by Nicolas on 2024/12/06.
//

import Foundation

struct Parameters {
    var upper_bound: Int
    var lower_bound: Int
    var active_intervals: Set<Int>
    var delay: Double
    var delay_sequence: Double
    var largeIntevalsProba: Double
}

extension Parameters {
    static let init_value: Parameters =
    Parameters(upper_bound: 107,
               lower_bound: 64,
               active_intervals: [-1, -2, -3, -4, -5, -6, -7, -8, -9, -10, -11, -12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
               delay: 2.8,
               delay_sequence: 0.8,
               largeIntevalsProba: 0.0)
    static let init_value_passive1: Parameters =
    Parameters(upper_bound: 107,
               lower_bound: 64,
               active_intervals: [-4, -3, 3, 4],
               delay: 2.8,
               delay_sequence: 0.8,
               largeIntevalsProba: 0.0)
    static let init_value_passive2: Parameters =
    Parameters(upper_bound: 107,
               lower_bound: 64,
               active_intervals: [8, 9, 10, 11],
               delay: 2.8,
               delay_sequence: 0.8,
               largeIntevalsProba: 0.0)
    static let init_value_passive3: Parameters =
    Parameters(upper_bound: 107,
               lower_bound: 64,
               active_intervals: [-8, -9, -10, -11],
               delay: 2.8,
               delay_sequence: 0.8,
               largeIntevalsProba: 0.0)
}
