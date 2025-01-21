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
    var sequenceGenerator: SequenceGenerator
    static var player: ListeningModePlayer = ListeningModePlayer()
    
    @Binding var dftParams: String


    init(params: Parameters, dftParams: Binding<String>, id: String){
        _params = .init(initialValue: params)
        if (params.type == .interval) {
            self.sequenceGenerator = IntervalGenerator()
        } else if (params.type == .triad){
            self.sequenceGenerator = TriadGenerator()
        } else {
            self.sequenceGenerator = ScaleDegreeGenerator()
        }
        _dftParams = .init(projectedValue: dftParams)
        self.id = id
    }
    
    var body: some View {
        HStack{
            ((ListeningView.player.playing && self.id == ListeningView.player.owner)  ? Image(systemName: "speaker.slash.fill") : Image(systemName: "speaker.wave.2")).onTapGesture {
                if (!ListeningView.player.playing) {
                    start()
                } else if self.id == ListeningView.player.owner {
                    stop()
                }
            }
            if (params.type == .scale_degree) {
                Image(systemName: "die.face.5").foregroundColor(Color(.systemGray)).onTapGesture {
                    if (!(ListeningView.player.playing && self.id == ListeningView.player.owner)) {
                        params.key = NOTE_KEYS.randomElement()!
                    }
                }
            } else{
                ChordArpSwitchView(chord: $params.is_chord, active: !(ListeningView.player.playing && self.id == ListeningView.player.owner))
            }
            NavigationLink(destination: ParametersView(params: $params).navigationBarBackButtonHidden(true).onAppear {
                if (ListeningView.player.playing && self.id == ListeningView.player.owner ) {
                    stop()
                }
            }){
            }.opacity(0)
            Text(sequenceGenerator.generateLabelString(params: params)).lineLimit(1)
            Image(systemName: "gearshape.fill")
        }.onAppear{
            save_dft_params(newParams: params)
        }.onDisappear{
        }
    }
    
    func start() {
        ListeningView.player.setParameters(params)
        ListeningView.player.setSequenceGenerator(sequenceGenerator)
        ListeningView.player.setOwner(self.id)
        _ = ListeningView.player.start()
    }
    
    func stop(){
        ListeningView.player.stop()
        persist_hist_data()
    }

    func save_dft_params(newParams: Parameters){
        dftParams = newParams.encode()
    }
    
    func persist_hist_data()
    {
        let cd = ListeningView.player.get_cacheData()
        for k in cd.keys {
            let hd = HistoricalData(date: Date(), type:ex_type_to_str(ex_type:params.type), id:short_answer(answer: k), listening: cd[k]!)
            modelContext.insert(hd)
        }
        try! modelContext.save()
        ListeningView.player.clear_cacheData()
    }
}
