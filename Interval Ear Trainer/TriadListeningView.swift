//
//  TriadListeningView.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2024/12/26.
//

import SwiftUI

struct TriadListeningView: View {
    @State var params: TriadParameters
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
            NavigationLink(destination: TriadParametersView(params: $params).navigationBarBackButtonHidden(true)){
            }.opacity(0)
            Text(triad_qualities_to_str(active_qualities:params.active_qualities)).lineLimit(1)
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
        let res = draw_random_triad(params: params)
        var delay = 0.0
        if chord {
            player.playNotes(notes: res.0, duration: params.delay * 0.5 , chord: true)
        } else {
            player.playNotes(notes: res.0, duration: params.delay_arpeggio, chord: false)
            delay = params.delay_arpeggio * 2.0 * 0.5 
        }
        timer = Timer.scheduledTimer(withTimeInterval:params.delay + delay, repeats: false) { t in
            loopFunction()
        }
    }
    
    func update_function(newParams: TriadParameters){
        dftDelay = newParams.delay
        dftFilterStr = triad_filters_to_str(active_qualities: newParams.active_qualities, active_inversions: newParams.active_inversions, active_voicings: newParams.active_voicings)
    }
}

