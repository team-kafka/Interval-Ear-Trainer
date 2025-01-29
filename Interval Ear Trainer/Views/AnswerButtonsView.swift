//
//  AnswerButtonsView.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2025/01/01.
//

import SwiftUI

struct IntervalAnswerButtonsView: View {
    
    var activeIntervals: Set<Int>
    var active: Bool
    var notes: [Int]
    @Binding var guesses: [String]
    var use_timer: Bool
    var portrait: Bool

    var body: some View {
        let activeIntAbs = activeIntervals.map{$0 > 0 ? $0 : -$0}
        let fontSize: Double = 30
        if portrait {
            HStack{
                ForEach(0..<4, id: \.self){ i in
                    VStack{
                        ForEach(0..<3, id: \.self){ j in
                            let thisInt = j*4+i+1
                            let reallyActive = activeIntAbs.contains(thisInt) && (active || (!use_timer && notes[0] != 0))
                            IntervalAnswerButtonView(intervalInt: thisInt, active: reallyActive, fontSize: fontSize, guesses: $guesses, notes: notes)
                        }
                    }.fixedSize(horizontal: false, vertical: true)
                }
            }.padding([.leading, .trailing, .bottom])
        } else {
            Grid {
                GridRow{
                    IntervalAnswerButtonView(intervalInt: 12, active: false, fontSize: fontSize, guesses: $guesses, notes: notes, visible: 0.0)
                    ForEach([1, 3], id: \.self){ thisInt in
                        let reallyActive = activeIntAbs.contains(thisInt) && (active || (!use_timer && notes[0] != 0))
                        IntervalAnswerButtonView(intervalInt: thisInt, active: reallyActive, fontSize: fontSize, guesses: $guesses, notes: notes).gridCellColumns(2)
                    }
                    IntervalAnswerButtonView(intervalInt: 12, active: false, fontSize: fontSize, guesses: $guesses, notes: notes, visible: 0.0).gridCellColumns(2)
                    ForEach([6, 8, 10], id: \.self){ thisInt in
                        let reallyActive = activeIntAbs.contains(thisInt) && (active || (!use_timer && notes[0] != 0))
                        IntervalAnswerButtonView(intervalInt: thisInt, active: reallyActive, fontSize: fontSize, guesses: $guesses, notes: notes).gridCellColumns(2)
                    }
                    IntervalAnswerButtonView(intervalInt: 12, active: false, fontSize: fontSize, guesses: $guesses, notes: notes, visible: 0.0).gridCellColumns(1)
                }
                GridRow{
                    ForEach(Array([12, 2, 4, 5, 7, 9, 11].enumerated()), id: \.offset){ _, thisInt in
                        let reallyActive = activeIntAbs.contains(thisInt) && (active || (!use_timer && notes[0] != 0))
                        IntervalAnswerButtonView(intervalInt: thisInt, active: reallyActive, fontSize: fontSize, guesses: $guesses, notes: notes).gridCellColumns(2)
                    }
                }
            }
        }
    }
}

struct IntervalAnswerButtonView: View {
    
    var intervalInt: Int
    var active: Bool
    var fontSize: Double
    @Binding var guesses: [String]
    var notes: [Int]
    var visible: Double = 1.0
    
    var body: some View {
        Text(interval_name(interval_int: intervalInt, oriented: false))
            .bold()
            .foregroundColor(Color(.systemGray))
            .font(.system(size: fontSize))
            .lineLimit(1)
            .scaledToFill()
            .minimumScaleFactor(0.5)
            .gridColumnAlignment(.leading)
            .padding().frame(maxWidth: .infinity, maxHeight: fontSize * 1.7)
            .overlay(RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 4)).opacity(active ? visible: 0.5 * visible).onTapGesture{
                    if (active) {
                        if (guesses.count < notes.count-1){
                            guesses.append(interval_name(interval_int: intervalInt, oriented: false))
                        }
                    }
                }
    }
}

struct TriadAnswerButtonsView: View {

    var params: Parameters
    var active: Bool
    @Binding var guesses: [String]
    var use_timer: Bool
    var notes: [Int]
    var portrait: Bool
    
    var body: some View {
        let activeTriads = params.active_qualities
        let nLines = portrait ? 2 : 1
        let nCol = Int(ceil(Double(TRIAD_KEYS.count) / Double(nLines)))
        HStack{
            ForEach(0..<nCol, id: \.self){ i in
                VStack{
                    ForEach(0..<nLines, id: \.self){ j in
                        let idx = j*nCol+i
                        if (idx < TRIAD_KEYS.count){
                            let thisTriad = TRIAD_KEYS[idx]
                            let active = activeTriads.contains(thisTriad) && (active || (!use_timer && notes[0] != 0))
                            Text(thisTriad.prefix(3)).bold().foregroundColor(Color(.systemGray)).font(.system(size: 30)).gridColumnAlignment(.leading).padding().frame(maxWidth: .infinity).overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.gray, lineWidth: 4)).opacity(active ? 1: 0.5).onTapGesture{
                                        if active {
                                            guesses = [thisTriad]
                                        }
                                    }
                        } else {
                            Text("Maj").bold().font(.system(size: 30)).gridColumnAlignment(.leading).padding().frame(maxWidth: .infinity).overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.gray, lineWidth: 4)).opacity(0.0)
                        }
                    }
                }.fixedSize(horizontal: false, vertical: true)
            }
        }.padding([.leading, .trailing, .bottom])
    }
}


struct ScaleDegreeAnswerButtonsView: View {

    var activeDegrees: Set<Int>
    var scale: String
    var active: Bool
    var notes: [Int]
    @Binding var guesses: [String]
    var use_timer: Bool
    var portrait: Bool
    
    var body: some View {
        let nLines = portrait ? 2 : 1
        let nCol = Int(ceil(Double(SCALE_DEGREES.values.count) / Double(nLines)))
        HStack{
            ForEach(0..<nCol, id: \.self){ i in
                VStack{
                    ForEach(0..<nLines, id: \.self){ j in
                        let idx = j*nCol+i
                        if (idx < SCALE_DEGREES.values.count) {
                            let thisDegree = SCALE_DEGREES.values.sorted()[idx]
                            let active = activeDegrees.contains(thisDegree) && (active || (!use_timer && notes[0] != 0))
                            Text(scale_degree_answer_str(degrees: [thisDegree], scale:scale)).bold().foregroundColor(Color(.systemGray)).font(.system(size: 30)).gridColumnAlignment(.leading).padding().frame(maxWidth: .infinity).overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.gray, lineWidth: 4)).opacity(active ? 1: 0.5)
                            .onTapGesture{
                                    if (active) {
                                        if (guesses.count < notes.count){
                                            guesses.append(scale_degree_answer_str(degrees: [thisDegree], scale:scale))
                                        }
                                    }
                            }
                        }
                        else{
                            Text("0").bold().foregroundColor(Color(.systemGray)).font(.system(size: 30)).gridColumnAlignment(.leading).padding().frame(maxWidth: .infinity).overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.gray, lineWidth: 4)).opacity(0)
                        }
                    }
                }.fixedSize(horizontal: false, vertical: true)
            }
        }.padding([.leading, .trailing, .bottom])
    }
}

