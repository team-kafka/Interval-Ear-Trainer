//
//  StatsView.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2025/01/12.
//

import SwiftUI
import TabularData
import Charts
import SwiftData

struct StatView: View {
    @State private var selectedIndex: Int = 0

    
    var body: some View {
        TabView(selection: $selectedIndex) {
            StatsIntervalView().modelContainer(for: HistoricalData.self)
            .tabItem {
                Text("Intervals")
                Image(systemName: "arrow.up.and.down.square")
            }
            .tag(0)
            
            StatsTriadView().modelContainer(for: HistoricalData.self)
            .tabItem {
                Label("Triads", systemImage: "music.quarternote.3")
            }
            .tag(1)
            
            StatsScaleDegreeView().modelContainer(for: HistoricalData.self)
            .tabItem {
                Text("Scale Degrees")
                Image(systemName: "key")
            }
            .tag(2)
        }
        .tint(Color.gray.opacity(0.7))
        .onAppear(perform: {
            UITabBar.appearance().unselectedItemTintColor = .systemGray
            UITabBarItem.appearance().badgeColor = .systemGray
            UITabBar.appearance().backgroundColor = .systemGray4.withAlphaComponent(0.4)
            UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.systemGray]
        })
    }
}

struct StatsIntervalView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<HistoricalData> {$0.type == "interval"})  var historicalData: [HistoricalData]
    @Query(filter: #Predicate<HistoricalData> {$0.id.contains("↑") && $0.type == "interval"}) var ascData: [HistoricalData]
    @Query(filter: #Predicate<HistoricalData> {$0.id.contains("↓") && $0.type == "interval"}) var descData: [HistoricalData]

    @State private var showingConfirmation = false
    
    var body: some View {

        VStack{
            Text("Intervals").font(.title)

            GroupBox("Practice and listening") {
                Chart {
                    BarMark(x: .value("date", Date(), unit: .day),
                            y: .value("practice+listening", 0)
                    )
                    BarMark(x: .value("date", Date().addingTimeInterval(TimeInterval(-86400*7)), unit: .day),
                            y: .value("practice+listening", 0)
                    )
                    ForEach(historicalData, id: \.self) { d in
                        BarMark(x: .value("date", d.date, unit: .day),
                                y: .value("practice+listening", d.practice + d.listening)
                        )
                    }
                }
                Chart {
                    ForEach(INTERVAL_KEYS, id: \.self) { k in
                            BarMark(x: .value("Id", "↑" + k ),
                                    y: .value("res",0))
                    }
                    ForEach(ascData, id: \.self) { d in
                            BarMark(x: .value("id", d.id),
                                    y: .value("practice+listening", d.practice + d.listening)
                            )
                        }
                }
                Chart {
                    ForEach(INTERVAL_KEYS, id: \.self) { k in
                            BarMark(x: .value("Id", "↓" + k ),
                                    y: .value("res",0))
                    }
                    ForEach(descData, id: \.self) { d in
                            BarMark(x: .value("id", d.id),
                                    y: .value("practice+listening", d.practice + d.listening)
                            )
                        }
                }
            }
            GroupBox("Quiz") {
                Chart {
                    ForEach(INTERVAL_KEYS, id: \.self) { k in
                            BarMark(x: .value("Id", "↑" + k ),
                                    y: .value("res",0))
                    }
                    ForEach(ascData, id: \.self) { d in
                            BarMark(x: .value("Id", d.id),
                                    y: .value("res", d.correct)
                            ).foregroundStyle(by: .value("correct", "correct"))
                    }
                    ForEach(ascData, id: \.self) { d in
                            BarMark(x: .value("Id", d.id),
                                    y: .value("res", d.timeout)
                            ).foregroundStyle(by: .value("timeout", "timeout"))
                    }
                    ForEach(ascData, id: \.self) { d in
                            BarMark(x: .value("Id", d.id),
                                    y: .value("res", d.incorrect)
                            ).foregroundStyle(by: .value("error", "error"))
                    }
                }
                .chartForegroundStyleScale([
                    "correct" : answer_colors[.correct]!,
                    "timeout": answer_colors[.timeout]!,
                    "error": answer_colors[.incorrect]!,
                ]).chartLegend(.hidden)
                Chart {
                    ForEach(INTERVAL_KEYS, id: \.self) { k in
                            BarMark(x: .value("Id", "↓" + k ),
                                    y: .value("res",0))
                    }
                    ForEach(descData, id: \.self) { d in
                        BarMark(x: .value("Id", d.id),
                                y: .value("res", d.correct)
                        ).foregroundStyle(by: .value("correct", "correct"))
                    }
                    ForEach(descData, id: \.self) { d in
                        BarMark(x: .value("Id", d.id),
                                y: .value("res", d.timeout)
                        ).foregroundStyle(by: .value("timeout", "timeout"))
                    }
                    ForEach(descData, id: \.self) { d in
                        BarMark(x: .value("Id", d.id),
                                y: .value("res", d.incorrect)
                        ).foregroundStyle(by: .value("error", "error"))
                    }
                }
                .chartForegroundStyleScale([
                    "correct" : answer_colors[.correct]!,
                    "timeout": answer_colors[.timeout]!,
                    "error": answer_colors[.incorrect]!,
                ])
            }
            Spacer()
            HStack {
                Button("Delete Interval History", systemImage: "trash", role: .destructive){
                    showingConfirmation = true
                }
                .confirmationDialog("Are you sure?", isPresented: $showingConfirmation) {
                    Button("Yes", role: .destructive) {
                        for hd in historicalData {
                            modelContext.delete(hd)
                        }
                    }
                    Button("No", role: .cancel) {}
                }.scaleEffect(0.8)
                Spacer()
            }
            Spacer()
        }
    }
}

struct StatsTriadView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<HistoricalData> {$0.type == "triad"})  var historicalData: [HistoricalData]

    @State private var showingConfirmation = false
    
    var body: some View {

        VStack{
            Text("Triads").font(.title)

            GroupBox("Practice and listening") {
                Chart {
                    BarMark(x: .value("date", Date(), unit: .day),
                            y: .value("practice+listening", 0)
                    )
                    BarMark(x: .value("date", Date().addingTimeInterval(TimeInterval(-86400*7)), unit: .day),
                            y: .value("practice+listening", 0)
                    )
                    ForEach(historicalData, id: \.self) { d in
                        BarMark(x: .value("date", d.date, unit: .day),
                                y: .value("practice+listening", d.practice + d.listening)
                        )
                    }
                }
                Chart {
                    ForEach(TRIAD_KEYS, id: \.self) { k in
                        BarMark(x: .value("Id",  short_answer(answer:k)),
                                    y: .value("res",0))
                    }
                    ForEach(historicalData, id: \.self) { d in
                            BarMark(x: .value("id", d.id),
                                    y: .value("practice+listening", d.practice + d.listening)
                            )
                        }
                }
            }
            GroupBox("Quiz") {
                Chart {
                    ForEach(TRIAD_KEYS, id: \.self) { k in
                        BarMark(x: .value("Id", short_answer(answer:k)),
                                y: .value("res",0))
                    }
                    ForEach(historicalData, id: \.self) { d in
                        BarMark(x: .value("Id", d.id),
                                y: .value("res", d.correct)
                        ).foregroundStyle(by: .value("correct", "correct"))
                    }
                    ForEach(historicalData, id: \.self) { d in
                        BarMark(x: .value("Id", d.id),
                                y: .value("res", d.timeout)
                        ).foregroundStyle(by: .value("timeout", "timeout"))
                    }
                    ForEach(historicalData, id: \.self) { d in
                        BarMark(x: .value("Id", d.id),
                                y: .value("res", d.incorrect)
                        ).foregroundStyle(by: .value("error", "error"))
                    }
                }
                .chartForegroundStyleScale([
                    "correct" : answer_colors[.correct]!,
                    "timeout": answer_colors[.timeout]!,
                    "error": answer_colors[.incorrect]!,
                ]).chartLegend(.hidden)
            }
            Spacer()
            HStack {
                Button("Delete Triad History", systemImage: "trash", role: .destructive){
                    showingConfirmation = true
                }
                .confirmationDialog("Are you sure?", isPresented: $showingConfirmation) {
                    Button("Yes", role: .destructive) {
                        for hd in historicalData {
                            modelContext.delete(hd)
                        }
                    }
                    Button("No", role: .cancel) {}
                }.scaleEffect(0.8)
                Spacer()
            }
            Spacer()
        }
    }
}

struct StatsScaleDegreeView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<HistoricalData> {$0.type == "scale_degree"})  var historicalData: [HistoricalData]

    @State private var showingConfirmation = false
    
    var body: some View {

        VStack{
            Text("Scale Degrees").font(.title)

            GroupBox("Practice and listening") {
                Chart {
                    BarMark(x: .value("date", Date(), unit: .day),
                            y: .value("practice+listening", 0)
                    )
                    BarMark(x: .value("date", Date().addingTimeInterval(TimeInterval(-86400*7)), unit: .day),
                            y: .value("practice+listening", 0)
                    )
                    ForEach(historicalData, id: \.self) { d in
                        BarMark(x: .value("date", d.date, unit: .day),
                                y: .value("practice+listening", d.practice + d.listening)
                        )
                    }
                }
                Chart {
                    ForEach(SCALE_DEGREE_KEYS_W_ALT, id: \.self) { k in
                        BarMark(x: .value("Id", k),
                                    y: .value("res",0))
                    }
                    ForEach(historicalData, id: \.self) { d in
                            BarMark(x: .value("id", d.id),
                                    y: .value("practice+listening", d.practice + d.listening)
                            )
                        }
                }
            }
            GroupBox("Quiz") {
                Chart {
                    ForEach(SCALE_DEGREE_KEYS_W_ALT, id: \.self) { k in
                        BarMark(x: .value("Id", k),
                                y: .value("res",0))
                    }
                    ForEach(historicalData, id: \.self) { d in
                        BarMark(x: .value("Id", d.id),
                                y: .value("res", d.correct)
                        ).foregroundStyle(by: .value("correct", "correct"))
                    }
                    ForEach(historicalData, id: \.self) { d in
                        BarMark(x: .value("Id", d.id),
                                y: .value("res", d.timeout)
                        ).foregroundStyle(by: .value("timeout", "timeout"))
                    }
                    ForEach(historicalData, id: \.self) { d in
                        BarMark(x: .value("Id", d.id),
                                y: .value("res", d.incorrect)
                        ).foregroundStyle(by: .value("error", "error"))
                    }
                }
                .chartForegroundStyleScale([
                    "correct" : answer_colors[.correct]!,
                    "timeout": answer_colors[.timeout]!,
                    "error": answer_colors[.incorrect]!,
                ]).chartLegend(.hidden)
            }
            Spacer()
            HStack {
                Button("Delete Scale Degree History", systemImage: "trash", role: .destructive){
                    showingConfirmation = true
                }
                .confirmationDialog("Are you sure?", isPresented: $showingConfirmation) {
                    Button("Yes", role: .destructive) {
                        for hd in historicalData {
                            modelContext.delete(hd)
                        }
                    }
                    Button("No", role: .cancel) {}
                }.scaleEffect(0.8)
                Spacer()
            }
            Spacer()
        }
    }
}

#Preview {
    StatView()
}
