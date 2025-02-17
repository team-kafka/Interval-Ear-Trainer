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


struct FlatData : Identifiable, Hashable {
    var date: Date
    var type: String
    var id: String
    var value: Double
    var valueType: String
}


func flattenData(data: [HistoricalData]) -> [FlatData] {
    var rv = [FlatData]()
    let allKeys = Array(Set(data.map{usageDataKey(date:$0.date, type:$0.type, id:$0.id)}))
    
    for key in allKeys {
        let filteredData = data.filter({$0.date == key.date && $0.type == key.type && $0.id == key.id})
        var fData = [0.0, 0.0, 0.0]
        for ud in filteredData {
            fData[0] += Double(ud.correct)
            fData[1] += Double(ud.incorrect)
            fData[2] += Double(ud.timeout)
        }
        if fData[0] + fData[1] > 5 {
            if fData[0] > 0 {
                rv.append(FlatData(date: key.date, type: key.type, id: key.id, value: fData[0], valueType: "correct"))
            }
            if fData[0] + fData[1] > 0 {
                rv.append(FlatData(date: key.date, type: key.type, id: key.id, value: fData[1], valueType: "error"))
            }
            if fData[0] > 0 {
                rv.append(FlatData(date: key.date, type: key.type, id: key.id, value: fData[2], valueType: "timeout"))
            }
        }
    }
    return rv.sorted(by: {$0.date < $1.date})
}
