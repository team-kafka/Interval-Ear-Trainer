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
    
    let id: String
    @State var params: Parameters
    @Binding var dftParams: String

    init(params: Parameters, dftParams: Binding<String>, id: String){
        _params = .init(initialValue: params)
        _dftParams = .init(projectedValue: dftParams)
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
        }.onDisappear{
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
        persist_hist_data()
    }

    func save_dft_params(newParams: Parameters){
        dftParams = newParams.encode()
    }
    
    func persist_hist_data()
    {
        let cd = SequencePlayer.shared.get_cacheData()
        for k in cd.keys {
            let hd = HistoricalData(date: Date(), type:ex_type_to_str(ex_type:params.type), id:short_answer(answer: k), listening: cd[k]!)
            modelContext.insert(hd)
        }
        try! modelContext.save()
        SequencePlayer.shared.clear_cacheData()
    }
}
