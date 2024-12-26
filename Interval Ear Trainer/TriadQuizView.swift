//
//  TriadQuizView.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2024/12/26.
//

import SwiftUI

struct TriadQuizView: View {
    @State var params: TriadParameters = TriadParameters()
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
    @State private var guess_str = Text(" ")

    //@Binding var dftDelay: Double
    //@Binding var dftFilterStr: String

    @State var player = MidiPlayer()
    
    var body: some View {
        
        NavigationStack{
            VStack {
                HStack{
                    Spacer()
                    NavigationLink(destination: TriadParametersView(params: $params).navigationBarBackButtonHidden(true).onAppear {stop()}){
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
                guess_str.foregroundColor(Color(.systemGray)).font(.system(size: 45))
                Spacer()
                TriadAnswerButtonsView(loopFunction: self.loopFunction, params: params, running: running, guess_str: $guess_str, use_timer: use_timer)
                Spacer()
            }
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
        guess_str = Text(" ")
        answer_visible = 1.0
    }

    func loopFunction() {
        var delay = params.delay * 0.5
        if (answer_visible == 1.0){
            correct = false
            answer_visible = 0.0
            guess_str = Text(" ")
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
        let res = draw_random_triad(params: params)
        quality = (res.1)[0]
        if chord {
            player.playNotes(notes: res.0, duration: params.delay * 0.5, chord: true)
        } else {
            let duration = params.delay_arpeggio
            player.playNotes(notes: res.0, duration: duration, chord: false)
            delay = params.delay_arpeggio * 2.0 * 0.5
        }
        return delay
    }
    
    func show_answer(){
        answer = Text(quality)
        correct = answer == guess_str
        answer_visible = 1.0
    }

    func reset_state(){
        stop()
        answer = Text(" ")
        answer_visible = 1.0
        guess_str = Text(" ")
    }
    
    func update_function(newParams: IntervalParameters){
        //dftDelay = newParams.delay
        //dftFilterStr = interval_filter_to_str(intervals: newParams.active_intervals)
    }
}

struct TriadAnswerButtonsView: View {
    public var loopFunction: (() -> Void)
    var params: TriadParameters
    var running: Bool
    @Binding var guess_str: Text
    var use_timer: Bool
    
    @State private var timer: Timer?
    
    var body: some View {
        let activeTriads = params.active_qualities
        HStack{
            ForEach(0..<2){ i in
                VStack{
                    ForEach(0..<3){ j in
                        if (i*3+j < TRIAD_KEYS.count){
                            let thisTriad = TRIAD_KEYS[i*3+j]
                            let active = activeTriads.contains(thisTriad) && running
                            Text(thisTriad.prefix(3)).bold().foregroundColor(Color(.systemGray)).font(.system(size: 30)).gridColumnAlignment(.leading).padding().frame(maxWidth: .infinity).overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.gray, lineWidth: 4)).opacity(active ? 1: 0.5).onTapGesture{
                                        if active {
                                            guess_str = Text(thisTriad)
                                            if !use_timer {
                                                set_timer()
                                            }
                                        }
                                    }
                        } else {
                            Text("Maj").bold().font(.system(size: 30)).gridColumnAlignment(.leading).padding().frame(maxWidth: .infinity).overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.gray, lineWidth: 4)).opacity(0.0)
                        }
                    }
                }.fixedSize(horizontal: false, vertical: true)
            }
        }.padding()
    }
    
    func set_timer() {
        timer = Timer.scheduledTimer(withTimeInterval:0.2, repeats: false) { t in
            loopFunction()
            timer = Timer.scheduledTimer(withTimeInterval:0.6, repeats: false) { t in
                loopFunction()
            }
        }
    }
}
