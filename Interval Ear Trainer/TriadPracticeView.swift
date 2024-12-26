//
//  TriadsPracticeView.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2024/12/25.
//

import SwiftUI

struct TriadPracticeView: View {
    @State var params: TriadParameters = TriadParameters()
    @State private var button_lbl = Image(systemName: "play.circle")
    @State private var running = false
    @State private var root_note: Int = 0
    @State private var quality: String = " "
    @State private var inversion: String = " "
    @State private var voicing: String = " "
    @State private var answer = Text(" ")
    @State private var notes:[Int] = [0,0,0]
    @State private var timer: Timer?
    @State private var answer_visible: Double = 1.0
    
    
    @State var player = MidiPlayer()
    
    
    var body: some View {
        
        NavigationStack{
            VStack {
                HStack{
                 Spacer()
                NavigationLink(destination: TriadParametersView(params: $params).navigationBarBackButtonHidden(true).onAppear {stop()}){
                Image(systemName: "gearshape.fill")
                 }.accentColor(Color(.systemGray)).padding([.trailing]).scaleEffect(1.5)
                }
                //Spacer()
                
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
                    
                    VStack{
                        ChordButton(running: running, duration: params.delay * 0.5, player: $player, notes: notes)
                        Text(" ").opacity(0.0)
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
            VStack(alignment: .leading){
                answer.font(.system(size: 40)).foregroundStyle(Color(.systemGray))
                Text(inversion).font(.system(size: 40)).foregroundStyle(Color(.systemGray))
                Text(voicing).font(.system(size: 40)).foregroundStyle(Color(.systemGray))
            }.opacity(answer_visible).padding()
            Spacer()
        
    }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            //update_function(newParams: params)
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
        let res = draw_random_triad(params: params)

        notes = res.0
        quality = (res.1)[0]
        inversion = (res.1)[1]
        voicing = (res.1)[2] + " voicing"
        root_note = res.2
        
        player.playNotes(notes: notes, duration: params.delay * 0.5, chord: true)
        delay = params.delay * 0.5

        return delay
    }
    
    func show_answer(){
        let note_name = midi_note_to_name(note_int: root_note)
        let test = note_name.replacing(/[0-9]+/, with: "")
        answer = Text(test + " " + quality + " triad")
        answer_visible = 1.0
    }
        
    func reset_state(){
        stop()
        answer = Text(" ")
        answer_visible = 1.0
        notes = notes.map{$0 * 0}
    }
    
    //func update_function(newParams: IntervalParameters){
    //    dftDelay = newParams.delay
    //    dftFilterStr = interval_filter_to_str(intervals: newParams.active_intervals)
    //}
}



        

#Preview {
    TriadPracticeView()
}
