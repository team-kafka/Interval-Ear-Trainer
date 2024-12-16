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
    var largeIntevalsProba: Double
}

extension Parameters {
    static let init_value: Parameters =
    Parameters(upper_bound: 107,
               lower_bound: 64,
               active_intervals: [-1, -2, -3, -4, -5, -6, -7, -8, -9, -10, -11, -12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
               delay: 3.0,
               largeIntevalsProba: 0.0)
}
