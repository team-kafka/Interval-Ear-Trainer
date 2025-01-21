//
//  PracticeView.swift
//  My First App
//
//  Created by Nicolas on 2024/12/04.
//

import SwiftUI

struct PracticeView: View {
    @State var params: Parameters
    
    @State private var running: Bool
    @State private var use_timer: Bool
    @State private var answer_str: String
    
    @State var notes: [Int]
    @State var fixed_n_notes: Bool
    @State var chord_active: Bool
    @State private var root_note: Int
    @State var answer_visible: Double
    
    @Binding var dftParams: String

    @State private var timer: Timer?
    @State var player = MidiPlayer()
    var sequenceGenerator: SequenceGenerator

    
    init(params: Parameters, dftParams: Binding<String>, fixed_n_notes: Bool=false, chord_active: Bool=true){
        _params = .init(initialValue: params)
        if (params.type == .interval) {
            self.sequenceGenerator = IntervalGenerator()
            _answer_str = .init(initialValue: " ")
        } else if (params.type == .triad){
            self.sequenceGenerator = TriadGenerator()
            _answer_str = .init(initialValue: " / / ")
        } else {
            self.sequenceGenerator = ScaleDegreeGenerator()
            _answer_str = .init(initialValue: " ")
        }
        _running = .init(initialValue: false)
        _answer_visible = .init(initialValue: 1.0)
        _notes = .init(initialValue: [Int].init(repeating: 0, count: params.n_notes))
        _fixed_n_notes = .init(initialValue: fixed_n_notes)
        _chord_active = .init(initialValue: chord_active)
        _root_note = .init(initialValue: 0)
        _use_timer = .init(initialValue: true)
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
                NoteButtonsView(params: params, player: $player, notes: notes, root_note: root_note, chord: params.is_chord, running: running, answer_visible: answer_visible, fixed_n_notes: fixed_n_notes, chord_active:chord_active, reset_state: self.reset_state, stop: self.stop)
                if (params.type == .scale_degree) {
                    ScaleChooserView(params: $params, player: $player, timer:$timer, running:$running, reset_state: self.reset_state)
                }
                Spacer()
                answerView().opacity(answer_visible).font(.system(size: 45)).foregroundStyle(Color(.systemGray))
                Spacer()
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
        let answerArray = answer_str.split(separator: "/")
        if answerArray.count < 2{
            return AnyView(VStack{Text(answer_str).font(.system(size: 45))})
        } else {
            return AnyView(VStack{
                Text(answerArray[0]).font(.system(size: 40))
                ForEach(Array(answerArray[1...].enumerated()), id: \.offset){_, ans in
                    Text(ans).font(.system(size: 30))
                }
            })
        }
    }

    func toggle_start_stop() {
        if use_timer {
            if !running {
                start()
            }
            else{
                stop()
            }
        } else {
            start()
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
    }

    func loopFunction() {
        var delay = params.delay * 0.5
        if (answer_visible == 1.0){
            answer_visible = 0.0
            delay += play_sequence()
        } else {
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
        var answers: [String]
        
        (new_notes, duration, delay, answers, root_note) = sequenceGenerator.generateSequence(params: params, n_notes:params.n_notes, chord:params.is_chord, prev_note:params.n_notes == 1 ? notes.last ?? 0 : notes.first ?? 0)
        answer_str = answers.joined(separator: " ")
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
        answer_str = params.type == .triad ? " / / " : " "
        answer_visible = 1.0
        notes = notes.map{$0 * 0}
    }
    
    func save_dft_params(newParams: Parameters){
        dftParams = newParams.encode()
    }
}

                  
