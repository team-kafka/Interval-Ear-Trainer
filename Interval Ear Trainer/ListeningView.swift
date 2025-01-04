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
    @State private var playing: Bool
    @State var n_notes: Int
    @State var chord: Bool
    @State private var speakerImg: Image
    @State private var timer: Timer?
    
    @Binding var dftDelay: Double
    @Binding var dftFilterStr: String

    var player = MidiPlayer()

    
    init(params: Parameters, dftDelay: Binding<Double>, dftFilterStr: Binding<String>, n_notes: Int=2, chord: Bool=false){
        _params = .init(initialValue: params)
        if (params.type == .interval) {
            self.sequenceGenerator = IntervalGenerator()
        } else if (params.type == .triad){
            self.sequenceGenerator = TriadGenerator()
        } else {
            self.sequenceGenerator = ScaleDegreeGenerator()
        }
        _speakerImg = .init(initialValue: Image(systemName: "speaker.wave.2.fill"))
        _n_notes = .init(initialValue: n_notes)
        _playing = .init(initialValue: false)
        _chord = .init(initialValue: chord)
        self.player = MidiPlayer()
        _timer = .init(initialValue: nil)
        _dftDelay = .init(projectedValue: dftDelay)
        _dftFilterStr = .init(projectedValue: dftFilterStr)
    }
    
    var body: some View {
        HStack{
            speakerImg.onTapGesture {
                if !playing {
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
                ChordArpSwitchView(chord: $chord)
            }
            NavigationLink(destination: ParametersView(params: $params).navigationBarBackButtonHidden(true)){
            }.opacity(0)
            Text(sequenceGenerator.generateLabelString(params: params)).lineLimit(1)
            Image(systemName: "gearshape.fill")
        }.onAppear{update_function(newParams: params)}
    }
    
    func start() {
        speakerImg = Image(systemName:"speaker.slash.fill")
        playing = true
        timer?.invalidate()
        if (params.type == .scale_degree) {
            player.playNotes(notes: scale_notes(scale: params.scale, key: params.key, upper_bound: params.upper_bound, lower_bound: params.lower_bound), duration: params.delay_sequence*0.8)
            timer = Timer.scheduledTimer(withTimeInterval:params.delay_sequence * 0.8 * 7, repeats: false) { t in
                loopFunction()
            }
        } else {
            loopFunction()
        }
        
    }
    
    func stop(){
        timer?.invalidate()
        playing = false
        speakerImg = Image(systemName:"speaker.wave.2.fill")
    }

    func loopFunction() {
        var delay = params.delay
        delay += play_sequence()
        timer = Timer.scheduledTimer(withTimeInterval:delay, repeats: false) { t in
            loopFunction()
        }
    }
    
    func play_sequence() -> Double {
        var delay: Double
        var duration: Double
        var notes: [Int] = [0, 0]
        
        (notes, duration, delay, _, _) = sequenceGenerator.generateSequence(params: params, n_notes:n_notes, chord:chord, prev_note:0)
        player.playNotes(notes: notes, duration: duration, chord: chord)

        return delay
    }
        
    func update_function(newParams: Parameters){
        dftDelay = newParams.delay
        dftFilterStr = sequenceGenerator.generateFilterString(params: newParams)
    }
}
