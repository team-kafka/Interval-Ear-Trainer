//
//  PracticeView.swift
//  My First App
//
//  Created by Nicolas on 2024/12/04.
//

import SwiftUI

struct PracticeView: View {
    @Environment(\.modelContext) var modelContext
    
    @State private var params: Parameters
    @State private var paramsPresented: Bool = false
    @State private var use_timer: Bool
    @State private var fixed_n_notes: Bool
    @State private var chord_active: Bool
    @State private var cacheData: [String: HistoricalData]

    @Binding private var dftParams: String
    @Binding private var saveUsageData: Bool

    @State private var player: SequencePlayer
    
    init(params: Parameters, dftParams: Binding<String>, saveUsageData: Binding<Bool>, fixed_n_notes: Bool=false, chord_active: Bool=true){
        _params = .init(initialValue: params)
        _fixed_n_notes = .init(initialValue: fixed_n_notes)
        _chord_active = .init(initialValue: chord_active)
        _use_timer = .init(initialValue: true)
        _dftParams = .init(projectedValue: dftParams)
        _saveUsageData = .init(projectedValue: saveUsageData)
        _player = .init(initialValue: SequencePlayer.shared)
        _cacheData = .init(initialValue: [:])
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
                NoteButtonsView(params: params, notes: $player.notes, root_note: player.rootNote, chord: params.is_chord, running: player.playing, answer_visible: $player.answerVisible, fixed_n_notes: fixed_n_notes, chord_active:chord_active)
                if (params.type == .scale_degree) {
                    ScaleChooserView(params: $params, running:player.playing)
                        .onChange(of: params.scale) { player.setParameters(params) ; player.resetState(params:params) }
                        .onChange(of: params.key) { player.setParameters(params) ; player.resetState(params:params) }
                }
                Spacer()
                answerView().opacity(player.answerVisible).font(.system(size: 45)).foregroundStyle(Color(.systemGray))
                Spacer()
            }
        }
        .toolbar {
            Button(action: {paramsPresented = true}){
                Image(systemName: "gearshape.fill")
            }
        }
        .sheet(isPresented: $paramsPresented) {
            NavigationStack{
                ParametersView(params: $params)
            }
        }
        .toolbarRole(.editor)
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
        }.onChange(of: SequencePlayer.shared.answerVisible) {
            if (SequencePlayer.shared.answerVisible == 1.0) {
                save_to_cache()
            }
        }.onChange(of: SequencePlayer.shared.playing) {
            if (SequencePlayer.shared.playing == false) {
                persist_cache()
            }
        }
    }
    
    func answerView() -> AnyView {
        let answerArray = player.answers.joined(separator: " ").split(separator: "/")
        if answerArray.count == 1{
            return AnyView(VStack{Text(answerArray[0]).font(.system(size: 45))})
        } else if answerArray.count > 1 {
            return AnyView(VStack{
                Text(answerArray[0]).font(.system(size: 40))
                ForEach(Array(answerArray[1...].enumerated()), id: \.offset){_, ans in
                    Text(ans).font(.system(size: 30))
                }
            })
        } else {
            return AnyView(VStack{Text(" ").font(.system(size: 45))})
        }
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
        }
    }
    
    func save_dft_params(newParams: Parameters){
        dftParams = newParams.encode()
    }

    func save_to_cache()
    {
        if saveUsageData {
            for ans in SequencePlayer.shared.answers {
                let short = short_answer(answer: ans)
                if !cacheData.keys.contains(short){
                    cacheData[short] = HistoricalData(date:rounded_date(date: Date()), type:ex_type_to_str(ex_type:params.type), id:short)
                }
                cacheData[short]!.listening += 1
            }
        }
    }
    
    func persist_cache()
    {
        if saveUsageData {
            for hd in cacheData.values{
                modelContext.insert(hd)
            }
            try! modelContext.save()
            cacheData = [String:HistoricalData]()
        }
    }
}
