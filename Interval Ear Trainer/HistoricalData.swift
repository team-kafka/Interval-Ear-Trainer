//
//  HistoricalData.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2025/01/12.
//

import Foundation
import TabularData

struct HistoricalData : Codable {
    var date: Date
    var id: String
    var listening: Int
    var practice: Int
    var quizz_correct: Int
    var quizz_error: Int
    var quizz_timeout: Int
}

extension DataFrame.Rows : @retroactive RandomAccessCollection {
}

func summmary1(data:DataFrame) -> DataFrame
{
    print("\(data)")
    
    return data
}

func emptyDF(date:Date, ids: [String]) -> DataFrame
{
    let colDate = Column<Date>(name:"date", contents: Array(repeating: date, count: ids.count))
    let colId = Column<String>(name:"id", contents: ids)
    let colListening = Column<Int>(name:"listening", contents: Array(repeating: 0, count: ids.count))
    let colPractice = Column<Int>(name:"practice", contents:  Array(repeating: 0, count: ids.count))
    let colQC = Column<Int>(name:"quizz_correct", contents:  Array(repeating: 0, count: ids.count))
    let colQE = Column<Int>(name:"quizz_error", contents:  Array(repeating: 0, count: ids.count))
    let colQT = Column<Int>(name:"quizz_timeout", contents:  Array(repeating: 0, count: ids.count))
    
    var dataFrame = DataFrame()
    dataFrame.append(column: colDate)
    dataFrame.append(column: colId)
    dataFrame.append(column: colListening)
    dataFrame.append(column: colPractice)
    dataFrame.append(column: colQC)
    dataFrame.append(column: colQE)
    dataFrame.append(column: colQT)
    
    print("\(dataFrame)")
    return dataFrame
}

func randomDF(date:Date, ids: [String]) -> DataFrame
{
    let colDate = Column<Date>(name:"date", contents: Array(repeating: date, count: ids.count))
    let colId = Column<String>(name:"id", contents: ids)
    let colListening = Column<Int>(name:"listening", contents: ids.map{_ in Int.random(in:0...20)})
    let colPractice = Column<Int>(name:"practice", contents:  ids.map{_ in Int.random(in:0...20)})
    let colQC = Column<Int>(name:"quiz_correct", contents:  ids.map{_ in Int.random(in:0...20)})
    let colQE = Column<Int>(name:"quiz_error", contents: ids.map{_ in Int.random(in:0...6)})
    let colQT = Column<Int>(name:"quiz_timeout", contents: ids.map{_ in Int.random(in:0...7)})
    
    var dataFrame = DataFrame()
    dataFrame.append(column: colDate)
    dataFrame.append(column: colId)
    dataFrame.append(column: colListening)
    dataFrame.append(column: colPractice)
    dataFrame.append(column: colQC)
    dataFrame.append(column: colQE)
    dataFrame.append(column: colQT)
    
    return dataFrame
}

func sampleDF(ids:[String]) -> DataFrame
{
    let nDates = 2
    let gregorianCalendar = Calendar(identifier: .gregorian)
    let dates = Range(1...nDates).map { Calendar.current.startOfDay(for: gregorianCalendar.date(
        byAdding:DateComponents(day: -$0), to:Date())!)}

    var rv = randomDF(date:dates[0], ids:ids)
    for d in dates[1...] {
        rv.append(randomDF(date:d, ids:ids))
    }
    
    return rv
}

func randomPLDF(date:Date, ids: [String]) -> DataFrame
{
    let colDate = Column<Date>(name:"date", contents: Array(repeating: date, count: ids.count))
    let colId = Column<String>(name:"id", contents: ids)
    let colListening = Column<Int>(name:"listening", contents: ids.map{_ in Int.random(in:0...20)})
    let colPractice = Column<Int>(name:"practice", contents:  ids.map{_ in Int.random(in:0...20)})
    
    var dataFrame = DataFrame()
    dataFrame.append(column: colDate)
    dataFrame.append(column: colId)
    dataFrame.append(column: colListening)
    dataFrame.append(column: colPractice)
    
    return dataFrame
}

func samplePLDF(ids:[String]) -> DataFrame
{
    let nDates = 2
    let gregorianCalendar = Calendar(identifier: .gregorian)
    let dates = Range(1...nDates).map { Calendar.current.startOfDay(for: gregorianCalendar.date(
        byAdding:DateComponents(day: -$0), to:Date())!)}

    var rv = randomDF(date:dates[0], ids:ids)
    for d in dates[1...] {
        rv.append(randomDF(date:d, ids:ids))
    }
    
    return rv
}

func testMerge() -> DataFrame
{
    var df = samplePLDF(ids: ["2", "4", "5"])
    
    var dictL: [String:Int] = [
        "2":10,
        "3":24,
        "5":7
    ]
    var dictP: [String:Int] = [
        "2":1,
        "3":4,
        "7":2
    ]
    let date = df["date"][0]
    let dfL:DataFrame = ["id":Array(dictL.keys), "listening":Array(dictL.values), "date":dictL.map{_ in date}]
    let dfP:DataFrame = ["id":Array(dictP.keys), "practice":Array(dictP.values), "date":dictP.map{_ in date}]
//    print("\(df)")
//    print("\(df2)")
    df.append(dfL)
    df.append(dfP)
    //print(df)
    df.transformColumn("listening") {
        (l:Int?) -> Int in
        l ?? 0
    }
    //print(df)
//    
//    let df3 = df.grouped(by: "id", "date").mapGroups { group in
//        group.summary(of: "listening")
//    }.ungrouped()
//    
//    print(df.sum)
    return df
}
