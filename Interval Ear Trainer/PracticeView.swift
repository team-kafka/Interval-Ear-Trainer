//
//  PracticeView.swift
//  My First App
//
//  Created by Nicolas on 2024/12/04.
//

import SwiftUI

struct PracticeView: View {
    @State var params  = Parameters.init_value
    @State private var button_lbl = Image(systemName: "play.circle")
    @State private var running = false
    @State private var answer = Text(" ")
    @State private var notes:[Int] = [0,0]
    @State private var timer: Timer?
    @State var answer_visible: Double = 1.0
    @State var n_notes:Int = 2
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
                }.scaleEffect(1.5)
                
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
                        ForEach(notes, id: \.self) { note in
                            NoteButton(running: $running, params: $params, player: $player, note: note)
                        }
                    }
                }
                answer.opacity(answer_visible).font(.system(size: 50)).foregroundStyle(Color(.systemGray))
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
    
    func onTickSingleNote() {
        if ((notes[1] == 0) && (notes[0] == 0) ){
            answer_visible = 0
            notes[0] = Int.random(in: params.lower_bound..<params.upper_bound)
            player.playNote(note: notes[0], duration: params.delay*0.45)
        }
        else if ((notes[1] == 0) && (notes[0] != 0) ){
            notes[1] = draw_new_note(prev_note: notes[0], params: params)
            player.playNote(note: notes[1], duration: params.delay*0.45)
        } else if (answer_visible == 0){
            answer = Text("\(interval_name(interval_int: notes[1]-notes[0], oriented: true))")
            answer_visible = 1
        } else{
            answer_visible = 0
            notes[0] = notes[1]
            notes[1] = draw_new_note(prev_note: notes[0], params: params)
            player.playNote(note: notes[1], duration: params.delay*0.45)
        }
    }
    
    func onTickMultipleNote() {
        
        if (answer_visible == 0.0){
            var answers = [String]()
            for (e1, e2) in zip(notes, notes[1...]) {
                answers.append(interval_name(interval_int:e2-e1, oriented: true))
            }
            answer = Text(answers.joined(separator: "  "))
            answer_visible = 1.0
        } else {
            answer_visible = 0.0
            notes[0] = Int.random(in: params.lower_bound..<params.upper_bound)
            for (i, _) in notes[1...].enumerated(){
                notes[i+1] = draw_new_note(prev_note: notes[i], params: params)
            }
            player.playNotes(notes: notes, duration: 0.8)
        }
    }

    func start() {
        button_lbl = Image(systemName: "pause.circle")
        running = true
        timer?.invalidate()
        if (n_notes == 1){
            onTickSingleNote()
            timer = Timer.scheduledTimer(withTimeInterval:params.delay*0.5, repeats: true) { t in
                onTickSingleNote()
            }
        } else{
            onTickMultipleNote()
            timer = Timer.scheduledTimer(withTimeInterval:params.delay*0.7, repeats: true) { t in
                onTickMultipleNote()
            }
        }
    }
    
    func stop(){
        button_lbl = Image(systemName: "play.circle")
        running = false
        timer?.invalidate()
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
                .stroke(.gray, lineWidth: 4)).padding().onTapGesture {
                  if ((note != 0) && !running){
                      player.playNote(note: note, duration: 0.8)
                    }
                }.opacity(((note != 0) && !running) ? 1.0 : 0.5)
    }
}


#Preview {
    PracticeView()
}


        
