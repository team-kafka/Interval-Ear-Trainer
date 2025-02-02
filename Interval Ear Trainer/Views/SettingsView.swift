//
//  StatParamsView.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2025/01/19.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query() private var data: [HistoricalData]
    
    @State private var showingConfirmation = false
    @Binding var saveUsageData: Bool
    @Binding var showHelp: Bool
    
    init(saveUsageData: Binding<Bool>, showHelp: Binding<Bool>) {
        _saveUsageData = .init(projectedValue: saveUsageData)
        _showHelp = .init(projectedValue: showHelp)
    }
    
    var body: some View {
        VStack{
            NavigationStack{
                List{
                    Section(header: Text("Stored Data")) {
                        Toggle("Store Usage Statistics", isOn: $saveUsageData)
                            HStack{
                            Text("Data Size")
                            Spacer()
                            Text("\(Double(data.count * class_getInstanceSize(HistoricalData.self)) / 1024.0, specifier: "%.1f") Kb")}
                        Button("Delete Stored Data", systemImage: "trash", role: .destructive){
                            showingConfirmation = true
                        }.foregroundStyle(.red)
                            .confirmationDialog("Are you sure?", isPresented: $showingConfirmation) {
                                Button("Delete data", role: .destructive) {
                                    do {
                                        try modelContext.delete(model: HistoricalData.self)
                                        try modelContext.save()
                                    } catch {
                                        print("Failed to delete data")
                                    }
                                }
                                Button("Cancel", role: .cancel) {}
                            }
                        }
                    Section(header: Text("Help")) {
                        Toggle("Show Help", isOn: $showHelp)
                    }
                    Section(header: Text("Info")) {
                        HStack{
                            Text("App Version:")
                            Spacer()
                            Text(appVersion!)
                        }
                        HStack{
                            Text("Feedback:")
                            Spacer()
                            Text("dev@team_kafka.com")
                        }
                    }
                }.navigationTitle("Settings").navigationBarTitleDisplayMode(.inline)
            }
        }
        .tint(.green)
        .toolbarRole(.editor)
    }
}

