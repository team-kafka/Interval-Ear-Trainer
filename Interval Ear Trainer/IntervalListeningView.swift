//
//  ListeningView.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2024/12/23.
//

import SwiftUI

struct IntervalListeningView: View {
    @State var params: IntervalParameters
    @State private var playing:Bool = false
    @State private var spakerImg:Image = Image(systemName:"speaker.wave.2.fill")
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
            NavigationLink(destination: IntervalParametersView(params: $params).navigationBarBackButtonHidden(true)){
            }.opacity(0)
            Text(interval_filter_to_str(intervals:params.active_intervals)).lineLimit(1)
            Image(systemName: "gearshape.fill")
        }.onAppear{ update_function(newParams: params)}
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
        var notes: [Int] = [0, 0]
        notes[0] = Int.random(in: params.lower_bound..<params.upper_bound)
        notes[1] = draw_new_note(prev_note: notes[0], active_intervals: params.active_intervals, upper_bound: params.upper_bound, lower_bound: params.lower_bound, largeIntevalsProba: params.largeIntevalsProba)
        player.playNotes(notes: notes, duration: params.delay_sequence, chord: false)
        timer = Timer.scheduledTimer(withTimeInterval:params.delay, repeats: false) { t in
            loopFunction()
        }
    }
    
    func update_function(newParams: IntervalParameters){
        dftDelay = newParams.delay
        dftFilterStr = interval_filter_to_str(intervals: newParams.active_intervals)
    }
}

