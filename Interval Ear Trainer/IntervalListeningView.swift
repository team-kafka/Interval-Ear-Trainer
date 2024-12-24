//
//  ListeningView.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2024/12/23.
//

import SwiftUI

struct IntervalListeningView: View {
    @State var params = IntervalParameters.init_value
    @State private var playing:Bool = false
    @State private var spakerImg:Image = Image(systemName:"speaker.wave.2.fill")
    @State private var timer: Timer?
    @State var player = MidiPlayer()
    
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
            Text(active_intervals_string(intervals:params.active_intervals)).lineLimit(1)
            //Spacer()
            Image(systemName: "gearshape.fill")
        }
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
        notes[1] = draw_new_note(prev_note: notes[0], params: params)
        player.playNotes(notes: notes, duration: params.delay_sequence, chord: false)
        timer = Timer.scheduledTimer(withTimeInterval:params.delay, repeats: false) { t in
            loopFunction()
        }
    }
}

#Preview {
    IntervalListeningView()
}
