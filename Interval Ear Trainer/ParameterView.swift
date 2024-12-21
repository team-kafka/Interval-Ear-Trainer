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
    "": Parameters.init_value.active_intervals
              ]

struct ParameterView: View {
    @Binding var params : Parameters
    @State private var preset = 0
    let player = MidiPlayer()
    
    let preset_values = ["", "3rds", "Large Intervals", "4ths and 5ths"]
    
    var body: some View {
        NavigationView{
            VStack{
                List{
                    Section(header: Text("general")) {
                        VStack{
                            HStack{Text("Delay (seconds)");Spacer()}
                            HStack{ParamSlider(value: $params.delay, valueRange: 0.2...5.0);Text("\(params.delay, specifier:"%0.1f")")}
                        }
                        VStack{
                            HStack{Text("Probability of large intervals (>octave)");Spacer()}
                            HStack{ParamSlider(value: $params.largeIntevalsProba, valueRange: 0.0...1.0);Text("\(params.largeIntevalsProba*100, specifier:"%0.f")")}
                        }
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
                    }
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
                }.navigationTitle("Parameters").navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    func toggle_active_intervals(intervals:[Int]){
        for i in intervals{
            if (params.active_intervals.contains(i))
            {
                params.active_intervals.remove(at: params.active_intervals.firstIndex(of: i)!)
            } else
            {
                params.active_intervals.insert(i)
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
                    active.remove(at: active.firstIndex(of: interval_int)!)
                } else
                {
                    active.insert(interval_int)
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


#Preview {
    @State @Previewable var params = Parameters.init_value
    ParameterView(params: $params)
}


        
