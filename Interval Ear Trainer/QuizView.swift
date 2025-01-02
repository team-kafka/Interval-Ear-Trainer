//
//  IntervalQuizzView.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2024/12/23.
//

import SwiftUI

struct QuizView: View { // find a way to reuse commmon code with practice view
    @State var params: Parameters
    
    @State private var button_lbl: Image
    @State private var running: Bool
    @State var use_timer: Bool
    @State private var answer_str: String
    
    @State private var notes: [Int]
    @State var n_notes:Int
    @State var fixed_n_notes: Bool
    @State var chord_active: Bool
    
    @State var correct: Bool
    @State private var guess_str: String
    @State private var guess: [Int]
    @State var answer_visible: Double

    @State private var timer: Timer?
    
    @State var chord: Bool
    

    @Binding var dftDelay: Double
    @Binding var dftFilterStr: String

    @State var player: MidiPlayer
    var sequenceGenerator: SequenceGenerator

    
    init(params: Parameters, dftDelay: Binding<Double>, dftFilterStr: Binding<String>, n_notes: Int=2, fixed_n_notes: Bool=false,  chord_active: Bool=true, chord: Bool=false){
        _params = .init(initialValue: params)
        if (params.type == .interval) {
            self.sequenceGenerator = IntervalGenerator()
        } else if (params.type == .triad){
            self.sequenceGenerator = TriadGenerator()
        } else  if (params.type == .scale_degree){
            self.sequenceGenerator = ScaleDegreeGenerator()
        } else {
            self.sequenceGenerator = ScaleDegreeGenerator()
        }
        _button_lbl = .init(initialValue: Image(systemName: "play.circle"))
        _running = .init(initialValue: false)
        _answer_str = .init(initialValue: " ")
        _answer_visible = .init(initialValue: 1.0)
        _n_notes = .init(initialValue: n_notes)
        _notes = .init(initialValue: [Int].init(repeating: 0, count: n_notes))
        _fixed_n_notes = .init(initialValue: fixed_n_notes)
        _chord_active = .init(initialValue: chord_active)
        _chord = .init(initialValue: chord)
        _use_timer = .init(initialValue: true)
        _correct = .init(initialValue: false)
        _guess_str = .init(initialValue: " ")
        _guess = .init(initialValue: [])
        _player = .init(initialValue: MidiPlayer())
        _timer = .init(initialValue: nil)
        _dftDelay = .init(projectedValue: dftDelay)
        _dftFilterStr = .init(projectedValue: dftFilterStr)
    }
    
    var body: some View {
        
        NavigationStack{
            VStack {
                QuickParamButtonsView(params: $params, notes: $notes, n_notes: $n_notes, chord: $chord, use_timer: $use_timer, fixed_n_notes: $fixed_n_notes, chord_active:$chord_active, reset_state: self.reset_state, stop: self.stop)
                HStack {
                    Spacer()
                    button_lbl.resizable().scaledToFit().onTapGesture {
                        toggle_start_stop()
                    }.foregroundColor(Color(.systemGray))
                    Spacer()
                }
                if (params.type == .scale_degree) {
                    ScaleChooserView(params: $params, player: $player, timer:$timer, reset_state: self.reset_state)
                }
                Spacer()
                answerView(answer: answer_str).opacity(answer_visible).foregroundStyle(correct ? Color.green : Color.red)
                Text(guess_str).foregroundColor(Color(.systemGray)).font(.system(size: 40))
                Spacer()
                if (params.type == .interval) {
                    IntervalAnswerButtonsView(loopFunction: self.loopFunction, activeIntervals: params.active_intervals, running: running, notes: notes, guess_str: $guess_str, guess: $guess, use_timer: use_timer)
                } else if (params.type == .triad) {
                    TriadAnswerButtonsView(loopFunction: self.loopFunction, params: params, running: running, guess_str: $guess_str, use_timer: use_timer)
                } else if (params.type == .scale_degree) {
                    ScaleDegreeAnswerButtonsView(loopFunction: self.loopFunction, activeDegrees: params.active_scale_degrees, scale:params.scale, running: running, notes: notes, guess_str: $guess_str, guess: $guess, use_timer: use_timer)
                }
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
    
    func short_answer(answer: String, oriented: Bool = true) -> String {
        let rv = String(answer.split(separator: "/")[0])
        if !oriented {
            return rv.replacingOccurrences(of: "↑", with: "").replacingOccurrences(of: "↓", with: "")
        }
        return rv
    }
    
    func answerView(answer: String) -> AnyView {
        return AnyView(Text(short_answer(answer: answer)).font(.system(size: 40)))
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
        if use_timer{
            button_lbl = Image(systemName: "pause.circle")
            running = true
        }
        timer?.invalidate()
        loopFunction()
    }
    
    func stop(){
        timer?.invalidate()
        button_lbl = Image(systemName: "play.circle")
        running = false
        notes = notes.map{$0 * 0}
        answer_str = " "
        guess_str = " "
        answer_visible = 1.0
    }

    func loopFunction() {
        var delay = params.delay * 0.5
        if (answer_visible == 1.0){
            correct = false
            answer_visible = 0.0
            guess_str = " "
            guess = []
            delay += play_sequence()
        } else{
            show_answer()
        }
        if (use_timer){
            timer = Timer.scheduledTimer(withTimeInterval:delay, repeats: false) { t in
                loopFunction()
            }
        }
    }
    
    func play_sequence() -> Double {
        var delay: Double = 0
        var duration: Double = 0
        var new_notes: [Int] = []
        
        (new_notes, duration, delay, answer_str, _) = sequenceGenerator.generateSequence(params: params, n_notes:n_notes, chord:chord, prev_note:notes.last ?? 0)
        player.playNotes(notes: new_notes, duration: duration, chord: chord)
        notes = new_notes
        
        return delay
    }
    
    func show_answer(){
        correct = short_answer(answer: answer_str, oriented: false) == guess_str
        answer_visible = 1.0
    }

    func reset_state(){
        stop()
        answer_visible = 1.0
        guess_str = " "
        guess = [Int](repeating: 0, count: notes.count)
    }
    
    func update_function(newParams: Parameters){
        dftDelay = newParams.delay
        dftFilterStr = sequenceGenerator.generateFilterString(params: newParams)
    }
}
