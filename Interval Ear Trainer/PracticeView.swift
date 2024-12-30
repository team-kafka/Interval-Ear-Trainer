//
//  PracticeView.swift
//  My First App
//
//  Created by Nicolas on 2024/12/04.
//

import SwiftUI

struct PracticeView: View {
    @State var params: Parameters
    var sequenceGenerator: SequenceGenerator
    @State private var button_lbl = Image(systemName: "play.circle")
    @State private var running = false
    @State private var use_timer = true
    @State private var answer: AnyView = AnyView(VStack{Text(" ")})
    @State private var answer_str = String(" ")
    
    @State var notes: [Int] = [0, 0]
    @State var n_notes:Int = 2
    @State var fixed_n_notes = false
    @State private var root_note: Int = 0
    
    @State private var timer: Timer?
    @State var answer_visible: Double = 1.0
    
    @State var chord: Bool = false
    @State var player = MidiPlayer()
    
    @Binding var dftDelay: Double
    @Binding var dftFilterStr: String

    var body: some View {
        
        NavigationStack{
            VStack {
                HStack{
                    Spacer()
                    NavigationLink(destination: ParametersView(params: $params).navigationBarBackButtonHidden(true).onAppear {stop()}){
                        Image(systemName: "gearshape.fill")
                    }.accentColor(Color(.systemGray)).padding([.trailing]).scaleEffect(1.5)
                }
                    HStack{
                        NumberOfNotesView(n_notes: $n_notes, notes: $notes, active: !fixed_n_notes, visible: !fixed_n_notes).padding().onChange(of: n_notes){
                            reset_state()
                            if (n_notes == 1) {chord = false}
                        }
                        TimerView(active: $use_timer).padding().onChange(of: use_timer){reset_state()}
                        ChordArpSwitchView(chord: $chord, active: (n_notes>1)).padding().onChange(of: chord){reset_state()}
                    }.scaleEffect(2.0)

                
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
                Spacer()
                answer.opacity(answer_visible).font(.system(size: 45)).foregroundStyle(Color(.systemGray))
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
            print(delay)
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
        if ((n_notes == 1) && (new_notes.count == 1)) {
            notes[0] = notes[1]
            notes[1] = new_notes[0]
        } else {
            notes = new_notes
        }
        return delay
    }
    
    func show_answer(){
        answer = answerView(answer_str: answer_str)
        answer_visible = 1.0
    }
        
    func reset_state(){
        stop()
        //answer = sequenceGenerator.generateAnswerView(answerStr: " ")
        answer_visible = 1.0
        notes = notes.map{$0 * 0}
    }
    
    func update_function(newParams: Parameters){
        dftDelay = newParams.delay
        dftFilterStr = sequenceGenerator.generateFilterString(params: newParams)
    }
}


        
