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
    @Query() private var data: [HistoricalData]
    
    @State private var showingConfirmation = false
    @Binding var saveUsageData: Bool

    
    var body: some View {
        VStack{
        Text("Statistics - Settings") // until the bug with nav stack inside tabs is fixed
            NavigationStack{
                List{
                    Toggle("Store Usage Statistics", isOn: $saveUsageData)
                    Section(header: Text("Stored Data")) {
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
                }
            }
        }
    }
}

