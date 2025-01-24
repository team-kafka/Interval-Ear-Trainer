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
