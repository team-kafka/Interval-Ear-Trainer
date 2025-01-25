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
    @State private var cacheData: [String: HistoricalData]

    let id: String
    @State var params: Parameters
    
    @Binding var dftParams: String
    @Binding private var saveUsageData: Bool

    init(params: Parameters, dftParams: Binding<String>, saveUsageData: Binding<Bool>, id: String){
        _params = .init(initialValue: params)
        _dftParams = .init(projectedValue: dftParams)
        _saveUsageData = .init(projectedValue: saveUsageData)
        _cacheData = .init(initialValue: [:])
        self.id = id
    }
    
    var body: some View {
        HStack{
            ((SequencePlayer.shared.playing && self.id == SequencePlayer.shared.getOwner())  ? Image(systemName: "speaker.slash.fill") : Image(systemName: "speaker.wave.2")).onTapGesture {
                if (!SequencePlayer.shared.playing) {
                    start()
                } else if self.id == SequencePlayer.shared.getOwner() {
                    stop()
                }
            }
            if (params.type == .scale_degree) {
                Image(systemName: "die.face.5").foregroundColor(Color(.systemGray)).onTapGesture {
                    if (!(SequencePlayer.shared.playing && self.id == SequencePlayer.shared.getOwner())) {
                        params.key = NOTE_KEYS.randomElement()!
                    }
                }
                // add number of notes
            } else{
                ChordArpSwitchView(chord: $params.is_chord, active: !(SequencePlayer.shared.playing && self.id == SequencePlayer.shared.getOwner()))
            }
            NavigationLink(destination: ParametersView(params: $params).navigationBarBackButtonHidden(true).onAppear {
                if (SequencePlayer.shared.playing && self.id == SequencePlayer.shared.getOwner() ) {
                    stop()
                }
            }){
            }.opacity(0)
            Text(params.generateLabelString()).lineLimit(1)
            Image(systemName: "gearshape.fill")
        }.onAppear{
            save_dft_params(newParams: params)
        }.onChange(of: SequencePlayer.shared.answerVisible) {
            if (SequencePlayer.shared.answerVisible == 1.0 && self.id == SequencePlayer.shared.getOwner()) {
                save_to_cache()
            }
        }
    }
    
    func start() {
        SequencePlayer.shared.setParameters(params)
        SequencePlayer.shared.setOwner(self.id)
        _ = SequencePlayer.shared.start()
    }
    
    func stop(){
        SequencePlayer.shared.stop()
        SequencePlayer.shared.resetState(params: params)
        persist_cache()
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
