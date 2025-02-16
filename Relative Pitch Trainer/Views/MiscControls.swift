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
    var active : Bool
    var visible : Double
    var duration : Double
    var notes : [Int]
    var chord : Bool
    var chord_delay: Double
    
    var body: some View {
        Image(systemName: "music.quarternote.3").foregroundColor(Color(.systemGray)).padding().overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 4)).onTapGesture {
                  if ((notes[0] != 0) && !active){
                      MidiPlayer.shared.playNotes(notes: notes, duration: chord ? duration : chord_delay, chord: chord)
                    }
                }.opacity(((notes[0] != 0) && !active) ? visible : 0.5 * visible)
    }
}

struct NoteButton : View {
    var active : Bool
    var visible : Double
    var note : Int
    var duration : Double

    var body: some View {
        Image(systemName: "music.note").foregroundColor(Color(.systemGray)).padding().overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 4)).onTapGesture {
                  if ((note != 0) && !active){
                      MidiPlayer.shared.playNotes(notes: [note], duration: duration)
                    }
                }.opacity(((note != 0) && !active) ? visible : 0.5 * visible)
    }
}

struct NoteButtonsView: View {
    @AppStorage("showHelp") var showHelp: Bool = false
    
    var params: Parameters
    var notes: [Int]
    var root_note: Int
    var active: Bool
    var chord: Bool
    var answer_visible: Double
    var hasChord: Bool
    var visible: Double
    
    init(params: Parameters, notes: [Int], root_note: Int, chord: Bool, active: Bool, answer_visible: Double, hasChord: Bool, visible: Double = 1.0) {
        self.params =  params
        self.notes = notes
        self.root_note = root_note
        self.active = active
        self.chord = chord
        self.hasChord = hasChord
        self.answer_visible = answer_visible
        self.visible = visible
    }
    
    var body: some View {
        Grid{
            GridRow(alignment: .center){
                if hasChord { ChordButton(active: active, visible: chord ? visible : 0.0, duration: params.delay * 0.5, notes: notes, chord: chord, chord_delay: params.delay_sequence) }
                ForEach(0...3, id: \.self) { i in
                    let note = i < notes.count ? notes[i] : 0
                    NoteButton(active: active, visible: i < notes.count ? visible : 0.0, note: note, duration: params.delay_sequence)
                }
                if showHelp{ HelpMarkView(opacity: visible * 0.3){ HelpNotesPOView() } }
            }
            GridRow(alignment: .center){
                if hasChord { Text(" ").opacity(0.0) }
                ForEach(0...3, id: \.self) { i in
                    let note = i < notes.count ? notes[i] : 0
                    let opacity = i < notes.count ? answer_visible * visible : 0.0
                    Text(midi_note_to_name(note_int: note)).opacity(opacity).foregroundStyle(Color(.systemGray)).fontWeight((note == root_note) ? .bold : .regular)
                }
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
    var fontSize: CGFloat

    init(params: Binding<Parameters>, running: Bool, fontSize: CGFloat = 30) {
        _params = .init(projectedValue: params)
        self.running = running
        self.fontSize = fontSize
    }

    var body: some View {
        Grid(alignment: .leading) {
            GridRow{
                HStack(alignment: .center){
                    if showHelp {HelpMarkView(){HelpTextView(text:"Select a random key")}.padding(4)}
                    Image(systemName: "die.face.5").foregroundColor(Color(.systemGray)).padding([.trailing]).onTapGesture {
                        if !running {
                            params.key = NOTE_KEYS.randomElement()!
                        }
                    }.scaleEffect(1.5)
                }
                Menu{
                    Picker("key", selection: $params.key) {
                        ForEach(NOTE_KEYS, id: \.self) {
                            Text($0).font(.system(size: fontSize)).accentColor(Color(.systemGray)).gridColumnAlignment(.leading)
                        }
                    }
                } label: {
                    Text(params.key).font(.system(size: fontSize)).accentColor(Color(.systemGray))
                }
            }
            GridRow{
                HStack(alignment: .center){
                    if showHelp {HelpMarkView(){HelpTextView(text:"Play the scale")}.padding(4)}
                    Image(systemName:"speaker.wave.2.fill").foregroundColor(Color(.systemGray)).padding([.trailing]).onTapGesture {
                        if !running {
                            play_scale(params:params)
                        }
                    }.scaleEffect(1.5)
                }
                Menu{
                    Picker("Scale", selection: $params.scale) {
                        ForEach(SCALE_KEYS, id: \.self) {
                            Text($0).font(.system(size: fontSize)).gridColumnAlignment(.leading).lineLimit(1)
                        }
                    }.accentColor(Color(.systemGray))
                } label: {
                    Text(params.scale).font(.system(size: fontSize)).accentColor(Color(.systemGray))
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
            ChordArpSwitchView(chord: $chord, active: chord_active, visible: chord_active).scaleEffect(2.0)
            if (showHelp && chord_active) { HelpMarkView{HelpChordPOView()}.padding(4) }
            Spacer()
            TimerView(active: $use_timer).scaleEffect(2.0)
            if showHelp { HelpMarkView{HelpTimerPOView()}.padding(4) }
            Spacer()
        }
    }
}

struct StreakView: View {
    @AppStorage("showHelp") var showHelp: Bool = false
    
    @Binding var streak_c: Int
    @Binding var streak_i: Int
    @Binding var streak_t: Int

    init(streak_c: Binding<Int>, streak_i: Binding<Int>, streak_t: Binding<Int>) {
        _streak_c = .init(projectedValue: streak_c)
        _streak_i = .init(projectedValue: streak_i)
        _streak_t = .init(projectedValue: streak_t)
    }
    
    var body: some View {
        HStack{
            Text("\(streak_c)").foregroundStyle(ANSWER_COLORS[.correct]!).font(.footnote)
            Text("\(streak_i)").foregroundStyle(ANSWER_COLORS[.incorrect]!).font(.footnote)
            Text("\(streak_t)").foregroundStyle(ANSWER_COLORS[.timeout]!).font(.footnote)
            Text("\(streak_c + streak_i + streak_t)").foregroundStyle(.secondary).font(.footnote)
            if showHelp {HelpMarkView(){HelpTextView(text:"The current streak. Tap to reset")}.padding(4).scaleEffect(0.7)}
        }.onTapGesture {
            streak_c = 0
            streak_i = 0
            streak_t = 0
        }
    }
}
