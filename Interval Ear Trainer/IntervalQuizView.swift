//
//  IntervalQuizzView.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2024/12/23.
//

import SwiftUI

struct IntervalQuizView: View {
    @State var params: IntervalParameters
    @State private var run_btn = Image(systemName: "play.circle")
    @State private var running = false
    @State private var answer = Text(" ")
    @State private var notes: [Int] = [0,0]
    @State private var timer: Timer?
    @State var answer_visible: Double = 1.0
    @State var n_notes:Int = 2
    @State var chord: Bool = false
    @State var use_timer: Bool = true

    @State var correct: Bool = false
    @State private var guess_str = Text(" ")
    @State private var guess: [Int] = [0]
    @Binding var dftDelay: Double
    @Binding var dftFilterStr: String

    @State var player = MidiPlayer()
    
    var body: some View {
        
        NavigationStack{
            VStack {
                HStack{
                    Spacer()
                    NavigationLink(destination: IntervalParametersView(params: $params).navigationBarBackButtonHidden(true).onAppear {stop()}){
                        Image(systemName: "gearshape.fill")
                    }.accentColor(Color(.systemGray)).scaleEffect(1.5).padding([.trailing])
                }
                Spacer()
                HStack{
                    NumberOfNotesView(n_notes: $n_notes, notes: $notes).padding().onChange(of: n_notes){
                        reset_state()
                        if (n_notes == 1) {chord = false}
                    }
                    TimerView(active: $use_timer).padding().onChange(of: use_timer){reset_state()}
                    ChordArpSwitchView(chord: $chord, active: (n_notes>1)).padding().onChange(of: chord){reset_state()}
                }.scaleEffect(2.0)
                Spacer()
                Spacer()
                HStack {
                    Spacer()
                    run_btn.resizable().scaledToFit().onTapGesture {
                        toggle_start_stop()
                    }.foregroundColor(Color(.systemGray))
                    Spacer()
                }
                Spacer()
                answer.opacity(answer_visible).font(.system(size: 45)).foregroundStyle(correct ? Color.green : Color.red)
                guess_str.foregroundColor(Color(.systemGray)).font(.system(size: 45))
                Spacer()
                AnswerButtonsView(loopFunction: self.loopFunction, params: params, running: running, notes: notes, guess_str: $guess_str, guess: $guess, use_timer: use_timer)
                Spacer()
            }
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            update_function(newParams: params)
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            stop()
        }
        
    }
    
    func toggle_start_stop() {
        running.toggle()
        if running {
            start()
        }
        else{
            stop()
        }
    }
    
    func start() {
        run_btn = Image(systemName: "pause.circle")
        running = true
        timer?.invalidate()
        loopFunction()
    }
    
    func stop(){
        timer?.invalidate()
        run_btn = Image(systemName: "play.circle")
        running = false
        notes = notes.map{$0 * 0}
        answer = Text(" ")
        guess_str = Text(" ")
        answer_visible = 1.0
    }

    func loopFunction() {
        var delay = params.delay * 0.5
        if (answer_visible == 1.0){
            correct = false
            answer_visible = 0.0
            guess_str = Text(" ")
            guess = [0]
            delay += play_sequence()
        } else{
            show_answer()
            notes[0] = notes[1]
        }
        if (use_timer){
            timer = Timer.scheduledTimer(withTimeInterval:delay, repeats: false) { t in
                loopFunction()
            }
        }
    }
    
    func play_sequence() -> Double {
        var delay: Double = 0.0
        if (n_notes == 1) {
            if (notes[0] == 0) {
                notes[0] = Int.random(in: params.lower_bound..<params.upper_bound)
                notes[1] = draw_new_note(prev_note: notes[0], params: params)
                player.playNotes(notes: notes, duration: params.delay*0.5)
                delay = params.delay * 0.5
            }
            else {
                notes[0] = notes[1]
                notes[1] = draw_new_note(prev_note: notes[0], params: params)
                player.playNotes(notes: [notes[1]], duration: params.delay*0.5)
            }
        } else if chord{
            notes = draw_random_chord(params: params, n_notes: n_notes)
            player.playNotes(notes: notes, duration: params.delay * 0.5, chord: true)
        } else {
            notes[0] = Int.random(in: params.lower_bound..<params.upper_bound)
            for (i, _) in notes[1...].enumerated(){
                notes[i+1] = draw_new_note(prev_note: notes[i], params: params)
            }
            let duration = params.delay_sequence
            player.playNotes(notes: notes, duration: duration, chord: false)
            delay = params.delay_sequence * Double(n_notes-1) * 0.5
        }
        return delay
    }
    
    func show_answer(){
        let answerStr = answer_string(notes: notes, chord: chord, oriented: !chord)
        let answerInt = answer_from_notes(notes: notes, chord: chord, oriented: false)
        print(answerInt)
        correct = (answerInt[...] == guess[1...])
        answer = Text(answerStr)
        answer_visible = 1.0
    }

    func reset_state(){
        stop()
        answer = Text(" ")
        answer_visible = 1.0
        guess_str = Text(" ")
        guess = [Int](repeating: 0, count: notes.count)
    }
    
    func update_function(newParams: IntervalParameters){
        dftDelay = newParams.delay
        dftFilterStr = interval_filter_to_str(intervals: newParams.active_intervals)
    }
}

struct AnswerButtonsView: View {
    public var loopFunction: (() -> Void)
    var params: IntervalParameters
    var running: Bool
    var notes: [Int]
    @Binding var guess_str: Text
    @Binding var guess: [Int]
    var use_timer: Bool
    
    @State private var timer: Timer?
    
    var body: some View {
        let activeIntAbs = params.active_intervals.map{$0 > 0 ? $0 : -$0}
        HStack{
            ForEach(0..<4){ i in
                VStack{
                    ForEach(0..<3){ j in
                        let thisInt = j*4+i+1
                        let active = (activeIntAbs.contains(thisInt) && running)
                        Text(interval_name(interval_int: thisInt, oriented: false)).bold().foregroundColor(Color(.systemGray)).font(.system(size: 30)).gridColumnAlignment(.leading).padding().frame(maxWidth: .infinity).overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.gray, lineWidth: 4)).opacity(active ? 1: 0.5).onTapGesture{
                                    if (active) {
                                        if (guess.count < notes.count){
                                            guess.append(thisInt)
                                        }
                                        guess_str = Text(answer_string(notes: guess, chord: true, oriented: false))
                                        if ((guess.count == notes.count) && !use_timer){
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
