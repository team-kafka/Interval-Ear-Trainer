//
//  StatParamsView.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2025/01/19.
//

import SwiftUI
import SwiftData

let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

struct SettingsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query() private var data: [HistoricalData]
    
    @State private var showingConfirmation = false
    @Binding var saveUsageData: Bool
    
    init(saveUsageData: Binding<Bool>) {
        _saveUsageData = .init(projectedValue: saveUsageData)
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
                    Section(header: Text("Info")) {
                        HStack{
                            Text("App Version:")
                            Spacer()
                            Text(appVersion!)
                        }
                    }
                }.navigationTitle("Settings").navigationBarTitleDisplayMode(.inline)
            }
        }
        .tint(.gray)
        .toolbarRole(.editor)
    }
}

