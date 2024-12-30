//
//  TriadListeningView.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2024/12/26.
//

import SwiftUI

struct ListeningView: View {
    @State var params: Parameters
    var sequenceGenerator: SequenceGenerator
    @State private var playing: Bool = false
    @State var chord: Bool = true
    @State private var spakerImg: Image = Image(systemName:"speaker.wave.2.fill")
    @State private var timer: Timer?
    
    @Binding var dftDelay: Double
    @Binding var dftFilterStr: String

    var player = MidiPlayer()
    
    var body: some View {
        HStack{
            spakerImg.onTapGesture {
                if !playing {
                    start()
                } else {
                    stop()
                }
            }
            ChordArpSwitchView(chord: $chord, active: true)
            NavigationLink(destination: ParametersView(params: $params).navigationBarBackButtonHidden(true)){
            }.opacity(0)
            Text(sequenceGenerator.generateLabelString(params: params)).lineLimit(1)
            Image(systemName: "gearshape.fill")
        }.onAppear{update_function(newParams: params)}
    }
    
    func start() {
        spakerImg = Image(systemName:"speaker.slash.fill")
        playing = true
        timer?.invalidate()
        loopFunction()
    }
    
    func stop(){
        timer?.invalidate()
        playing = false
        spakerImg = Image(systemName:"speaker.wave.2.fill")
    }

    func loopFunction() {
        var delay = params.delay * 0.5
        delay += play_sequence()
        timer = Timer.scheduledTimer(withTimeInterval:delay, repeats: false) { t in
            loopFunction()
        }
    }
    
    func play_sequence() -> Double {
        var delay: Double
        var duration: Double
        var notes: [Int] = [0, 0]
        
        (notes, duration, delay, _, _) = sequenceGenerator.generateSequence(params: params, n_notes:2, chord:chord, prev_note:0)
        player.playNotes(notes: notes, duration: duration, chord: chord)

        return delay
    }
        
    func update_function(newParams: Parameters){
        dftDelay = newParams.delay
        dftFilterStr = sequenceGenerator.generateFilterString(params: newParams)
    }
}
