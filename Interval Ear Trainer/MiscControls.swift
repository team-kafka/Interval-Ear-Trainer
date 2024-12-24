//
//  MiscControls.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2024/12/24.
//

import SwiftUI


struct CheckBoxView: View {
    @Binding var checked: Bool
    
    var body: some View {
        Image(systemName: checked ? "checkmark.square.fill" : "square")
            .foregroundColor(Color.secondary)
            .onTapGesture {
                checked.toggle()
            }
    }
}


struct ChordButton : View{
    @Binding var running : Bool
    @Binding var params : Parameters
    @Binding var player : MidiPlayer
    var notes : [Int]

    var body: some View {
        Image(systemName: "music.quarternote.3").foregroundColor(Color(.systemGray)).padding().overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 4)).onTapGesture {
                  if ((notes[0] != 0) && !running){
                      player.playNotes(notes: notes, duration: params.delay*0.5, chord: true)
                    }
                }.opacity(((notes[0] != 0) && !running) ? 1.0 : 0.5)
    }
}


struct NoteButton : View{
    @Binding var running : Bool
    @Binding var params : Parameters
    @Binding var player : MidiPlayer
    var note : Int

    var body: some View {
        Image(systemName: "music.note").foregroundColor(Color(.systemGray)).padding().overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 4)).onTapGesture {
                  if ((note != 0) && !running){
                      player.playNotes(notes: [note], duration: 0.8)
                    }
                }.opacity(((note != 0) && !running) ? 1.0 : 0.5)
    }
}


struct TimerView: View {
    @Binding var active: Bool
    
    var body: some View {
        Image(systemName: active ? "clock" : "infinity.circle")
            .foregroundColor(Color.secondary)
            .onTapGesture {
                active.toggle()
            }
    }
}

struct ChordArpSwitchView: View {
    @Binding var chord: Bool
    
    var body: some View {
        let rotation = chord ? 90.0 : 0.0
        Image(systemName:"00.square").rotationEffect(Angle(degrees: rotation))
            .foregroundColor(Color.secondary)
            .onTapGesture {
                chord.toggle()
            }
    }
}


struct NumberOfNotesView: View {
    @Binding var n_notes: Int
    @Binding var notes: [Int]

    var body: some View {
        Image(systemName: String(format:"%d.square", n_notes))
            .foregroundColor(Color.secondary)
            .onTapGesture {
                n_notes = n_notes + 1 > 4 ? 1 : n_notes + 1
                notes = [Int](repeating: 0, count: max(2, n_notes))
            }
    }
}
