//
//  StatParamsView.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2025/01/19.
//

import SwiftUI
import SwiftData

struct StatParamsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<HistoricalData> {$0.type == "interval"})  var intervalData: [HistoricalData]
    @Query(filter: #Predicate<HistoricalData> {$0.type == "triad"})  var triadData: [HistoricalData]
    @Query(filter: #Predicate<HistoricalData> {$0.type == "scale_degree"})  var scaleDegreeData: [HistoricalData]
    @State private var showingConfirmation = false

    var body: some View {
        VStack{
        Text("Historical Data") // until the bug with nav stack inside tabs is fixed
            NavigationStack{
                List{
                    Section(header: Text("Data Size")) {
                        HStack{
                            Text("Intervals")
                            Spacer()
                            Text("\(Double(intervalData.count * class_getInstanceSize(HistoricalData.self)) / 1024.0, specifier: "%.1f") Kb")}
                        HStack{
                            Text("Triads")
                            Spacer()
                            Text("\(Double(triadData.count * class_getInstanceSize(HistoricalData.self)) / 1024.0, specifier: "%.1f") Kb")}
                        HStack{
                            Text("Scale Degrees")
                            Spacer()
                            Text("\(Double(scaleDegreeData.count * class_getInstanceSize(HistoricalData.self)) / 1024.0, specifier: "%.1f") Kb")}
                    }
                    //.navigationTitle("Historical Data Parameters").navigationBarTitleDisplayMode(.inline)
                    Section(header: Text("Deleting Data")) {
                        Button("Delete Interval History", systemImage: "trash", role: .destructive){
                            showingConfirmation = true
                        }.foregroundStyle(.red)
                            .confirmationDialog("Are you sure?", isPresented: $showingConfirmation) {
                                Button("Yes", role: .destructive) {
                                    for hd in intervalData {
                                        modelContext.delete(hd)
                                    }
                                    try! modelContext.save()
                                }
                                Button("No", role: .cancel) {}
                            }
                        
                        Button("Delete Triad History", systemImage: "trash", role: .destructive){
                            showingConfirmation = true
                        }.foregroundStyle(.red)
                            .confirmationDialog("Are you sure?", isPresented: $showingConfirmation) {
                                Button("Yes", role: .destructive) {
                                    for hd in triadData {
                                        modelContext.delete(hd)
                                    }
                                    try! modelContext.save()
                                }
                                Button("No", role: .cancel) {}
                            }
                        
                        Button("Delete Scale Degree History", systemImage: "trash", role: .destructive){
                            showingConfirmation = true
                        }.foregroundStyle(.red)
                            .confirmationDialog("Are you sure?", isPresented: $showingConfirmation) {
                                Button("Yes", role: .destructive) {
                                    for hd in scaleDegreeData {
                                        modelContext.delete(hd)
                                    }
                                    try! modelContext.save()
                                }
                                Button("No", role: .cancel) {}
                            }
                    }
//                    Section(header: Text("Devs' corner")) {
//                        Toggle(isOn: $useTestData) {
//                            Text("Use sample data for testing")
//                        }
//                    }
                }
            }
        }
    }
}

#Preview {
    StatParamsView().modelContainer(for: HistoricalData.self)
}
