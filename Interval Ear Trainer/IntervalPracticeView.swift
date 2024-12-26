//
//  PracticeView.swift
//  My First App
//
//  Created by Nicolas on 2024/12/04.
//

import SwiftUI

struct IntervalPracticeView: View {
    @State var params: IntervalParameters
    @State private var button_lbl = Image(systemName: "play.circle")
    @State private var running = false
    @State private var use_timer = true
    @State private var answer = Text(" ")
    @State private var notes:[Int] = [0,0]
    @State private var timer: Timer?
    @State var answer_visible: Double = 1.0
    @State var n_notes:Int = 2
    @State var chord: Bool = false
    @State var player = MidiPlayer()
    @Binding var dftDelay: Double
    @Binding var dftFilterStr: String

    var body: some View {
        
        NavigationStack{
            VStack {
                VStack {
                    HStack{
                        Spacer()
                        NavigationLink(destination: IntervalParametersView(params: $params).navigationBarBackButtonHidden(true).onAppear {stop()}){
                            Image(systemName: "gearshape.fill")
                        }.accentColor(Color(.systemGray)).padding([.trailing]).scaleEffect(1.5)
                    }
                    //Spacer()
                    HStack{
                        NumberOfNotesView(n_notes: $n_notes, notes: $notes).padding().onChange(of: n_notes){
                            reset_state()
                            if (n_notes == 1) {chord = false}
                        }
                        TimerView(active: $use_timer).padding().onChange(of: use_timer){reset_state()}
                        ChordArpSwitchView(chord: $chord, active: (n_notes>1)).padding().onChange(of: chord){reset_state()}
                    }.scaleEffect(2.0)
                    //Spacer()
                }
                    //Spacer()
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
                                Text(midi_note_to_name(note_int: note)).opacity(answer_visible).foregroundStyle(Color(.systemGray))
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
                delay = 0
            }
        } else if chord{
            notes = draw_random_chord(params: params, n_notes: n_notes)
            player.playNotes(notes: notes, duration: params.delay * 0.5, chord: true)
            delay = params.delay * 0.5
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
        answer = Text(answerStr)
        answer_visible = 1.0
    }
        
    func reset_state(){
        stop()
        answer = Text(" ")
        answer_visible = 1.0
        notes = notes.map{$0 * 0}
    }
    
    func update_function(newParams: IntervalParameters){
        dftDelay = newParams.delay
        dftFilterStr = interval_filter_to_str(intervals: newParams.active_intervals)
    }
}



        
