//
//  IntervalQuizzView.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2024/12/23.
//

import SwiftUI

let answer_colors: [AnswerType: Color] = [
    .correct: Color.green,
    .incorrect: Color.red,
    .timeout: Color.orange
]

struct QuizView: View {
    @State var params: Parameters
    
    @State private var running: Bool
    @State var use_timer: Bool
    @State private var answers: [String]

    @State private var notes: [Int]
    @State var fixed_n_notes: Bool
    @State var chord_active: Bool
    
    @State private var guesses: [String]
    @State var answer_visible: Double

    @State private var timer: Timer?
    
    @Binding var dftParams: String

    @State var player: MidiPlayer
    var sequenceGenerator: SequenceGenerator

    
    init(params: Parameters, dftParams: Binding<String>, n_notes: Int=2, fixed_n_notes: Bool=false,  chord_active: Bool=true, chord: Bool=false){
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
        _running = .init(initialValue: false)
        _answers = .init(initialValue: [])
        _answer_visible = .init(initialValue: 1.0)
        _notes = .init(initialValue: [Int].init(repeating: 0, count: params.n_notes))
        _fixed_n_notes = .init(initialValue: fixed_n_notes)
        _chord_active = .init(initialValue: chord_active)
        _use_timer = .init(initialValue: true)
        _guesses = .init(initialValue: [])
        _player = .init(initialValue: MidiPlayer())
        _timer = .init(initialValue: nil)
        _dftParams = .init(projectedValue: dftParams)
    }
    
    var body: some View {
        
        NavigationStack{
            VStack {
                QuickParamButtonsView(params: $params, notes: $notes, n_notes: $params.n_notes, chord: $params.is_chord, use_timer: $use_timer, fixed_n_notes: $fixed_n_notes, chord_active:$chord_active, reset_state: self.reset_state, stop: self.stop)
                HStack {
                    Spacer()
                    (running ? Image(systemName: "pause.circle") : Image(systemName: "play.circle")).resizable().scaledToFit().onTapGesture {
                        toggle_start_stop()
                    }.foregroundColor(Color(.systemGray))
                    Spacer()
                }
                if (params.type == .scale_degree) {
                    ScaleChooserView(params: $params, player: $player, timer:$timer, running:$running, reset_state: self.reset_state)
                }
                Spacer()
                answerView().opacity(answer_visible)
                guessView()
                Spacer()
                if (params.type == .interval) {
                    IntervalAnswerButtonsView(loopFunction: self.loopFunction, activeIntervals: params.active_intervals, running: (running && (answer_visible==0.0)), notes: notes, guesses: $guesses, use_timer: use_timer)
                } else if (params.type == .triad) {
                    TriadAnswerButtonsView(loopFunction: self.loopFunction, params: params, running: (running && (answer_visible==0.0)), guesses: $guesses, use_timer: use_timer, notes: notes)
                } else if (params.type == .scale_degree) {
                    ScaleDegreeAnswerButtonsView(loopFunction: self.loopFunction, activeDegrees: params.active_scale_degrees, scale:params.scale, running:  (running && (answer_visible==0.0)), notes: notes, guesses: $guesses, use_timer: use_timer)
                }
            }
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            save_dft_params(newParams: params)
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            stop()
        }
    }
    
    func answerView() -> AnyView {
        let guess_eval = evaluate_guess(guess: guesses, answer: answers)
        return AnyView(
            HStack{
                Text(" ").font(.system(size: 40))
                ForEach(Array(answers.enumerated()), id: \.offset) { i, ans in
                    Text(short_answer(answer: ans)).font(.system(size: 40)).foregroundStyle(answer_colors[guess_eval[i]]!)
                }
            })
    }
    
    func guessView() -> AnyView {
        return AnyView(
            HStack{
                Text(" ").font(.system(size: 40))
                ForEach(Array(guesses), id: \.self) { g in
                    Text(short_answer(answer: g)).foregroundColor(Color(.systemGray)).font(.system(size: 40))
                }
            })
    }
    
    func toggle_start_stop() {
        if !running {
            start()
        }
        else{
            stop()
        }
    }
    
    func start() {
        timer?.invalidate()
        running = use_timer
        if (params.type == .scale_degree && notes[0] == 0) {
            player.playNotes(notes: scale_notes(scale: params.scale, key: params.key, upper_bound: params.upper_bound, lower_bound: params.lower_bound), duration: SCALE_DELAY)
            timer = Timer.scheduledTimer(withTimeInterval:SCALE_DELAY * 9, repeats: false) { t in
                self.loopFunction()
            }
        } else {
            self.loopFunction()
        }
    }
    
    func stop(){
        timer?.invalidate()
        running = false
        notes = notes.map{$0 * 0}
        answers = []
        guesses = []
        answer_visible = 1.0
    }

    func loopFunction() {
        var delay = params.delay * 0.5
        if (answer_visible == 1.0){
            answer_visible = 0.0
            guesses = []
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
        var delay: Double
        var duration: Double
        var new_notes: [Int]
        
        (new_notes, duration, delay, answers, _) = sequenceGenerator.generateSequence(params: params, n_notes:params.n_notes,                 chord:params.is_chord, prev_note:params.n_notes == 1 ? notes.last ?? 0 : notes.first ?? 0)
        if ((params.n_notes == 1) && (notes[0] != 0)) {
         player.playNotes(notes: [new_notes.last!], duration: duration, chord: params.is_chord)
        } else {
         player.playNotes(notes: new_notes, duration: duration, chord: params.is_chord)
        }
        notes = new_notes
        return delay
    }
    
    func show_answer(){
        answer_visible = 1.0
    }

    func reset_state(){
        stop()
    }

    func save_dft_params(newParams: Parameters){
        dftParams = newParams.encode()
    }
}
