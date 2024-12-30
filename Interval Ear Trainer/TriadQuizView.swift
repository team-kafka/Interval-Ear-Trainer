//
//  TriadQuizView.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2024/12/26.
//

import SwiftUI

struct TriadQuizView: View {
    @State var params: Parameters
    @State private var run_btn = Image(systemName: "play.circle")
    @State private var running = false
    @State private var answer = Text(" ")
    @State private var notes: [Int] = [0,0,0]
    @State private var quality: String = ""
    @State private var timer: Timer?
    @State var answer_visible: Double = 1.0
    @State var chord: Bool = true
    @State var use_timer: Bool = true

    @State var correct: Bool = false
    @State private var guess_str = " "

    @Binding var dftDelay: Double
    @Binding var dftFilterStr: String

    @State var player = MidiPlayer()
    
    var body: some View {
        
        NavigationStack{
            VStack {
                HStack{
                    Spacer()
                    NavigationLink(destination: ParametersView(params: $params).navigationBarBackButtonHidden(true).onAppear {stop()}){
                        Image(systemName: "gearshape.fill")
                    }.accentColor(Color(.systemGray)).scaleEffect(1.5).padding([.trailing])
                }
                Spacer()
                HStack{
                    TimerView(active: $use_timer).padding().onChange(of: use_timer){reset_state()}
                    ChordArpSwitchView(chord: $chord).padding().onChange(of: chord){reset_state()}
                }.scaleEffect(2.0)
                Spacer()
                Spacer()
                HStack {
                    Spacer()
                    run_btn.resizable().scaledToFit().onTapGesture {
                        toggle_start_stop()
                    }.foregroundColor(Color(.systemGray))
                    Spacer()
                }
                Spacer()
                answer.opacity(answer_visible).font(.system(size: 45)).foregroundStyle(correct ? Color.green : Color.red)
                Text(guess_str).foregroundColor(Color(.systemGray)).font(.system(size: 45))
                Spacer()
                TriadAnswerButtonsView(loopFunction: self.loopFunction, params: params, running: running, guess_str: $guess_str, use_timer: use_timer)
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
        running.toggle()
        if running {
            start()
        }
        else{
            stop()
        }
    }
    
    func start() {
        run_btn = Image(systemName: "pause.circle")
        running = true
        timer?.invalidate()
        loopFunction()
    }
    
    func stop(){
        timer?.invalidate()
        run_btn = Image(systemName: "play.circle")
        running = false
        notes = notes.map{$0 * 0}
        answer = Text(" ")
        guess_str = " "
        answer_visible = 1.0
    }

    func loopFunction() {
        var delay = params.delay * 0.5
        if (answer_visible == 1.0){
            correct = false
            answer_visible = 0.0
            guess_str = " "
            delay += play_sequence()
        } else{
            show_answer()
            notes[0] = notes[1]
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
        quality = (res.1)[0]
        if chord {
            player.playNotes(notes: res.0, duration: params.delay * 0.5, chord: true)
        } else {
            let duration = params.delay_sequence
            player.playNotes(notes: res.0, duration: duration, chord: false)
            delay = params.delay_sequence * 2.0 * 0.5
        }
        return delay
    }
    
    func show_answer(){
        answer = Text(quality)
        correct = quality == guess_str
        answer_visible = 1.0
    }

    func reset_state(){
        stop()
        answer = Text(" ")
        answer_visible = 1.0
        guess_str = " "
    }
    
    func update_function(newParams: Parameters){
        dftDelay = newParams.delay
        dftFilterStr = triad_filters_to_str(active_qualities: newParams.active_qualities, active_inversions: newParams.active_inversions, active_voicings: newParams.active_voicings)
    }
}
