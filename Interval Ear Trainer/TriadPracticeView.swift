//
//  TriadsPracticeView.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2024/12/25.
//

import SwiftUI

struct TriadPracticeView: View {
    @State var params: TriadParameters
    @State private var button_lbl = Image(systemName: "play.circle")
    @State private var running = false
    @State private var chord = true
    @State private var use_timer = true
    @State private var root_note: Int = 0
    @State private var quality: String = ""
    @State private var inversion: String = ""
    @State private var voicing: String = ""
    @State private var answer = Text("")
    @State private var notes:[Int] = [0,0,0]
    @State private var timer: Timer?
    @State private var answer_visible: Double = 1.0
    
    @Binding var dftDelay: Double
    @Binding var dftFilterStr: String

    
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
                HStack{
                    ChordArpSwitchView(chord: $chord, active: true).padding().onChange(of: chord){reset_state()}
                    TimerView(active: $use_timer).padding().onChange(of: use_timer){reset_state()}
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
                    
                    VStack{
                        ChordButton(running: running, duration: params.delay * 0.5, player: $player, notes: notes, chord: chord, chord_delay: params.delay_arpeggio)
                        Text(" ").opacity(0.0)
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
            VStack(alignment: .leading){
                answer.font(.system(size: 40)).foregroundStyle(Color(.systemGray))
                Text(inversion).font(.system(size: 30)).foregroundStyle(Color(.systemGray))
                Text(voicing).font(.system(size: 30)).foregroundStyle(Color(.systemGray))
            }.opacity(answer_visible).padding()
            Spacer()
        
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
        if use_timer{
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
        if (use_timer){
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
        var delay: Double = 0.0
        let res = draw_random_triad(active_qualities: params.active_qualities, active_inversions: params.active_inversions, active_voicings: params.active_voicings, upper_bound: params.upper_bound, lower_bound: params.lower_bound)

        notes = res.0
        quality = (res.1)[0]
        inversion = (res.1)[1]
        voicing = (res.1)[2] + " position"
        root_note = res.2
        
        if chord {
            player.playNotes(notes: notes, duration: params.delay * 0.5 , chord: true)
        } else {
            player.playNotes(notes: notes, duration: params.delay_arpeggio, chord: false)
            delay = params.delay_arpeggio * 2.0 * 0.5 // x  n_notes - 1 (triad) and x 0.5 (tempo = 120)
        }
        return delay
    }
    
    func show_answer(){
        answer = Text(quality + " triad")
        answer_visible = 1.0
    }
        
    func reset_state(){
        stop()
        answer = Text("")
        voicing = ""
        inversion = ""
        answer_visible = 1.0
        notes = notes.map{$0 * 0}
    }
    
    func update_function(newParams: TriadParameters){
        dftDelay = newParams.delay
        dftFilterStr = triad_filters_to_str(active_qualities: newParams.active_qualities, active_inversions: newParams.active_inversions, active_voicings: newParams.active_voicings)
    }
}


