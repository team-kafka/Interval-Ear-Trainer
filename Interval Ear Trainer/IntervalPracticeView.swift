//
//  PracticeView.swift
//  My First App
//
//  Created by Nicolas on 2024/12/04.
//

import SwiftUI

enum playMode {
    case melodic
    case harmonic
}

struct IntervalPracticeView: View {
    @State var params = Parameters.init_value
    @State private var button_lbl = Image(systemName: "play.circle")
    @State private var running = false
    @State private var answer = Text(" ")
    @State private var notes:[Int] = [0,0]
    @State private var timer: Timer?
    @State var answer_visible: Double = 1.0
    @State var n_notes:Int = 2
    @State var chord: Bool = false

    @State var player = MidiPlayer()
    
    var body: some View {
        
        NavigationStack{
            VStack {
                VStack {
                    HStack{
                        Spacer()
                        NavigationLink(destination: ParameterView(params: $params).navigationBarBackButtonHidden(true).onAppear {stop()}){
                            Image(systemName: "gearshape.fill")
                        }.accentColor(Color(.systemGray)).padding([.trailing]).scaleEffect(1.5)
                    }
                    //Spacer()
                    HStack{
                        NumberOfNotesView(n_notes: $n_notes, notes: $notes).padding().onChange(of: n_notes){
                            reset_state()
                            if (n_notes == 1) {chord = false}
                        }
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
                                ChordButton(running: $running, params: $params, player: $player, notes: notes)
                                Text(" ").opacity(0.0)
                            }
                        }
                        ForEach(notes, id: \.self) { note in
                            VStack{
                                NoteButton(running: $running, params: $params, player: $player, note: note)
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
        button_lbl = Image(systemName: "pause.circle")
        running = true
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
        } else{
            show_answer()
        }
        timer = Timer.scheduledTimer(withTimeInterval:delay, repeats: false) { t in
            loopFunction()
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
}


#Preview {
    IntervalPracticeView()
}


        
