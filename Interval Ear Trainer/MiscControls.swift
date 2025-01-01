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
    var chord : Bool
    var chord_delay: Double
    var body: some View {
        Image(systemName: "music.quarternote.3").foregroundColor(Color(.systemGray)).padding().overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 4)).onTapGesture {
                  if ((notes[0] != 0) && !running){
                      player.playNotes(notes: notes, duration: chord ? duration : chord_delay, chord: chord)
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
    var active: Bool = true
    var visible: Bool = true

    var body: some View {
        let rotation = (chord && active) ? 90.0 : 0.0
        Image(systemName:"00.square").rotationEffect(Angle(degrees: rotation))
            .foregroundColor(Color.secondary).opacity(visible ? 1 : 0)
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
    var active: Bool = true
    var visible: Bool = true

    var body: some View {
        let opacity:Double = (visible ? 1 : 0) * (active ? 1 : 0.5)
        Image(systemName: String(format:"%d.square", n_notes))
            .foregroundColor(Color.secondary).opacity(opacity)
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

struct ScaleChooserView: View {
    @Binding var params: Parameters
    @Binding var player: MidiPlayer
    var reset_state: () -> Void

init(params: Binding<Parameters>, player: Binding<MidiPlayer>, reset_state: @escaping () -> Void) {
    _params = .init(projectedValue: params)
    _player = .init(projectedValue: player)
    self.reset_state = reset_state
}

var body: some View {

    Grid{
        GridRow{
            Image(systemName: "die.face.5").foregroundColor(Color(.systemGray)).padding([.leading, .trailing]).onTapGesture {
                params.key = NOTE_KEYS.randomElement()!
            }.scaleEffect(1.5)
            Menu{
                Picker("key", selection: $params.key) {
                    ForEach(NOTE_KEYS, id: \.self) {
                        Text($0).font(.system(size: 35)).accentColor(Color(.systemGray)).gridColumnAlignment(.leading)
                    }
                }.onChange(of: params.key) {reset_state()}
            } label: {
                Text(params.key).font(.system(size: 35)).accentColor(Color(.systemGray)).gridColumnAlignment(.leading)
            }.gridColumnAlignment(.leading)
        }
        GridRow{
            Image(systemName:"speaker.wave.2.fill").foregroundColor(Color(.systemGray)).padding([.trailing, .leading]).onTapGesture {
                player.playNotes(notes: scale_notes(scale: params.scale, key: params.key, upper_bound: params.upper_bound, lower_bound: params.lower_bound), duration: params.delay_sequence*0.8)
            }.scaleEffect(1.5)
            Menu{
                Picker("Scale", selection: $params.scale) {
                    ForEach(SCALE_KEYS, id: \.self) {
                        Text($0).font(.system(size: 35)).gridColumnAlignment(.leading)
                    }
                }.accentColor(Color(.systemGray)).onChange(of: params.scale) {reset_state()}
            } label: {
                Text(params.scale).font(.system(size: 35)).accentColor(Color(.systemGray)).gridColumnAlignment(.leading)
            }.gridColumnAlignment(.leading)
        }
    }
}
}

struct QuickParamButtonsView: View {
    @Binding var params: Parameters
    @Binding var notes: [Int]
    @Binding var n_notes: Int
    @Binding var chord: Bool
    @Binding var use_timer: Bool
    @Binding var fixed_n_notes: Bool
    @Binding var chord_active: Bool
    var reset_state: () -> Void
    var stop: () -> Void

init(params: Binding<Parameters>, notes: Binding<[Int]>, n_notes: Binding<Int>, chord: Binding<Bool>, use_timer: Binding<Bool>, fixed_n_notes: Binding<Bool>, chord_active: Binding<Bool>, reset_state: @escaping () -> Void, stop: @escaping () -> Void) {
    _params = .init(projectedValue: params)
    _notes = .init(projectedValue: notes)
    _n_notes = .init(projectedValue: n_notes)
    _chord = .init(projectedValue: chord)
    _use_timer = .init(projectedValue: use_timer)
    _fixed_n_notes = .init(projectedValue: fixed_n_notes)
    _chord_active = .init(projectedValue: chord_active)
    self.reset_state = reset_state
    self.stop = stop
}

var body: some View {
    HStack{
    Spacer()
    NavigationLink(destination: ParametersView(params: $params).navigationBarBackButtonHidden(true).onAppear {stop()}){
        Image(systemName: "gearshape.fill")
    }.accentColor(Color(.systemGray)).padding([.trailing]).scaleEffect(1.5)
    }
    HStack{
        NumberOfNotesView(n_notes: $n_notes, notes: $notes, active: !fixed_n_notes, visible: !fixed_n_notes).padding().onChange(of: n_notes){
            reset_state()
            if (n_notes == 1) {chord = false}
        }
        TimerView(active: $use_timer).padding().onChange(of: use_timer){reset_state()}
    ChordArpSwitchView(chord: $chord, active: (chord_active && (n_notes>1)), visible: chord_active).padding().onChange(of: chord){reset_state()}
    }.scaleEffect(2.0)
}
}
