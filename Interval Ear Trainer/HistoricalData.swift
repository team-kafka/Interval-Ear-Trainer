//
//  IntervalData.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2025/01/15.
//

import Foundation
import SwiftData

@Model final class HistoricalData {
    var date: Date
    var type: String
    var id: String
    var listening: Int
    var practice: Int
    var correct: Int
    var incorrect: Int
    var timeout: Int
    
    init(date:Date, type: String, id: String, listening: Int=0, practice: Int=0, correct: Int=0, incorrect: Int=0, timeout: Int=0){
        self.date = date
        self.type = type
        self.id = id
        self.listening = listening
        self.practice = practice
        self.correct = correct
        self.incorrect = incorrect
        self.timeout = timeout
    }
}

extension HistoricalData {
    static var samples_int_asc  = generateIntervalSampleData(nDates:30, asc:true)
    static var samples_int_desc = generateIntervalSampleData(nDates:30, asc:false)
    static var samples_triad    = generateTriadSampleData(nDates:30)
}

func generateIntervalSampleData(nDates:Int=10, asc:Bool=true) -> [HistoricalData] {
    var rv = [HistoricalData]()
    for i in 0..<nDates {
        let proba_success = 0.5 + 0.3 * Double(nDates-i) / Double(nDates)
        let nInts = Int.random(in: 0...INTERVAL_KEYS.count)
        for interval in INTERVAL_KEYS.shuffled().prefix(nInts){
            let total = Int.random(in: 20...100)
            let correct = Int(Double(total) * (proba_success + Double.random(in: -0.15...0.15)))
            let incorrect_all = total - correct
            let timeout = Int.random(in: 0...Int(Double(incorrect_all)/2.0))
            let incorrect = incorrect_all - timeout
            let ihd = HistoricalData(date:rounded_date(date:Date() - TimeInterval(i*3600*24)), type:"interval", id: (asc ? "↑" : "↓") + interval, listening:Int.random(in: 0...100), practice:Int.random(in: 0...100), correct:correct, incorrect:incorrect, timeout:timeout)
            rv.append(ihd)
        }
    }
    return rv
}

func generateTriadSampleData(nDates:Int=10) -> [HistoricalData] {
    var rv = [HistoricalData]()
    for i in 0..<nDates {
        let proba_success = 0.5 + 0.3 * Double(nDates-i) / Double(nDates)
        let nInts = Int.random(in: 0...TRIAD_KEYS.count)
        for id in TRIAD_KEYS.shuffled().prefix(nInts){
            let total = Int.random(in: 20...100)
            let correct = Int(Double(total) * (proba_success + Double.random(in: -0.15...0.15)))
            let incorrect_all = total - correct
            let timeout = Int.random(in: 0...Int(Double(incorrect_all)/2.0))
            let incorrect = incorrect_all - timeout
            let ihd = HistoricalData(date:rounded_date(date:Date() - TimeInterval(i*3600*24)), type:"triad", id: id, listening:Int.random(in: 0...100), practice:Int.random(in: 0...100), correct:correct, incorrect:incorrect, timeout:timeout)
            rv.append(ihd)
        }
    }
    return rv
}

func generateScaleDegreeSampleData(nDates:Int=10) -> [HistoricalData] {
    var rv = [HistoricalData]()
    for i in 0..<nDates {
        let proba_success = 0.5 + 0.3 * Double(nDates-i) / Double(nDates)
        let nInts = Int.random(in: 0...SCALE_KEYS.count)
        for sc_id in SCALE_KEYS.shuffled().prefix(nInts){
            let degree_array = SCALE_DEGREES.values.map{interval_name(interval_int:SCALES[sc_id]![$0], oriented:false)}
            let d_ids = degree_array.shuffled().prefix(4)
            for d_id in d_ids{
                let total = Int.random(in: 20...100)
                let correct = Int(Double(total) * (proba_success + Double.random(in: -0.15...0.15)))
                let incorrect_all = total - correct
                let timeout = Int.random(in: 0...Int(Double(incorrect_all)/2.0))
                let incorrect = incorrect_all - timeout
                let ihd = HistoricalData(date:rounded_date(date:Date() - TimeInterval(i*3600*24)), type:"scle_degree", id: d_id, listening:Int.random(in: 0...100), practice:Int.random(in: 0...100), correct:correct, incorrect:incorrect, timeout:timeout)
                rv.append(ihd)
            }
        }
    }
    return rv
}
