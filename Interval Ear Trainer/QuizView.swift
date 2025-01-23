//
//  IntervalQuizzView.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2024/12/23.
//

import SwiftUI

let answer_colors: [AnswerType: Color] = [
    .correct: Color.green,
    .incorrect: Color.red,
    .timeout: Color.orange
]

struct QuizView: View {
    @Environment(\.modelContext) var modelContext
    @State var cacheData: [String: HistoricalData]
    
    @State private var params: Parameters
    @State private var use_timer: Bool
    @State private var fixed_n_notes: Bool
    @State private var chord_active: Bool
    @State private var guesses: [String]
    @State private var timer: Timer?
    
    @Binding private var dftParams: String

    @State private var player: SequencePlayer

    
    init(params: Parameters, dftParams: Binding<String>, n_notes: Int=2, fixed_n_notes: Bool=false,  chord_active: Bool=true, chord: Bool=false){
        _params = .init(initialValue: params)
        _fixed_n_notes = .init(initialValue: fixed_n_notes)
        _chord_active = .init(initialValue: chord_active)
        _use_timer = .init(initialValue: true)
        _guesses = .init(initialValue: [])
        _timer = .init(initialValue: nil)
        _dftParams = .init(projectedValue: dftParams)
        _cacheData = .init(initialValue: [:])
        _player = .init(initialValue: SequencePlayer.shared)
    }
    
    var body: some View {
        
        NavigationStack{
            VStack {
                QuickParamButtonsView(params: $params, n_notes: $params.n_notes, chord: $params.is_chord, use_timer: $use_timer, fixed_n_notes: $fixed_n_notes, chord_active:$chord_active)
                    .onChange(of: params.n_notes) { player.setParameters(params) ; player.resetState(params:params) }
                    .onChange(of: params.is_chord) { player.setParameters(params) }
                    .onChange(of: use_timer) { player.stop(); player.setParameters(params) ; player.resetState(params:params) }
                HStack {
                    Spacer()
                    (player.playing ? Image(systemName: "pause.circle") : Image(systemName: "play.circle")).resizable().scaledToFit().onTapGesture {
                        toggle_start_stop()
                    }.foregroundColor(Color(.systemGray))
                    Spacer()
                }
                if (params.type == .scale_degree) {
                    ScaleChooserView(params: $params, running:player.playing)
                        .onChange(of: params.scale) { player.setParameters(params) ; player.resetState(params:params) }
                        .onChange(of: params.key) { player.setParameters(params) ; player.resetState(params:params) }
                }
                Spacer()
                answerView().opacity(player.answerVisible)
                    .onChange(of: player.answerVisible) { if player.answerVisible == 0.0 { guesses = [] } }

                guessView()
                Spacer()
                if (params.type == .interval) {
                    IntervalAnswerButtonsView(loopFunction: self.loopFunction(), activeIntervals: params.active_intervals, active: (player.playing && (player.answerVisible==0.0)), notes: player.notes, guesses: $guesses, use_timer: use_timer)
                } else if (params.type == .triad) {
                    TriadAnswerButtonsView(loopFunction: self.loopFunction(), params: params, active: (player.playing && (player.answerVisible==0.0)), guesses: $guesses, use_timer: use_timer, notes: player.notes)
                } else if (params.type == .scale_degree) {
                    ScaleDegreeAnswerButtonsView(loopFunction: self.loopFunction(), activeDegrees: params.active_scale_degrees, scale:params.scale, active:  (player.playing && (player.answerVisible==0.0)), notes: player.notes, guesses: $guesses, use_timer: use_timer)
                }
            }
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            save_dft_params(newParams: params)
            player.stop()
            player.setParameters(params)
            player.resetState(params:params)
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            player.stop()
            persist_cache()
        }
    }
    
    func answerView() -> AnyView {
        let guess_eval = evaluate_guess(guess: guesses, answer: player.answers)
        return AnyView(
            HStack{
                Text(" ").font(.system(size: 40))
                ForEach(Array(player.answers.enumerated()), id: \.offset) { i, ans in
                    Text(short_answer(answer: ans)).font(.system(size: 40)).foregroundStyle(answer_colors[guess_eval[i]]!)
                }
            })
    }
    
    func guessView() -> AnyView {
        return AnyView(
            HStack{
                Text(" ").font(.system(size: 40))
                ForEach(Array(guesses), id: \.self) { g in
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
        } else {
            player.step()
            if player.answerVisible == 1.0 {
                timer = Timer.scheduledTimer(withTimeInterval:0.6, repeats: false) { t in
                    player.step()
                }
            }
        }
    }

    func save_dft_params(newParams: Parameters){
        dftParams = newParams.encode()
    }
    
    func loopFunction() -> (() -> ())
    {
        if use_timer {
            return player.loopFunction
        } else {
            return player.step
        }
    }
    func save_to_cache()
    {
        let guess_eval = evaluate_guess(guess: guesses, answer: player.answers)
        for (res, ans) in zip(guess_eval, player.answers){
            if !cacheData.keys.contains(ans){
                cacheData[ans] = HistoricalData(date:Date(), type:ex_type_to_str(ex_type:params.type), id:short_answer(answer: ans))
            }
            switch res{
                case .correct:
                    cacheData[ans]!.correct += 1
                case .incorrect:
                    cacheData[ans]!.incorrect += 1
                case .timeout:
                    cacheData[ans]!.timeout += 1
            }
        }
    }
    
    func persist_cache()
    {
        for hd in cacheData.values{
            modelContext.insert(hd)
        }
        try! modelContext.save()
        cacheData = [String:HistoricalData]()
    }
}
