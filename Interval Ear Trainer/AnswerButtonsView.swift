//
//  AnswerButtonsView.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2025/01/01.
//

import SwiftUI

struct IntervalAnswerButtonsView: View {
    public var loopFunction: (() -> Void)
    var activeIntervals: Set<Int>
    var running: Bool
    var notes: [Int]
    @Binding var guess_str: String
    @Binding var guess: [Int]
    var use_timer: Bool
    
    @State private var timer: Timer?
    
    var body: some View {
        let activeIntAbs = activeIntervals.map{$0 > 0 ? $0 : -$0}
        HStack{
            ForEach(0..<4){ i in
                VStack{
                    ForEach(0..<3){ j in
                        let thisInt = j*4+i+1
                        let active = activeIntAbs.contains(thisInt) && (running || (!use_timer && notes[0] != 0))
                        Text(interval_name(interval_int: thisInt, oriented: false)).bold().foregroundColor(Color(.systemGray)).font(.system(size: 30)).gridColumnAlignment(.leading).padding().frame(maxWidth: .infinity).overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.gray, lineWidth: 4)).opacity(active ? 1: 0.5).onTapGesture{
                                    if (active) {
                                        if (guess.count < notes.count-1){
                                            guess.append(thisInt)
                                        }
                                        guess_str = interval_answer_string(notes: [0] + guess, chord: true, oriented: false)
                                        if ((guess.count == notes.count-1) && !use_timer){
                                            set_timer()
                                        }
                                    }
                                }
                    
                    }
                }.fixedSize(horizontal: false, vertical: true)
            }
        }.padding()
    }
    
    func set_timer() {
        timer = Timer.scheduledTimer(withTimeInterval:0.2, repeats: false) { t in
            loopFunction()
            timer = Timer.scheduledTimer(withTimeInterval:0.6, repeats: false) { t in
                loopFunction()
            }
        }
    }
}

struct TriadAnswerButtonsView: View {
    public var loopFunction: (() -> Void)
    var params: Parameters
    var running: Bool
    @Binding var guess_str: String
    var use_timer: Bool
    var notes: [Int]
    
    @State private var timer: Timer?
    
    var body: some View {
        let activeTriads = params.active_qualities
        HStack{
            ForEach(0..<3){ i in
                VStack{
                    ForEach(0..<2){ j in
                        let idx = i*2+j
                        if (idx < TRIAD_KEYS.count){
                            let thisTriad = TRIAD_KEYS[idx]
                            let active = activeTriads.contains(thisTriad) && (running || (!use_timer && notes[0] != 0))
                            Text(thisTriad.prefix(3)).bold().foregroundColor(Color(.systemGray)).font(.system(size: 30)).gridColumnAlignment(.leading).padding().frame(maxWidth: .infinity).overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.gray, lineWidth: 4)).opacity(active ? 1: 0.5).onTapGesture{
                                        if active {
                                            guess_str = thisTriad
                                            if !use_timer {
                                                set_timer()
                                            }
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
        }.padding()
    }
    
    func set_timer() {
        timer = Timer.scheduledTimer(withTimeInterval:0.2, repeats: false) { t in
            loopFunction()
            timer = Timer.scheduledTimer(withTimeInterval:0.6, repeats: false) { t in
                loopFunction()
            }
        }
    }
}


struct ScaleDegreeAnswerButtonsView: View {
    public var loopFunction: (() -> Void)
    var activeDegrees: Set<Int>
    var scale: String
    @Binding var running: Bool
    var notes: [Int]
    @Binding var guess_str: String
    @Binding var guess: [Int]
    var use_timer: Bool
    
    @State private var timer: Timer?
    
    var body: some View {
        HStack{
            
            ForEach(0..<4){ i in
                VStack{
                    ForEach(0..<2){ j in
                        let idx = j*4+i
                        if (idx < SCALE_DEGREES.values.count) {
                            let thisDegree = SCALE_DEGREES.values.sorted()[idx]
                            let active = activeDegrees.contains(thisDegree) && (running || (!use_timer && notes[0] != 0))
                            Text(scale_degree_answer_str(degrees: [thisDegree], scale:scale)).bold().foregroundColor(Color(.systemGray)).font(.system(size: 30)).gridColumnAlignment(.leading).padding().frame(maxWidth: .infinity).overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.gray, lineWidth: 4)).opacity(active ? 1: 0.5)
                            .onTapGesture{
                                    if (active) {
                                        if (guess.count < notes.count){
                                            guess.append(thisDegree)
                                        }
                                        guess_str = scale_degree_answer_str(degrees: guess, scale:scale)
                                        if ((guess.count == notes.count) && !use_timer){
                                            set_timer()
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
        }.padding()
    }
    
    func set_timer() {
        timer = Timer.scheduledTimer(withTimeInterval:0.2, repeats: false) { t in
            loopFunction()
            timer = Timer.scheduledTimer(withTimeInterval:0.6, repeats: false) { t in
                loopFunction()
            }
        }
    }
}
