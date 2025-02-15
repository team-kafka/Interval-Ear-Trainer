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
    var listening: UInt16
    var correct: UInt16
    var incorrect: UInt16
    var timeout: UInt16
    
    init(date:Date, type: String, id: String, listening: UInt16=0, correct: UInt16=0, incorrect: UInt16=0, timeout: UInt16=0){
        self.date = date
        self.type = type
        self.id = id
        self.listening = listening
        self.correct = correct
        self.incorrect = incorrect
        self.timeout = timeout
    }
}
