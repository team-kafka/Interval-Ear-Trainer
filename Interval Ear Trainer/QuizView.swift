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
        } else {
            self.sequenceGenerator = TriadGenerator()
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
                Spacer()
                answerView(answer_str: answer_str).opacity(answer_visible).foregroundStyle(correct ? Color.green : Color.red)
                Text(guess_str).foregroundColor(Color(.systemGray)).font(.system(size: 40))
                Spacer()
                if (params.type == .interval) {
                    IntervalAnswerButtonsView(loopFunction: self.loopFunction, activeIntervals: params.active_intervals, running: running, notes: notes, guess_str: $guess_str, guess: $guess, use_timer: use_timer)
                } else if (params.type == .triad) {
                    TriadAnswerButtonsView(loopFunction: self.loopFunction, params: params, running: running, guess_str: $guess_str, use_timer: use_timer)
                }
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
            guess = [0]
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
        var delay: Double = 0
        var duration: Double = 0
        var new_notes: [Int] = []
        
        (new_notes, duration, delay, answer_str, _) = sequenceGenerator.generateSequence(params: params, n_notes:n_notes, chord:chord, prev_note:notes.last ?? 0)
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
        correct = answer_str.contains(guess_str) && guess_str != " "
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


struct IntervalQuizView: View {
    @State var params: Parameters
    @State private var run_btn = Image(systemName: "play.circle")
    @State private var running = false
    @State private var answer = Text(" ")
    @State private var answer_str = String(" ")
    @State private var notes: [Int] = [0,0]
    @State private var timer: Timer?
    @State var answer_visible: Double = 1.0
    @State var n_notes:Int = 2
    @State var chord: Bool = false
    @State var use_timer: Bool = true

    @State var correct: Bool = false
    @State private var guess_str = " "
    @State private var guess: [Int] = [0]
    
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
                    NumberOfNotesView(n_notes: $n_notes, notes: $notes).padding().onChange(of: n_notes){
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
                    run_btn.resizable().scaledToFit().onTapGesture {
                        toggle_start_stop()
                    }.foregroundColor(Color(.systemGray))
                    Spacer()
                }
                Spacer()
                answer.opacity(answer_visible).font(.system(size: 45)).foregroundStyle(correct ? Color.green : Color.red)
                Text(guess_str).foregroundColor(Color(.systemGray)).font(.system(size: 45))
                Spacer()
                IntervalAnswerButtonsView(loopFunction: self.loopFunction, activeIntervals: params.active_intervals, running: running, notes: notes, guess_str: $guess_str, guess: $guess, use_timer: use_timer)
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
            guess = [0]
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
        if (n_notes == 1) {
            if (notes[0] == 0) {
                notes[0] = Int.random(in: params.lower_bound..<params.upper_bound)
                (notes[1], answer_str) = draw_new_note(prev_note: notes[0], active_intervals: params.active_intervals, upper_bound: params.upper_bound, lower_bound: params.lower_bound, largeIntevalsProba: params.largeIntevalsProba)
                player.playNotes(notes: notes, duration: params.delay*0.5)
                delay = params.delay * 0.5
            }
            else {
                notes[0] = notes[1]
                (notes[1], answer_str) = draw_new_note(prev_note: notes[0], active_intervals: params.active_intervals, upper_bound: params.upper_bound, lower_bound: params.lower_bound, largeIntevalsProba: params.largeIntevalsProba)
                player.playNotes(notes: [notes[1]], duration: params.delay*0.5)
            }
        } else if chord{
            (notes, answer_str) = draw_random_chord(n_notes: n_notes, active_intervals: params.active_intervals, upper_bound: params.upper_bound, lower_bound: params.lower_bound, largeIntevalsProba: params.largeIntevalsProba)
            player.playNotes(notes: notes, duration: params.delay * 0.5, chord: true)
        } else {
            notes[0] = Int.random(in: params.lower_bound..<params.upper_bound)
            var answers = [String]()
            for (i, _) in notes[1...].enumerated(){
                var answer: String
                (notes[i+1], answer) = draw_new_note(prev_note: notes[i], active_intervals: params.active_intervals, upper_bound: params.upper_bound, lower_bound: params.lower_bound, largeIntevalsProba: params.largeIntevalsProba)
                answers.append(answer)
            }
            answer_str = answers.joined(separator: " ")
            let duration = params.delay_sequence
            player.playNotes(notes: notes, duration: duration, chord: false)
            delay = params.delay_sequence * Double(n_notes-1) * 0.5
        }
        return delay
    }
    
    func show_answer(){
        let answerInt = answer_from_notes(notes: notes, chord: chord, oriented: false)

        correct = (answerInt[...] == guess[1...])
        answer = Text(answer_str)
        answer_visible = 1.0
    }

    func reset_state(){
        stop()
        answer = Text(" ")
        answer_visible = 1.0
        guess_str = " "
        guess = [Int](repeating: 0, count: notes.count)
    }
    
    func update_function(newParams: Parameters){
        dftDelay = newParams.delay
        dftFilterStr = interval_filter_to_str(intervals: newParams.active_intervals)
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
