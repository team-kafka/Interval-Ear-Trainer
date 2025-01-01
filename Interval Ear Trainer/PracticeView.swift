//
//  PracticeView.swift
//  My First App
//
//  Created by Nicolas on 2024/12/04.
//

import SwiftUI

struct PracticeView: View {
    @State var params: Parameters
    
    @State private var button_lbl: Image
    @State private var running: Bool
    @State private var use_timer: Bool
    @State private var answer_str: String
    
    @State var notes: [Int]
    @State var n_notes:Int
    @State var fixed_n_notes: Bool
    @State var chord_active: Bool
    @State private var root_note: Int
    
    @State var answer_visible: Double
    @State var chord: Bool = false
    
    @Binding var dftDelay: Double
    @Binding var dftFilterStr: String

    @State private var timer: Timer?
    @State var player = MidiPlayer()
    var sequenceGenerator: SequenceGenerator

    
    init(params: Parameters, dftDelay: Binding<Double>, dftFilterStr: Binding<String>, n_notes: Int=2, fixed_n_notes: Bool=false, chord_active: Bool=true, chord: Bool=false){
        _params = .init(initialValue: params)
        if (params.type == .interval) {
            self.sequenceGenerator = IntervalGenerator()
        } else if (params.type == .triad){
            self.sequenceGenerator = TriadGenerator()
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
        _root_note = .init(initialValue: 0)
        _chord = .init(initialValue: chord)
        _use_timer = .init(initialValue: true)
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
                Grid{
                    GridRow{
                        if chord{
                            VStack{
                                ChordButton(running: running, duration: params.delay * 0.5, player: $player, notes: notes, chord: chord, chord_delay: params.delay_sequence)
                                Text(" ").opacity(0.0)
                            }
                        }
                        ForEach(notes, id: \.self) { note in
                            VStack{
                                NoteButton(running: running, player: $player, note: note)
                                Text(midi_note_to_name(note_int: note)).opacity(answer_visible).foregroundStyle(Color(.systemGray)).fontWeight((note == root_note) ? .bold : .regular)
                            }
                        }
                    }
                }
                if (params.type == .scale_degree) {
                    ScaleChooserView(params: $params, player: $player, reset_state: self.reset_state)
                }
                Spacer()
                answerView(answer_str: answer_str).opacity(answer_visible).font(.system(size: 45)).foregroundStyle(Color(.systemGray))
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
    
    func answerView(answer_str: String) -> AnyView {
        let answerArray = answer_str.split(separator: "/")
        if answerArray.count < 2{
            return AnyView(VStack{Text(answer_str).font(.system(size: 45))})
        } else {
            return AnyView(VStack{
                Text(answerArray[0]).font(.system(size: 40))
                ForEach(answerArray[1...], id: \.self){ans in
                    Text(ans).font(.system(size: 30))
                }
            })
        }
    }
    
    func toggle_start_stop() {
        if use_timer {
            running.toggle()
            if running {
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
        var delay: Double = 0
        var duration: Double = 0
        var new_notes: [Int] = []
        
        (new_notes, duration, delay, answer_str, root_note) = sequenceGenerator.generateSequence(params: params, n_notes:n_notes, chord:chord, prev_note:notes.last ?? 0)
        player.playNotes(notes: new_notes, duration: duration, chord: chord)
        notes = new_notes
        
        return delay
    }
    
    func show_answer(){
        answer_visible = 1.0
    }
        
    func reset_state(){
        stop()
        answer_visible = 1.0
        notes = notes.map{$0 * 0}
    }
    
    func update_function(newParams: Parameters){
        dftDelay = newParams.delay
        dftFilterStr = sequenceGenerator.generateFilterString(params: newParams)
    }
}


