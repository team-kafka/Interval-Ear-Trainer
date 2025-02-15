//
//  IntervalQuizzView.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2024/12/23.
//

import SwiftUI

let ANSWER_COLORS: [AnswerType: Color] = [
    .correct: Color.green,
    .incorrect: Color.red,
    .timeout: Color.orange
]

struct QuizView: View {
    @Environment(\.modelContext) var modelContext

    @State private var orientation = UIDeviceOrientation.portrait
    @State var cacheData: [String: HistoricalData]
    
    @State private var params: Parameters
    @State private var paramsPresented: Bool
    @State private var use_timer: Bool
    @State private var fixed_n_notes: Bool
    @State private var chord_active: Bool
    @State private var guesses: [String]
    @State private var streak_c: Int
    @State private var streak_i: Int
    @State private var streak_t: Int
    @State private var timer: Timer?
    
    @Binding private var dftParams: String
    @Binding private var saveUsageData: Bool

    @State private var player: SequencePlayer

    init(params: Parameters, dftParams: Binding<String>, saveUsageData: Binding<Bool>, n_notes: Int=2, fixed_n_notes: Bool=false,  chord_active: Bool=true, chord: Bool=false){
        _params = .init(initialValue: params)
        _paramsPresented = .init(initialValue: false)
        _fixed_n_notes = .init(initialValue: fixed_n_notes)
        _chord_active = .init(initialValue: chord_active)
        _use_timer = .init(initialValue: true)
        _guesses = .init(initialValue: [])
        _streak_c = .init(initialValue: 0)
        _streak_i = .init(initialValue: 0)
        _streak_t = .init(initialValue: 0)
        _timer = .init(initialValue: nil)
        _dftParams = .init(projectedValue: dftParams)
        _saveUsageData = .init(projectedValue: saveUsageData)
        _cacheData = .init(initialValue: [:])
        _player = .init(initialValue: SequencePlayer.shared)
    }
    
    var body: some View {
        QuickParamButtonsView(n_notes: $params.n_notes, chord: $params.is_chord, use_timer: $use_timer, fixed_n_notes: $fixed_n_notes, chord_active:$chord_active).padding([.top])
        NavigationStack{
            VStack {
                if orientation.isPortrait {
                    VStack(alignment: .center){
                        (player.playing ? Image(systemName: "pause.circle") : Image(systemName: "play.circle")).resizable().scaledToFit().onTapGesture {
                            toggle_start_stop()
                        }.foregroundColor(Color(.systemGray)).padding([.leading, .trailing, .top])
                        if (params.type == .scale_degree) {
                            ScaleChooserView(params: $params, running:player.playing).padding([.top])
                        }
                        NoteButtonsView(params: params, notes: player.notes, root_note: player.rootNote, chord: params.is_chord, active: player.playing && use_timer, answer_visible: player.answerVisible, hasChord:chord_active, visible: use_timer ? 0.0 : 1.0).padding([.top, .bottom])
                        HStack{
                            Spacer()
                            let gridSize = switch params.type {
                            case .scale_degree : params.n_notes
                            case .interval : max(1, params.n_notes - 1)
                            case .triad : 1
                            }
                            IntervalResultView(fontSize: 30, gridSize: gridSize, guesses: $guesses, answers: $player.answers, answerVisible: $player.answerVisible, oriented: !params.is_chord).padding([.leading, .trailing])
                            Spacer()
                        }.padding([.bottom])
                    }
                } else {
                    if (params.type == .scale_degree) {
                        HStack{
                            ScaleChooserView(params: $params, running:player.playing, fontSize: 25)
                                .padding([.leading, .trailing])
                            Spacer()
                        }
                    }
                    HStack{
                        Image(systemName: player.playing ? "pause.circle" : "play.circle").resizable().frame(width: 100, height: 100).onTapGesture {
                            toggle_start_stop()
                        }.foregroundColor(Color(.systemGray)).padding([.leading, .trailing, .bottom])
                        NoteButtonsView(params: params, notes: player.notes, root_note: player.rootNote, chord: params.is_chord, active: player.playing && use_timer, answer_visible: player.answerVisible, hasChord:chord_active, visible: use_timer ? 0.0 : 1.0)
                        
                        IntervalResultView(fontSize: 30, gridSize: params.type == .scale_degree ? 4 : 3, guesses: $guesses, answers: $player.answers, answerVisible: $player.answerVisible, oriented: !params.is_chord).padding([.leading, .trailing])
                        Spacer()
                    }.padding([.top])

                    Spacer()
                }
                if (params.type == .interval) {
                    IntervalAnswerButtonsView(activeIntervals: params.active_intervals, active: (player.playing && (player.answerVisible==0.0)), notes: $player.notes, guesses: $guesses, use_timer: use_timer, portrait: orientation.isPortrait)
                } else if (params.type == .triad) {
                    TriadAnswerButtonsView(params: params, active: (player.playing && (player.answerVisible==0.0)), guesses: $guesses, use_timer: use_timer, notes: player.notes, portrait: orientation.isPortrait)
                } else if (params.type == .scale_degree) {
                    ScaleDegreeAnswerButtonsView(activeDegrees: params.active_scale_degrees, scale:params.scale, active: (player.playing && (player.answerVisible==0.0)), notes: player.notes, guesses: $guesses, use_timer: use_timer, portrait: orientation.isPortrait)
                }
            }.onRotate { newOrientation in
                if (newOrientation == UIDeviceOrientation.portrait || newOrientation == UIDeviceOrientation.landscapeLeft || newOrientation == UIDeviceOrientation.landscapeRight) {
                    orientation = newOrientation
                }
            }
        }
        .onAppear {
            player.stop()
            player.setParameters(params)
            player.resetState(params:params)
            player.releaseNowPlaying()
            orientation = UIDevice.current.orientation.isLandscape ? UIDeviceOrientation.landscapeLeft : UIDeviceOrientation.portrait
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {paramsPresented = true}){
                    Image(systemName: "gearshape.fill")
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                StreakView(streak_c: $streak_c, streak_i: $streak_i, streak_t: $streak_t)
            }
        }
        .sheet(isPresented: $paramsPresented) {
                ParametersView(params: $params)
        }
        .toolbarRole(.editor)
        .onDisappear {
            player.stop()
        }.onChange(of: SequencePlayer.shared.playing) {
            if (SequencePlayer.shared.playing == false) {
                persist_cache()
            }
        }.onChange(of: paramsPresented) {
            if paramsPresented == false {
                save_dft_params(newParams: params)
                resetState()
            }
        }.onChange(of: player.answerVisible) {
            if player.answerVisible == 0.0 { guesses = [] }
            else { save_to_cache() }
        }
        .onChange(of: guesses){
            if (guesses.count == player.answers.count && guesses.count > 0) {
                self.advanceState()
                if !use_timer {
                    let guess_eval = evaluate_guess(guess: guesses, answer: player.answers)
                    if guess_eval.reduce(true, { x, y in x && y == .correct}) {
                        timer = Timer.scheduledTimer(withTimeInterval:ANSWER_TIME, repeats: false) { _ in self.advanceState() }
                    }
                }
            }
        }
        .onChange(of: params.n_notes) { resetState(); save_dft_params(newParams: params) }
        .onChange(of: params.is_chord) { resetState(); save_dft_params(newParams: params) }
        .onChange(of: use_timer) { resetState() }
        .onChange(of: params.scale) { resetState(); save_dft_params(newParams: params) }
        .onChange(of: params.key) { resetState(); save_dft_params(newParams: params) }
    }
    
    func answerView() -> AnyView {
        let guess_eval = evaluate_guess(guess: guesses, answer: player.answers)
        return AnyView(
            HStack{
                Text(" ").font(.system(size: 40))
                ForEach(Array(player.answers.enumerated()), id: \.offset) { i, ans in
                    Text(short_answer(answer: ans)).font(.system(size: 40)).foregroundStyle(ANSWER_COLORS[guess_eval[i]]!)
                }
            })
    }
    
    func guessView() -> AnyView {
        return AnyView(
            HStack{
                Text(" ").font(.system(size: 40))
                ForEach(Array(guesses.enumerated()), id: \.offset) { _, g in
                    Text(short_answer(answer: g)).foregroundColor(Color(.systemGray)).font(.system(size: 40))
                }
            })
    }
    
    func toggle_start_stop() {
        if use_timer {
            if !player.playing {
                player.setParameters(params)
                _ = player.start()
            }
            else{
                player.stop()
            }
        } else { // Give up
            player.step()
        }
    }

    func save_dft_params(newParams: Parameters) {
        dftParams = newParams.encode()
    }
    
    func resetState() {
        guesses = []
        player.stop()
        player.setParameters(params)
        player.resetState(params:params)
    }
    
    func advanceState() {
        if !use_timer {
            player.step()
        } else {
            player.loopFunction()
        }
    }
    
    func save_to_cache() {
        let guess_eval = evaluate_guess(guess: guesses, answer: player.answers)
        for (res, ans) in zip(guess_eval, player.answers){
            let short = short_answer(answer: ans)
            if !cacheData.keys.contains(short){
                cacheData[short] = HistoricalData(date:rounded_date(date: Date()), type:ex_type_to_str(ex_type:params.type), id:short)
            }
            switch res{
            case .correct:
                cacheData[short]!.correct += 1
                streak_c += 1
            case .incorrect:
                cacheData[short]!.incorrect += 1
                streak_i += 1
            case .timeout:
                cacheData[short]!.timeout += 1
                streak_t += 1
            }
        }
    }


    func persist_cache() {
        if saveUsageData {
            for hd in cacheData.values{
                modelContext.insert(hd)
            }
            try! modelContext.save()
            cacheData = [String:HistoricalData]()
        }
    }
}
