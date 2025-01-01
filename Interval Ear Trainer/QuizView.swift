//
//  IntervalQuizzView.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2024/12/23.
//

import SwiftUI

struct QuizView: View { // find a way to reuse commmon code with practice view
    @State var params: Parameters
    @State private var button_lbl: Image
    @State private var running: Bool
    
    @State private var answer_str: String
    @State var correct: Bool
    @State private var guess_str: String
    @State private var guess: [Int]
    @State var answer_visible: Double

    @State private var timer: Timer?
    
    @State private var notes: [Int]
    @State var n_notes:Int
    @State var fixed_n_notes: Bool
    
    @State var chord: Bool
    @State var use_timer: Bool

    @Binding var dftDelay: Double
    @Binding var dftFilterStr: String

    @State var player: MidiPlayer
    var sequenceGenerator: SequenceGenerator

    
    init(params: Parameters, dftDelay: Binding<Double>, dftFilterStr: Binding<String>, n_notes: Int=2, fixed_n_notes: Bool=false, chord: Bool=false){
        _params = .init(initialValue: params)
        if (params.type == .interval) {
            self.sequenceGenerator = IntervalGenerator()
        } else if (params.type == .triad){
            self.sequenceGenerator = TriadGenerator()
        } else  if (params.type == .scale_degree){
            self.sequenceGenerator = ScaleDegreeGenerator()
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
        _chord = .init(initialValue: chord)
        _use_timer = .init(initialValue: true)
        _correct = .init(initialValue: false)
        _guess_str = .init(initialValue: " ")
        _guess = .init(initialValue: [0])
        _player = .init(initialValue: MidiPlayer())
        _timer = .init(initialValue: nil)
        _dftDelay = .init(projectedValue: dftDelay)
        _dftFilterStr = .init(projectedValue: dftFilterStr)
    }
    
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
                    NumberOfNotesView(n_notes: $n_notes, notes: $notes, active: !fixed_n_notes, visible: !fixed_n_notes).padding().onChange(of: n_notes){
                        reset_state()
                        if (n_notes == 1) {chord = false}
                    }
                    TimerView(active: $use_timer).padding().onChange(of: use_timer){reset_state()}
                    ChordArpSwitchView(chord: $chord, active: (n_notes>1)).padding().onChange(of: chord){reset_state()}
                }.scaleEffect(2.0)
                Spacer()
                Spacer()
                HStack {
                    Spacer()
                    button_lbl.resizable().scaledToFit().onTapGesture {
                        toggle_start_stop()
                    }.foregroundColor(Color(.systemGray))
                    Spacer()
                }
                if (params.type == .scale_degree) {
                    Grid{
                        GridRow{
                            Image(systemName: "die.face.5").foregroundColor(Color(.systemGray)).padding([.leading, .trailing]).onTapGesture {
                                params.key = NOTE_KEYS.randomElement()!
                            }.scaleEffect(1.5)
                            Menu{
                                Picker("key", selection: $params.key) {
                                    ForEach(NOTE_KEYS, id: \.self) {
                                        Text($0).font(.system(size: 30)).accentColor(Color(.systemGray)).gridColumnAlignment(.leading)
                                    }
                                }.onChange(of: params.key) {reset_state()}
                            } label: {
                                Text(params.key).font(.system(size: 30)).accentColor(Color(.systemGray)).gridColumnAlignment(.leading)
                            }.gridColumnAlignment(.leading)
                        }
                        GridRow{
                            Image(systemName:"speaker.wave.2.fill").foregroundColor(Color(.systemGray)).padding([.trailing, .leading]).onTapGesture {
                                player.playNotes(notes: scale_notes(scale: params.scale, key: params.key, upper_bound: params.upper_bound, lower_bound: params.lower_bound), duration: params.delay_sequence)
                            }.scaleEffect(1.5)
                            Menu{
                                Picker("Scale", selection: $params.scale) {
                                    ForEach(SCALE_KEYS, id: \.self) {
                                        Text($0).font(.system(size: 30)).gridColumnAlignment(.leading)
                                    }
                                }.accentColor(Color(.systemGray)).onChange(of: params.scale) {reset_state()}
                            } label: {
                                Text(params.scale).font(.system(size: 30)).accentColor(Color(.systemGray)).gridColumnAlignment(.leading)
                            }.gridColumnAlignment(.leading)
                            //Spacer()
                        }
                    }
                }
                Spacer()
                answerView(answer_str: answer_str).opacity(answer_visible).foregroundStyle(correct ? Color.green : Color.red)
                Text(guess_str).foregroundColor(Color(.systemGray)).font(.system(size: 40))
                Spacer()
                if (params.type == .interval) {
                    IntervalAnswerButtonsView(loopFunction: self.loopFunction, activeIntervals: params.active_intervals, running: running, notes: notes, guess_str: $guess_str, guess: $guess, use_timer: use_timer)
                } else if (params.type == .triad) {
                    TriadAnswerButtonsView(loopFunction: self.loopFunction, params: params, running: running, guess_str: $guess_str, use_timer: use_timer)
                } else if (params.type == .scale_degree) {
                    ScaleDegreeAnswerButtonsView(loopFunction: self.loopFunction, activeDegrees: params.active_scale_degrees, running: running, notes: notes, guess_str: $guess_str, guess: $guess, use_timer: use_timer)
                }
                //Spacer()
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
        return AnyView(Text(answer_str.split(separator: "/")[0]).font(.system(size: 40)))
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
        notes = notes.map{$0 * 0}
        answer_str = " "
        guess_str = " "
        answer_visible = 1.0
    }

    func loopFunction() {
        var delay = params.delay * 0.5
        if (answer_visible == 1.0){
            correct = false
            answer_visible = 0.0
            guess_str = " "
            guess = []
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
        var delay: Double = 0
        var duration: Double = 0
        var new_notes: [Int] = []
        
        (new_notes, duration, delay, answer_str, _) = sequenceGenerator.generateSequence(params: params, n_notes:n_notes, chord:chord, prev_note:notes.last ?? 0)
        player.playNotes(notes: new_notes, duration: duration, chord: chord)
        notes = new_notes
        
        return delay
    }
    
    func show_answer(){
        correct = answer_str.hasSuffix(guess_str) && guess_str != " "
        answer_visible = 1.0
    }

    func reset_state(){
        stop()
        answer_visible = 1.0
        guess_str = " "
        guess = [Int](repeating: 0, count: notes.count)
    }
    
    func update_function(newParams: Parameters){
        dftDelay = newParams.delay
        dftFilterStr = sequenceGenerator.generateFilterString(params: newParams)
    }
}

struct IntervalAnswerButtonsView: View {
    public var loopFunction: (() -> Void)
    var activeIntervals: Set<Int>
    var running: Bool
    var notes: [Int]
    @Binding var guess_str: String
    @Binding var guess: [Int]
    var use_timer: Bool
    
    @State private var timer: Timer?
    
    var body: some View {
        let activeIntAbs = activeIntervals.map{$0 > 0 ? $0 : -$0}
        HStack{
            ForEach(0..<4){ i in
                VStack{
                    ForEach(0..<3){ j in
                        let thisInt = j*4+i+1
                        let active = (activeIntAbs.contains(thisInt) && running)
                        Text(interval_name(interval_int: thisInt, oriented: false)).bold().foregroundColor(Color(.systemGray)).font(.system(size: 30)).gridColumnAlignment(.leading).padding().frame(maxWidth: .infinity).overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.gray, lineWidth: 4)).opacity(active ? 1: 0.5).onTapGesture{
                                    if (active) {
                                        if (guess.count < notes.count){
                                            guess.append(thisInt)
                                        }
                                        guess_str = answer_string(notes: guess, chord: true, oriented: false)
                                        if ((guess.count == notes.count) && !use_timer){
                                            set_timer()
                                        }
                                    }
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

struct TriadAnswerButtonsView: View {
    public var loopFunction: (() -> Void)
    var params: Parameters
    var running: Bool
    @Binding var guess_str: String
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
                                            guess_str = thisTriad
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


struct ScaleDegreeAnswerButtonsView: View {
    public var loopFunction: (() -> Void)
    var activeDegrees: Set<Int>
    var running: Bool
    var notes: [Int]
    @Binding var guess_str: String
    @Binding var guess: [Int]
    var use_timer: Bool
    
    @State private var timer: Timer?
    
    var body: some View {
        HStack{
            ForEach(0..<4){ i in
                VStack{
                    ForEach(0..<2){ j in
                        let idx = j*4+i
                        if (idx < SCALE_DEGREES.values.count) {
                            let thisDegree = SCALE_DEGREES.values.sorted()[idx]
                            let active = activeDegrees.contains(thisDegree) && running
                            Text(scale_degree_name(degree_int: thisDegree)).bold().foregroundColor(Color(.systemGray)).font(.system(size: 30)).gridColumnAlignment(.leading).padding().frame(maxWidth: .infinity).overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.gray, lineWidth: 4)).opacity(active ? 1: 0.5)
                            .onTapGesture{
                                    if (active) {
                                        if (guess.count < notes.count){
                                            guess.append(thisDegree)
                                        }
                                        guess_str = answer_str(guess: guess)
                                        if ((guess.count == notes.count) && !use_timer){
                                            set_timer()
                                        }
                                    }
                            }
                        }
                        else{
                            Text("0").bold().foregroundColor(Color(.systemGray)).font(.system(size: 30)).gridColumnAlignment(.leading).padding().frame(maxWidth: .infinity).overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.gray, lineWidth: 4)).opacity(0)
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
