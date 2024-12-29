//
//  ListeningView.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2024/12/23.
//

import SwiftUI

struct IntervalListeningView: View {
    @State var intParams: IntervalParameters
    @State var seqParams: SequenceParameters
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
            NavigationLink(destination: IntervalParametersView(intParams: $intParams, seqParams: $seqParams).navigationBarBackButtonHidden(true)){
            }.opacity(0)
            Text(interval_filter_to_str(intervals:intParams.active_intervals)).lineLimit(1)
            Image(systemName: "gearshape.fill")
        }.onAppear{ update_function(newIntParams: intParams, newSeqParams: seqParams) }
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
        notes[0] = Int.random(in: seqParams.lower_bound..<seqParams.upper_bound)
        notes[1] = draw_new_note(prev_note: notes[0], active_intervals: intParams.active_intervals, upper_bound: seqParams.upper_bound, lower_bound: seqParams.lower_bound, largeIntevalsProba: intParams.largeIntevalsProba)
        player.playNotes(notes: notes, duration: seqParams.delay_sequence, chord: false)
        timer = Timer.scheduledTimer(withTimeInterval:seqParams.delay, repeats: false) { t in
            loopFunction()
        }
    }
    
    func update_function(newIntParams: IntervalParameters, newSeqParams: SequenceParameters){
        dftDelay = newSeqParams.delay
        dftFilterStr = interval_filter_to_str(intervals: newIntParams.active_intervals)
    }
}

