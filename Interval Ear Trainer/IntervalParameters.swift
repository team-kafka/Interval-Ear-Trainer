//
//  Parameters.swift
//  My First App
//
//  Created by Nicolas on 2024/12/06.
//

import Foundation
import SwiftData

struct IntervalParameters {
    var upper_bound: Int = 107
    var lower_bound: Int = 64
    var active_intervals: Set<Int> = [-1, -2, -3, -4, -5, -6, -7, -8, -9, -10, -11, -12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
    var delay: Double = 2.8
    var delay_sequence: Double = 0.8
    var largeIntevalsProba: Double = 0.0
}
