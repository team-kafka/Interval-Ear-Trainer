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
    @Binding var useTestData: Bool
    
    var body: some View {
        NavigationStack{
            List{
                Section(header: Text("Data Size")) {
                    Text("\(intervalData.count) entries")
                    Text("\(triadData.count) entries")
                    Text("\(scaleDegreeData.count) entries")
                }
                Section(header: Text("Deleting Data")) {
                    Button("Delete Interval History", systemImage: "trash", role: .destructive){
                        showingConfirmation = true
                    }.foregroundStyle(.red)
                    .confirmationDialog("Are you sure?", isPresented: $showingConfirmation) {
                        Button("Yes", role: .destructive) {
                            for hd in intervalData {
                                modelContext.delete(hd)
                            }
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
                        }
                        Button("No", role: .cancel) {}
                    }
                }
                Section(header: Text("Devs' corner")) {
                    Toggle(isOn: $useTestData) {
                            Text("Use sample data for testing")
                        }
                }
            }.navigationTitle("Historical Data Parameters").navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    struct Preview: View {
        @State var useTestData: Bool = false
        var body: some View {
            StatParamsView(useTestData: $useTestData).modelContainer(for: HistoricalData.self)
        }
    }
    return Preview()
}
