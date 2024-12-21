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

struct PracticeView: View {
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
                
                HStack{
                    Spacer()
                    NavigationLink(destination: ParameterView(params: $params).navigationBarBackButtonHidden(true).onAppear {stop()}){
                        Image(systemName: "gearshape.fill")
                    }.accentColor(Color(.systemGray)).padding().scaleEffect(1.5)
                }
                Spacer()
                HStack{
                    Text("Number of notes").foregroundColor(Color(.systemGray))
                    Picker("", selection: $n_notes) {
                        ForEach(1..<5, id: \.self) {
                            Text("\($0)")
                        }
                    }.accentColor(Color(.systemGray)).onChange(of: n_notes){
                        stop()
                        notes = [Int](repeating: 0, count: max(2, n_notes))
                        answer = Text(" ")
                        answer_visible = 1.0
                    }
                    Text("Chord").foregroundColor(Color(.systemGray)).opacity(n_notes > 1 ? 1.0 : 0.0)
                    CheckBoxView(checked: $chord).opacity(n_notes > 1 ? 1.0 : 0.0)

                }.scaleEffect(1.2)
                
                Spacer()
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
        var answers = [String]()
        if chord{
            for i in notes[1...] {
                answers.append(interval_name(interval_int:i-notes[0], oriented: false, octave: false))
            }
        } else{
            for (e1, e2) in zip(notes, notes[1...]) {
                answers.append(interval_name(interval_int:e2-e1, oriented: true))
            }
        }
        answer = Text(answers.joined(separator: "  "))
        answer_visible = 1.0
    }
}

struct NoteButton : View{
    @Binding var running : Bool
    @Binding var params : Parameters
    @Binding var player : MidiPlayer
    var note : Int

    var body: some View {
        Image(systemName: "music.note").foregroundColor(Color(.systemGray)).padding().overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 4)).onTapGesture {
                  if ((note != 0) && !running){
                      player.playNotes(notes: [note], duration: 0.8)
                    }
                }.opacity(((note != 0) && !running) ? 1.0 : 0.5)
    }
}


struct ChordButton : View{
    @Binding var running : Bool
    @Binding var params : Parameters
    @Binding var player : MidiPlayer
    var notes : [Int]

    var body: some View {
        Image(systemName: "music.quarternote.3").foregroundColor(Color(.systemGray)).padding().overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 4)).onTapGesture {
                  if ((notes[0] != 0) && !running){
                      player.playNotes(notes: notes, duration: params.delay*0.5, chord: true)
                    }
                }.opacity(((notes[0] != 0) && !running) ? 1.0 : 0.5)
    }
}


struct CheckBoxView: View {
    @Binding var checked: Bool
    
    var body: some View {
        Image(systemName: checked ? "checkmark.square.fill" : "square")
            .foregroundColor(Color.secondary)
            .onTapGesture {
                checked.toggle()
            }
    }
}


#Preview {
    PracticeView()
}


        
