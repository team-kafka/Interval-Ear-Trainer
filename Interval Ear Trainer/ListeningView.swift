//
//  TriadListeningView.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2024/12/26.
//

import SwiftUI
import MediaPlayer

struct ListeningView: View {
    @State var params: Parameters
    var sequenceGenerator: SequenceGenerator
    var player: ListeningModePlayer
    @State private var playing: Bool
    
    @Binding var dftDelay: Double
    @Binding var dftFilterStr: String


    init(params: Parameters, dftDelay: Binding<Double>, dftFilterStr: Binding<String>){
        _params = .init(initialValue: params)
        if (params.type == .interval) {
            self.sequenceGenerator = IntervalGenerator()
        } else if (params.type == .triad){
            self.sequenceGenerator = TriadGenerator()
        } else {
            self.sequenceGenerator = ScaleDegreeGenerator()
        }
        _playing = .init(initialValue: false)
        self.player = ListeningModePlayer(params: params, sequenceGenerator: sequenceGenerator)
        
        _dftDelay = .init(projectedValue: dftDelay)
        _dftFilterStr = .init(projectedValue: dftFilterStr)
    }
    
    var body: some View {
        HStack{
            (self.playing ? Image(systemName: "speaker.slash.fill") : Image(systemName: "speaker.wave.2")).onTapGesture {
                if !self.playing {
                    start()
                } else {
                    stop()
                }
            }
            if (params.type == .scale_degree) {
                Image(systemName: "die.face.5").foregroundColor(Color(.systemGray)).onTapGesture {
                    stop()
                    params.key = NOTE_KEYS.randomElement()!
                }
            } else{
                ChordArpSwitchView(chord: $params.is_chord)
            }
            NavigationLink(destination: ParametersView(params: $params).navigationBarBackButtonHidden(true).onAppear {stop()}){
            }.opacity(0)
            Text(sequenceGenerator.generateLabelString(params: params)).lineLimit(1)
            Image(systemName: "gearshape.fill")
        }.onAppear{
            update_function(newParams: params)
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(AVAudioSession.Category.playback, mode: .default, options: [.mixWithOthers])
                try session.setActive(true)
            } catch let error as NSError {
                print("Failed to set the audio session category and mode: \(error.localizedDescription)")
            }
        }
    }
    
    func start() {
        self.playing = true
        player.start(params: params)
    }
    
    func stop(){
        self.playing = false
        player.stop()
    }

    func update_function(newParams: Parameters){
        dftDelay = newParams.delay
        dftFilterStr = sequenceGenerator.generateFilterString(params: newParams)
    }
}
