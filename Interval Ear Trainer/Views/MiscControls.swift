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

struct ChordButton : View {
    var running : Bool
    var duration : Double
    var notes : [Int]
    var chord : Bool
    var chord_delay: Double
    
    var body: some View {
        Image(systemName: "music.quarternote.3").foregroundColor(Color(.systemGray)).padding().overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 4)).onTapGesture {
                  if ((notes[0] != 0) && !running){
                      MidiPlayer.shared.playNotes(notes: notes, duration: chord ? duration : chord_delay, chord: chord)
                    }
                }.opacity(((notes[0] != 0) && !running) ? 1.0 : 0.5)
    }
}

struct NoteButton : View {
    var running : Bool
    var note : Int
    var duration : Double

    var body: some View {
        Image(systemName: "music.note").foregroundColor(Color(.systemGray)).padding().overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 4)).onTapGesture {
                  if ((note != 0) && !running){
                      MidiPlayer.shared.playNotes(notes: [note], duration: duration)
                    }
                }.opacity(((note != 0) && !running) ? 1.0 : 0.5)
    }
}

struct NoteButtonsView: View {
    @AppStorage("showHelp") var showHelp: Bool = false
    
    var params: Parameters
    var notes: [Int]
    var root_note: Int
    var running: Bool
    var chord: Bool
    var answer_visible: Double
    var fixed_n_notes: Bool
    
    init(params: Parameters, notes: [Int], root_note: Int, chord: Bool, running: Bool, answer_visible: Double, fixed_n_notes: Bool, chord_active: Bool) {
        self.params =  params
        self.notes = notes
        self.root_note = root_note
        self.running = running
        self.chord = chord
        self.fixed_n_notes = fixed_n_notes
        self.answer_visible = answer_visible
    }
    
    var body: some View {
        Grid{
            GridRow(alignment: .center){
                if chord{ ChordButton(running: running, duration: params.delay * 0.5, notes: notes, chord: chord, chord_delay: params.delay_sequence) }
                ForEach(Array(notes.enumerated()), id: \.offset) { _, note in
                    NoteButton(running: running, note: note, duration: params.delay_sequence)
                }
                if showHelp{ HelpMarkView{ HelpNotesPOView() } }
            }
            GridRow(alignment: .center){
                if chord{ Text(" ").opacity(0.0) }
                ForEach(Array(notes.enumerated()), id: \.offset) { _, note in
                    Text(midi_note_to_name(note_int: note)).opacity(answer_visible).foregroundStyle(Color(.systemGray)).fontWeight((note == root_note) ? .bold : .regular)
                }
                if showHelp{ Text(" ").opacity(0) }
            }
        }
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
        let rotation = (chord) ? 90.0 : 0.0
        Image(systemName:"00.square.hi").rotationEffect(Angle(degrees: rotation))
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
    var active: Bool = true
    var visible: Bool = true

    var body: some View {
        let opacity:Double = (visible ? 1 : 0)
        Image(systemName: String(format:"%d.square", n_notes))
            .foregroundColor(Color.secondary).opacity(opacity)
            .onTapGesture {
                if active {
                    n_notes = n_notes + 1 > 4 ? 1 : n_notes + 1
                }
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
                    if (active.count > 1) {
                        active.remove(at: active.firstIndex(of: interval_int)!)
                    }
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
                    if (active.count > 1) {
                        active.remove(at: active.firstIndex(of: key)!)
                    }
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
    @AppStorage("showHelp") var showHelp: Bool = false
    @Binding var params: Parameters
    var running: Bool

    init(params: Binding<Parameters>, running: Bool) {
        _params = .init(projectedValue: params)
        self.running = running
    }

    var body: some View {
        Grid{
            GridRow{
                HStack(alignment: .center){
                    Image(systemName: "die.face.5").foregroundColor(Color(.systemGray)).padding([.leading]).onTapGesture {
                        if !running {
                            params.key = NOTE_KEYS.randomElement()!
                        }
                    }.scaleEffect(1.5)
                    if showHelp {HelpMarkView(){HelpTextView(text:"Select random key")}.padding(4)}
                }
                Menu{
                    Picker("key", selection: $params.key) {
                        ForEach(NOTE_KEYS, id: \.self) {
                            Text($0).font(.system(size: 35)).accentColor(Color(.systemGray)).gridColumnAlignment(.leading)
                        }
                    }
                } label: {
                    Text(params.key).font(.system(size: 35)).accentColor(Color(.systemGray))
                }
            }
            GridRow{
                Image(systemName:"speaker.wave.2.fill").foregroundColor(Color(.systemGray)).padding([.trailing, .leading]).onTapGesture {
                    if !running {
                        play_scale(params:params)
                    }
                }.scaleEffect(1.5)
                Menu{
                    Picker("Scale", selection: $params.scale) {
                        ForEach(SCALE_KEYS, id: \.self) {
                            Text($0).font(.system(size: 35)).gridColumnAlignment(.leading)
                        }
                    }.accentColor(Color(.systemGray))
                } label: {
                    Text(params.scale).font(.system(size: 35)).accentColor(Color(.systemGray))
                }
            }
        }
    }
    
    func play_scale(params:Parameters){
        MidiPlayer.shared.playNotes(notes: scale_notes(scale: params.scale, key: params.key, upper_bound: params.upper_bound, lower_bound: params.lower_bound), duration: SCALE_DELAY)
    }
}

struct QuickParamButtonsView: View {
    @AppStorage("showHelp") var showHelp: Bool = false
    
    @Binding var n_notes: Int
    @Binding var chord: Bool
    @Binding var use_timer: Bool
    @Binding var fixed_n_notes: Bool
    @Binding var chord_active: Bool
    
    init(n_notes: Binding<Int>, chord: Binding<Bool>, use_timer: Binding<Bool>, fixed_n_notes: Binding<Bool>, chord_active: Binding<Bool>) {
        _n_notes = .init(projectedValue: n_notes)
        _chord = .init(projectedValue: chord)
        _use_timer = .init(projectedValue: use_timer)
        _fixed_n_notes = .init(projectedValue: fixed_n_notes)
        _chord_active = .init(projectedValue: chord_active)
    }
    
    var body: some View {
        HStack{
            Spacer()
            NumberOfNotesView(n_notes: $n_notes, active: !fixed_n_notes, visible: !fixed_n_notes).scaleEffect(2.0)
            if (showHelp && !fixed_n_notes) { HelpMarkView{HelpNNotesPOView()}.padding(4) }
            Spacer()
            TimerView(active: $use_timer).scaleEffect(2.0)
            if showHelp { HelpMarkView{HelpTimerPOView()}.padding(4) }
            Spacer()
            ChordArpSwitchView(chord: $chord, active: chord_active, visible: chord_active).scaleEffect(2.0)
            if (showHelp && chord_active) { HelpMarkView{HelpChordPOView()}.padding(4) }
            Spacer()
        }
    }
}
