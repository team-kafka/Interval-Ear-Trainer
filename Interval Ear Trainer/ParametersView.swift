//
//  Params.swift
//  My First App
//
//  Created by Nicolas on 2024/12/06.
//

import SwiftUI


let PRESET_MAPPING: [String : Set<Int>] = [
    "Large Intervals": [-11, -10, -9, -8, 8, 9, 10, 11],
    "3rds": [-3, -4, 3, 4],
    "4ths and 5ths": [-5, -6, -7, 5, 6, 7],
    "": Parameters().active_intervals
              ]

struct ParametersView: View {
    @Binding var params : Parameters
    @State private var preset = 0
    
    let player = MidiPlayer()
    
    let preset_values = ["", "3rds", "Large Intervals", "4ths and 5ths"] // get this from dict
    
    var body: some View {
        NavigationView{
            VStack{
                List{
                    Section(header: Text("general")) {
                        if (params.type == .scale_degree){
                            Picker("Scale", selection: $params.scale) {
                                ForEach(SCALE_KEYS, id: \.self) {
                                    Text($0)
                                }
                            }
                            Picker("Key", selection: $params.key) {
                                ForEach(NOTE_KEYS, id: \.self) {
                                    Text($0)
                                }
                            }
                        }
                        VStack{
                            HStack{Text("Delay (seconds)");Spacer()}
                            HStack{ParamSlider(value: $params.delay, valueRange: 0.2...5.0);Text("\(params.delay, specifier:"%0.1f")")}
                        }
                        if ((params.type == .interval) || (params.type == .scale_degree)) {
                            VStack{
                                HStack{Text("Probability of large intervals (>octave)");Spacer()}
                                HStack{ParamSlider(value: $params.largeIntevalsProba, valueRange: 0.0...1.0);Text("\(params.largeIntevalsProba*100, specifier:"%0.f")")}
                            }
                        }

                    }
                    if (params.type == .interval) {
                        Section(header: Text("filters")) {
                            Picker("Preset", selection: $preset) {
                                ForEach(0..<preset_values.count, id: \.self) {
                                    Text(preset_values[$0])
                                }
                            }.onChange(of: preset) {
                                params.active_intervals = PRESET_MAPPING[preset_values[preset]]!
                            }
                            Grid{
                                GridRow {
                                    Text("")
                                    Image(systemName: "arrow.up.square").onTapGesture {
                                        toggle_active_intervals(intervals: [1, 3, 5, 7, 9, 11])
                                    }
                                    Image(systemName: "arrow.down.square").onTapGesture {
                                        toggle_active_intervals(intervals: [-1, -3, -5, -7, -9, -11])
                                    }
                                    Text(""); Text("")
                                    Image(systemName: "arrow.up.square").onTapGesture {
                                        toggle_active_intervals(intervals: [2, 4, 6, 8, 10, 12])
                                    }
                                    Image(systemName: "arrow.down.square").onTapGesture {
                                        toggle_active_intervals(intervals: [-2, -4, -6, -8, -10, -12])
                                    }
                                }
                                Divider()
                                ForEach(1..<7){ interval_int in
                                    GridRow{
                                        Text(interval_name(interval_int: 2*interval_int-1, oriented: false)).bold().gridColumnAlignment(.trailing).onTapGesture {
                                            toggle_active_intervals(intervals: [2*interval_int-1, -2*interval_int+1])
                                        }
                                        IntervalCheckBoxView(active: $params.active_intervals , interval_int: 2*interval_int-1)
                                        IntervalCheckBoxView(active: $params.active_intervals ,interval_int: -2*interval_int+1)
                                        Spacer()
                                        Text(interval_name(interval_int: 2*interval_int, oriented: false)).bold().gridColumnAlignment(.trailing).onTapGesture {
                                            toggle_active_intervals(intervals: [2*interval_int, -2*interval_int])
                                        }
                                        IntervalCheckBoxView(active: $params.active_intervals , interval_int: 2*interval_int)
                                        IntervalCheckBoxView(active: $params.active_intervals ,interval_int: -2*interval_int)
                                    }
                                    if (interval_int < 6) {Divider()}
                                }
                            }
                        }
                    }
                    if (params.type == .triad) {
                        Section(header: Text("Qualities")) {
                            Grid{
                                ForEach(TRIAD_KEYS, id: \.self) { key in
                                    GridRow{
                                        Text(key).gridColumnAlignment(.leading)
                                        ChordCheckBoxView(active: $params.active_qualities, key: key).gridColumnAlignment(.trailing)
                                    }
                                    if (TRIAD_KEYS.firstIndex(of: key) != TRIAD_KEYS.count-1 ) {Divider()}
                                }
                            }
                        }
                        Section(header: Text("Inversions")) {
                            Grid{
                                ForEach(TRIAD_INVERSION_KEYS, id: \.self) { key in
                                    GridRow{
                                        Text(key.split(separator: " ")[0]).gridColumnAlignment(.leading)
                                        ChordCheckBoxView(active: $params.active_inversions, key: key).gridColumnAlignment(.trailing)
                                    }
                                    if (TRIAD_INVERSION_KEYS.firstIndex(of: key) != TRIAD_INVERSION_KEYS.count-1 ) {Divider()}
                                }
                            }
                        }
                        Section(header: Text("Voicings")) {
                            Grid{
                                ForEach(TRIAD_VOICING_KEYS, id: \.self) { key in
                                    GridRow{
                                        Text(key).gridColumnAlignment(.leading)
                                        ChordCheckBoxView(active: $params.active_voicings, key: key).gridColumnAlignment(.trailing)
                                    }
                                    if (TRIAD_VOICING_KEYS.firstIndex(of: key) != TRIAD_VOICING_KEYS.count-1 ) {Divider()}
                                }
                            }
                        }
                    }
                    if (params.type == .scale_degree) {
                        Section(header: Text("Scale degrees")) {
                            Grid{
                                ForEach(0..<4){ degree_int in
                                    GridRow{
                                        Text(scale_degree_name(degree_int: 2*degree_int)).bold().gridColumnAlignment(.trailing)
                                        IntervalCheckBoxView(active: $params.active_scale_degrees, interval_int: 2*degree_int)
                                        Spacer()
                                        if (2*degree_int+1 < 7){
                                            Text(scale_degree_name(degree_int: 2*degree_int+1)).bold().gridColumnAlignment(.trailing)
                                            IntervalCheckBoxView(active: $params.active_scale_degrees , interval_int: 2*degree_int+1)
                                        }
                                    }
                                    if (degree_int < 3) {Divider()}
                                }
                            }
                        }
                    }
                    Section(header: Text("Misc")) {
                        HStack{
                            NoteStepperView(value: $params.lower_bound, caption: "Lowest note", other_bond: params.upper_bound)
                            Text(midi_note_to_name(note_int: params.lower_bound)).bold()
                            Spacer()
                            Image(systemName: "speaker.wave.2.fill").onTapGesture {
                                player.playNotes(notes: [params.lower_bound], duration: 1)
                            }
                        }
                        HStack{
                            NoteStepperView(value: $params.upper_bound, caption: "Highest note", other_bond: params.lower_bound)
                            Text(midi_note_to_name(note_int: params.upper_bound)).bold()
                            Spacer()
                            Image(systemName: "speaker.wave.2.fill").onTapGesture {
                                player.playNotes(notes: [params.upper_bound], duration: 1)
                            }
                        }
                        VStack{
                            HStack{Text("Sequence speed (seconds)");Spacer()}
                            HStack{ParamSlider(value: $params.delay_sequence, valueRange: 0.2...1.0);Text("\(params.delay_sequence, specifier:"%0.1f")")}
                        }
                    }
                }.navigationTitle("Parameters").navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    func toggle_active_intervals(intervals:[Int]){
        let inactive = intervals.filter({!params.active_intervals.contains($0)})
        let active   = intervals.filter({ params.active_intervals.contains($0)})
        for i in inactive {
                params.active_intervals.insert(i)
        }
        for i in active {
            if params.active_intervals.count > 1{
                params.active_intervals.remove(at: params.active_intervals.firstIndex(of: i)!)
            }
        }

    }
}
