//
//  TriadListeningView.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2024/12/26.
//

import SwiftUI
import MediaPlayer

struct ListeningView: View {
    @Environment(\.modelContext) var modelContext
    @AppStorage("showHelp") var showHelp: Bool = false
    
    let id: String
    @State private var cacheData: [String: HistoricalData]
    @State var params: Parameters
    @State private var paramsPresented: Bool
    @Binding var dftParams: String
    @Binding private var saveUsageData: Bool
    private var label: String?
    private var divider: Bool
    private var helpText: AnyView

    init(params: Parameters, dftParams: Binding<String>, saveUsageData: Binding<Bool>, id: String, label: String? = nil, divider: Bool = false, helpText: AnyView = AnyView(Text(""))){
        _params = .init(initialValue: params)
        _paramsPresented = .init(initialValue: false)
        _dftParams = .init(projectedValue: dftParams)
        _saveUsageData = .init(projectedValue: saveUsageData)
        _cacheData = .init(initialValue: [:])
        self.id = id
        self.label = label
        self.divider = divider
        self.helpText = helpText
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4){
            if label != nil {
                HStack(alignment: .center, spacing: 4){
                    Text(label!).font(.footnote).bold().padding(.bottom, 5)
                    if (showHelp && label != nil) {HelpMarkView(){helpText}.font(.footnote).padding(.bottom, 5)}
                }
            }
            HStack{
                Text("")
                Image(systemName: ((SequencePlayer.shared.playing && self.id == SequencePlayer.shared.owner) ?  "pause.circle" : "play.circle")).foregroundColor(.gray).onTapGesture {
                    if (!SequencePlayer.shared.playing) {
                        start()
                    } else if self.id == SequencePlayer.shared.owner {
                        stop()
                    }
                }
                if (params.compare_intervals ?? false) {
                    Image(systemName: (params.compare_intervals_shuffled ?? false) ? "shuffle.circle.fill" : "shuffle.circle").foregroundColor(.gray).onTapGesture {
                        if (!(SequencePlayer.shared.playing && self.id == SequencePlayer.shared.owner)) {
                            if params.compare_intervals_shuffled == nil {
                                params.compare_intervals_shuffled = true
                            } else {
                                params.compare_intervals_shuffled!.toggle()
                            }
                        }
                    }
                    ChordArpSwitchView(chord: $params.is_chord, active: !(SequencePlayer.shared.playing && self.id == SequencePlayer.shared.owner))
                } else if (params.type == .scale_degree) {
                    Image(systemName: "die.face.5").foregroundColor(.gray).onTapGesture {
                        if (!(SequencePlayer.shared.playing && self.id == SequencePlayer.shared.owner)) {
                            params.key = NOTE_KEYS.randomElement()!
                        }
                    }
                    NumberOfNotesView(n_notes: $params.n_notes, active: !(SequencePlayer.shared.playing && self.id == SequencePlayer.shared.owner))
                } else{
                    ChordArpSwitchView(chord: $params.is_chord, active: !(SequencePlayer.shared.playing && self.id == SequencePlayer.shared.owner))
                    NumberOfNotesView(n_notes: $params.n_notes, active: false).opacity(0)
                }
                Text(params.generateLabelString(harmonic: self.params.is_chord)).lineLimit(1)
                Spacer()
                Image(systemName: "gearshape.fill").foregroundStyle(.gray).onTapGesture { paramsPresented = true }
            }
            if divider { Divider() }
        }.onChange(of: SequencePlayer.shared.answerVisible) {
            if (SequencePlayer.shared.answerVisible == 1.0 && self.id == SequencePlayer.shared.owner) {
                save_to_cache()
            }
        }.onChange(of: SequencePlayer.shared.playing) {
            if (SequencePlayer.shared.playing == false) {
                persist_cache()
            }
        }.onChange(of: paramsPresented) {
            if (paramsPresented == true && self.id == SequencePlayer.shared.owner) {
                stop()
            } else {
                save_dft_params(newParams: params)
            }
        }.onChange(of: params.n_notes) {
            save_dft_params(newParams: params)
        }.onChange(of: params.is_chord) {
            save_dft_params(newParams: params)
        }.onChange(of: params.key) {
            save_dft_params(newParams: params)
        }.onChange(of: SequencePlayer.shared.owner) {
            if (SequencePlayer.shared.owner == self.id) {
                SequencePlayer.shared.setParameters(params)
            }
        }
        .sheet(isPresented: $paramsPresented) { ParametersView(params: $params) }
    }
    
    func start() {
        SequencePlayer.shared.setParameters(params)
        SequencePlayer.shared.setOwner(self.id)
        _ = SequencePlayer.shared.start()
    }
    
    func stop(){
        SequencePlayer.shared.stop()
        SequencePlayer.shared.resetState(params: params)
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
