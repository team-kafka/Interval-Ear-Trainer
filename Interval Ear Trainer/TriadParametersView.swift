//
//  TriadParametersView.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2024/12/25.
//

import SwiftUI

struct TriadParametersView: View {
    @Binding var params : TriadParameters
    
    
    let player = MidiPlayer()
    
    var body: some View {
        NavigationView{
            VStack{
                List{
                    Section(header: Text("general")) {
                        VStack{
                            HStack{Text("Delay (seconds)");Spacer()}
                            HStack{ParamSlider(value: $params.delay, valueRange: 0.2...5.0);Text("\(params.delay, specifier:"%0.1f")")}
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
                        Grid{
                            
                        }
                    }
                }.navigationTitle("Parameters").navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    func toggle_active_intervals(intervals:[Int]){
        
    }
}


