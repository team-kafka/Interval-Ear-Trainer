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
    @Binding var notes: [Int]
    @Binding var guesses: [String]
    var use_timer: Bool
    var portrait: Bool

    var body: some View {
        let activeIntAbs = activeIntervals.map{$0 > 0 ? $0 : -$0}
        let fontSize: Double = 30
        if portrait {
            Grid {
                GridRow{
                    ForEach([1, 2, 3, 4], id: \.self){ thisInt in
                        let reallyActive = activeIntAbs.contains(thisInt) && (active || (!use_timer && notes[0] != 0))
                        IntervalAnswerButtonView(intervalInt: thisInt, active: reallyActive, fontSize: fontSize, guesses: $guesses, notes: notes)
                    }
                }
                GridRow{
                    ForEach([5, 6, 7], id: \.self){ thisInt in
                        let reallyActive = activeIntAbs.contains(thisInt) && (active || (!use_timer && notes[0] != 0))
                        IntervalAnswerButtonView(intervalInt: thisInt, active: reallyActive, fontSize: fontSize, guesses: $guesses, notes: notes)
                    }
                    IntervalAnswerButtonView(intervalInt: 12, active: false, fontSize: fontSize, guesses: $guesses, notes: notes, visible: 0.0).gridCellColumns(1)
                }
                GridRow{
                    ForEach([8, 9, 10, 11], id: \.self){ thisInt in
                        let reallyActive = activeIntAbs.contains(thisInt) && (active || (!use_timer && notes[0] != 0))
                        IntervalAnswerButtonView(intervalInt: thisInt, active: reallyActive, fontSize: fontSize, guesses: $guesses, notes: notes)
                    }
                }
                GridRow{
                    ForEach([12], id: \.self){ thisInt in
                        let reallyActive = activeIntAbs.contains(thisInt) && (active || (!use_timer && notes[0] != 0))
                        IntervalAnswerButtonView(intervalInt: thisInt, active: reallyActive, fontSize: fontSize, guesses: $guesses, notes: notes)
                    }
                    IntervalAnswerButtonView(intervalInt: 12, active: false, fontSize: fontSize, guesses: $guesses, notes: notes, visible: 0.0).gridCellColumns(2)
                    DeleteButtonView(guesses: $guesses, fontSize: fontSize, answerSize: notes.count-1)
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
                    DeleteButtonView(guesses: $guesses, fontSize: fontSize, answerSize: notes.count-1).gridCellColumns(2)
                }
                GridRow{
                    ForEach(Array([12, 2, 4, 5, 7, 9, 11, 12].enumerated()), id: \.offset){ _, thisInt in
                        let reallyActive = activeIntAbs.contains(thisInt) && (active || (!use_timer && notes[0] != 0))
                        IntervalAnswerButtonView(intervalInt: thisInt, active: reallyActive, fontSize: fontSize, guesses: $guesses, notes: notes).gridCellColumns(2)
                    }
                }
            }
        }
    }
}

struct ButtonTextView: View {
    var label: String
    var fontSize: CGFloat
    var color: Color = Color(.systemGray)
    
    var body: some View {
        Text(label)
            .bold()
            .foregroundColor(color)
            .font(.system(size: fontSize))
            .lineLimit(1)
            .scaledToFill()
            .minimumScaleFactor(0.5)
            .gridColumnAlignment(.leading)
            .padding().frame(maxWidth: .infinity, maxHeight: fontSize * 1.7)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(color, lineWidth: 4))
            .contentShape(Rectangle())
    }
}
    
struct DeleteButtonView: View {
    @Binding var guesses: [String]
    var fontSize: Double
    var answerSize: Int
    
    init(guesses: Binding<[String]>, fontSize: Double, answerSize: Int) {
        _guesses = .init(projectedValue: guesses)
        self.fontSize = fontSize
        self.answerSize = answerSize
    }
    
    var body: some View {
        let active = guesses.count > 0 && guesses.count < answerSize
        ButtonTextView(label:"X", fontSize: fontSize)
            .opacity(active ? 1 : 0.5).onTapGesture{
                    if active { guesses.removeLast() }
                }
    }
}


struct IntervalResultView: View {
    
    var fontSize: Double
    var gridSize: Int
    @Binding var guesses: [String]
    @Binding var answers: [String]
    @Binding var answerVisible: Double
    var oriented: Bool
    
    var body: some View {
        let guess_eval = evaluate_guess(guess: guesses, answer: answers)
        Grid(horizontalSpacing: 1, verticalSpacing: 1){
            GridRow {
                ForEach(0...gridSize-1, id: \.self) { i in
                    let ans = i < answers.count ? answers[i] : " "
                    let color = i < guess_eval.count ? ANSWER_COLORS[guess_eval[i]]! : Color(.systemGray)
                    Text(short_answer(answer: ans, oriented: oriented))
                        .bold()
                        .foregroundColor(color)
                        .font(.system(size: fontSize))
                        .lineLimit(1)
                        .scaledToFill()
                        .minimumScaleFactor(0.5)
                        .gridColumnAlignment(.leading)
                        .frame(maxWidth: fontSize * 1.7, maxHeight: fontSize * 1.3)
                }
            }.opacity(answerVisible)
            GridRow {
                ForEach(0...gridSize-1, id: \.self) { i in
                    let guess = i < guesses.count ? guesses[i] : " "
                    Text(guess)
                        .bold()
                        .foregroundColor(Color(.systemGray))
                        .font(.system(size: fontSize))
                        .lineLimit(1)
                        .scaledToFill()
                        .minimumScaleFactor(0.5)
                        .gridColumnAlignment(.leading)
                        .frame(maxWidth: fontSize * 1.7, maxHeight: fontSize * 1.3)
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
        ButtonTextView(label:interval_name(interval_int: intervalInt, oriented: false), fontSize: fontSize)
            .opacity(active ? visible: 0.5 * visible).onTapGesture{
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
        Grid {
            GridRow{
            }
        }
        let nLines = portrait ? 2 : 1
        let nCol = Int(ceil(Double(SCALE_DEGREES.values.count+1) / Double(nLines)))
        HStack{
            ForEach(0..<nCol, id: \.self){ i in
                VStack{
                    ForEach(0..<nLines, id: \.self){ j in
                        let idx = j*nCol+i
                        if (idx < SCALE_DEGREES.values.count) {
                            let thisDegree = SCALE_DEGREES.values.sorted()[idx]
                            let reallyActive = activeDegrees.contains(thisDegree) && (active || (!use_timer && notes[0] != 0))
                            ButtonTextView(label:scale_degree_answer_str(degrees: [thisDegree], scale:scale), fontSize: 30).opacity(reallyActive ? 1: 0.5)
                            .onTapGesture{
                                if (reallyActive) {
                                    if (guesses.count < notes.count){
                                        guesses.append(scale_degree_answer_str(degrees: [thisDegree], scale:scale))
                                    }
                                }
                            }
                        }
                        else{
                            DeleteButtonView(guesses: $guesses, fontSize: 30, answerSize: notes.count)
                        }
                    }
                }.fixedSize(horizontal: false, vertical: true)
            }
        }.padding([.leading, .trailing, .bottom])
    }
}
