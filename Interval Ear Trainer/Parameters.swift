//
//  Parameters.swift
//  My First App
//
//  Created by Nicolas on 2024/12/06.
//

import Foundation

enum ExerciseType: Codable {
    case interval
    case triad
    case scale_degree
}

func ex_type_to_str(ex_type:ExerciseType) -> String
{
    return switch ex_type
    {
        case .scale_degree:  "scale_degree"
        case .interval:      "interval"
        case .triad:         "triad"
    }
}
struct Parameters : Codable {
    var type: ExerciseType = ExerciseType.interval
    
    // General
    var n_notes: Int = 2
    var is_chord: Bool = false
    var upper_bound: Int = 103
    var lower_bound: Int = 64
    var delay: Double = 2.8
    var delay_sequence: Double = 0.3
    
    // Interval related
    var active_intervals: Set<Int> = [-1, -2, -3, -4, -5, -6, -7, -8, -9, -10, -11, -12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
    var largeIntevalsProba: Double = 0.0
    
    // Triad related
    var active_qualities:  Set<String> = Set<String>(TRIADS.keys)
    var active_inversions: Set<String> = Set<String>(TRIAD_INVERSIONS.keys)
    var active_voicings:   Set<String> = Set<String>(TRIAD_VOICINGS.keys)
    
    // Scale degree related
    var scale: String = SCALE_KEYS.first!
    var active_scale_degrees: Set<Int> = Set<Int>(SCALE_DEGREES.values)
    var key: String = "A"
}

extension Parameters {
    func encode() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(self)
            return String(data: data, encoding: .utf8)!
        } catch {
            fatalError("Error encoding parameters: \(error)")
        }
    }
        
    static func decode(_ string: String) -> Parameters {
        let decoder = JSONDecoder()
        do {
            let parameters = try decoder.decode(Parameters.self, from: string.data(using: .utf8)!)
            return parameters
        } catch {
            fatalError("Error decoding parameters: \(error)")
        }
    }
}

