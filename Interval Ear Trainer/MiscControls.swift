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
    var running : Bool
    var duration : Double
    @Binding var player : MidiPlayer
    var notes : [Int]

    var body: some View {
        Image(systemName: "music.quarternote.3").foregroundColor(Color(.systemGray)).padding().overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 4)).onTapGesture {
                  if ((notes[0] != 0) && !running){
                      player.playNotes(notes: notes, duration: duration, chord: true)
                    }
                }.opacity(((notes[0] != 0) && !running) ? 1.0 : 0.5)
    }
}


struct NoteButton : View{
    var running : Bool
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
    var active: Bool
    var body: some View {
        let rotation = (chord && active) ? 90.0 : 0.0
        Image(systemName:"00.square").rotationEffect(Angle(degrees: rotation))
            .foregroundColor(Color.secondary)
            .onTapGesture {
                if active {
                    chord.toggle()
                }
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

struct ParamSlider: View {
    @Binding var value : Double
    var valueRange: ClosedRange<Double>
    var body: some View {
            Slider(
                value: $value,
                in: valueRange
            )
    }
}

struct IntervalCheckBoxView: View {
    @Binding var active: Set<Int>
    var interval_int: Int
    
    var body: some View {
        Image(systemName: active.contains(interval_int) ? "checkmark.square.fill" : "square")
            .foregroundColor(active.contains(interval_int) ? Color(UIColor.systemBlue) : Color.secondary)
            .onTapGesture {
                if (active.contains(interval_int))
                {
                    active.remove(at: active.firstIndex(of: interval_int)!)
                } else
                {
                    active.insert(interval_int)
                }
            }
    }
}

struct ChordCheckBoxView: View {
    @Binding var active: Set<String>
    var key: String
    
    var body: some View {
        Image(systemName: active.contains(key) ? "checkmark.square.fill" : "square")
            .foregroundColor(active.contains(key) ? Color(UIColor.systemBlue) : Color.secondary)
            .onTapGesture {
                if (active.contains(key))
                {
                    active.remove(at: active.firstIndex(of: key)!)
                } else
                {
                    active.insert(key)
                }
            }
    }
}

struct NoteStepperView: View {
    @Binding var value: Int
    var caption: String
    var other_bond: Int
    
    var body: some View {
        Stepper {
            Text(caption)
        } onIncrement: {
            if (abs(value+1-other_bond)>30){
                value += 1}
        } onDecrement: {
            if (abs(value-1-other_bond)>30){
                value -= 1}
        }
    }
}

