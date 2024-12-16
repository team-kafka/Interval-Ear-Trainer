//
//  PracticeView.swift
//  My First App
//
//  Created by Nicolas on 2024/12/04.
//

import SwiftUI

struct PracticeView: View {
    @State var params  = Parameters.init_value
    @State private var button_lbl = Image(systemName: "play.circle")
    @State private var running = false
    @State private var answer = Text(" ")
    @State private var note1:Int = 0
    @State private var note2:Int = 0
    @State private var timer: Timer?
    @State var visible: Double = 0.0
    @State var n_notes:Int = 1
    let player = MidiPlayer()
    
    
    var body: some View {
        
        NavigationStack{
            VStack {
                HStack{
                    Spacer()
                    NavigationLink(destination: ParameterView(params: $params).onAppear {stop()}){
                        Image(systemName: "gearshape.fill")
                    }.accentColor(Color(.systemGray))
                }
            Spacer()
              //      Picker("Number of Notes", selection: $n_notes) {
              //          ForEach(0..<4, id: \.self) {
              //              Text("\($0)")
              //          }
              //      }.onChange(of: n_notes) {
              //  }

            HStack {
                Spacer()
                Button(action:toggle_start_stop){
                    button_lbl.resizable().scaledToFit()
                }.accentColor(Color(.systemGray))
                Spacer()
            }
                Grid{
                    GridRow{
                        //padding(2)
                        Image(systemName: "music.note").foregroundColor(Color(.systemGray)).padding().overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.gray, lineWidth: 4)).padding().onTapGesture {
                                    if (note1 != 0){
                                        player.playNote(note: note1, duration: params.delay*0.45)
                                    }
                                }.opacity(running ? 0.5 : 1.0)
                        Image(systemName: "music.note").foregroundColor(Color(.systemGray)).padding().overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.gray, lineWidth: 4)).padding().onTapGesture {
                                    if (note2 != 0){
                                        player.playNote(note: note2, duration: params.delay*0.45)
                                    }
                                }.opacity(running ? 0.5 : 1.0)
                    }
                }
                answer.bold().opacity(visible).font(.system(size: 60)).foregroundStyle(Color(.systemGray))
                Spacer()
                
        }.background(Color(.black))
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            stop()
        }

    }

    func toggle_start_stop() {
        running.toggle()
        if running {
            start()
        }
        else{
            stop()
        }
    }
    
     func onTick() {
         if ((note2 == 0) && (note1 == 0) ){
             visible = 0
             note1 = Int.random(in: params.lower_bound..<params.upper_bound)
             player.playNote(note: note1, duration: params.delay*0.45)
         }
         else if ((note2 == 0) && (note1 != 0) ){
            note2 = draw_new_note(prev_note: note1, params: params)
            player.playNote(note: note2, duration: params.delay*0.45)
         } else if (visible == 0){
             answer = Text("\(interval_name(interval_int: note2-note1, oriented: true))")
             visible = 1
         } else{
             visible = 0
             note1 = note2
             note2 = draw_new_note(prev_note: note1, params: params)
             player.playNote(note: note2, duration: params.delay*0.45)
        }
    }

    func start() {
        button_lbl = Image(systemName: "pause.circle")
        running = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval:params.delay*0.5, repeats: true) { t in
            onTick()
        }
    }
    
    func stop(){
        button_lbl = Image(systemName: "play.circle")
        running = false
        timer?.invalidate()
    }
    
}



#Preview {
    PracticeView()
}


        
