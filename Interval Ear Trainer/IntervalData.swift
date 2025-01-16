//
//  IntervalData.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2025/01/15.
//

import Foundation
import SwiftData

@Model final class IntervalData {
    var date: Date
    var interval: String
    var listening: Int
    var practice: Int
    var correct: Int
    var incorrect: Int
    var timeout: Int
    
    init(date:Date, interval: String, listening: Int=0, practice: Int=0, correct: Int=0, incorrect: Int=0, timeout: Int=0){
        self.date = date
        self.interval = interval
        self.listening = listening
        self.practice = practice
        self.correct = correct
        self.incorrect = incorrect
        self.timeout = timeout
    }
}

extension IntervalData {
    static var samples: [IntervalData] = [
        IntervalData(date:rounded_date(date:Date()), interval:"2", listening:10, practice:11, correct:13, incorrect:6, timeout:4),
        IntervalData(date:rounded_date(date:Date()), interval:"3", listening:13, practice:13, correct:15, incorrect:9, timeout:3),
        IntervalData(date:rounded_date(date:Date()), interval:"5", listening:12, practice:1, correct:10, incorrect:6, timeout:6),
        IntervalData(date:rounded_date(date:Date()), interval:"7", listening:2, practice:1, correct:10, incorrect:0, timeout:0),
        IntervalData(date:rounded_date(date:Date()), interval:"8", listening:1, practice:10, correct:10, incorrect:0, timeout:1),
    ]
    
}
