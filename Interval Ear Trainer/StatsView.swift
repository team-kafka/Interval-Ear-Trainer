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
    //@AppStorage("hasData") var hasData = false
    @State private var selectedIndex: Int = 0

    
    var body: some View {
        TabView(selection: $selectedIndex) {
            StatsIntervalView().modelContainer(for: HistoricalData.self)
            .tabItem {
                Text("Intervals")
                Image(systemName: "arrow.up.and.down.square")
            }
            .tag(0)
            
            StatsTriadView()
            .tabItem {
                Label("Triads", systemImage: "music.quarternote.3")
            }
            .tag(1)
            
            StatsScaleDegreeView()
            .tabItem {
                Text("Scale Degrees")
                Image(systemName: "key")
            }
            .tag(2)
        }
        //1
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
    @Query() var historicalData: [HistoricalData]
    
    var body: some View {

        VStack{
            Text("Intervals").font(.title)

            GroupBox("Practice and listening") {
                Chart {
                    ForEach(historicalData.sorted(by: { compare_intervals(lhs: $0.id, rhs: $1.id) }), id: \.self) { d in
                        BarMark(x: .value("date", d.date, unit: .day),
                                y: .value("practice+listening", d.practice + d.listening)
                        )
                    }
                }
                Chart {
                    ForEach(historicalData.sorted(by: { compare_intervals(lhs: $0.id, rhs: $1.id) }), id: \.self) { d in
                        if d.id.hasPrefix("↑") {
                            BarMark(x: .value("id", d.id),
                                    y: .value("practice+listening", d.practice + d.listening)
                            )
                        }
                    }
                }
                Chart {
                    ForEach(historicalData.sorted(by: { compare_intervals(lhs: $0.id, rhs: $1.id) }), id: \.self) { d in
                        if d.id.hasPrefix("↓") {
                            BarMark(x: .value("id", d.id),
                                    y: .value("practice+listening", d.practice + d.listening)
                            )
                        }
                    }
                }
            }
            GroupBox("Quiz") {
                Chart {
                    ForEach(historicalData, id: \.self) { d in
                        BarMark(x: .value("Id", d.id),
                                y: .value("res", d.correct)
                        ).foregroundStyle(by: .value("correct", "correct"))
                    }
                    ForEach(historicalData, id: \.self) { d in
                        BarMark(x: .value("Id", d.id),
                                y: .value("res", d.incorrect)
                        ).foregroundStyle(by: .value("error", "error"))
                    }
                    ForEach(historicalData, id: \.self) { d in
                        BarMark(x: .value("Id", d.id),
                                y: .value("res", d.timeout)
                        ).foregroundStyle(by: .value("timeout", "timeout"))
                    }
                }
                .padding()
                .chartForegroundStyleScale([
                    "correct" : answer_colors[.correct]!,
                    "error": answer_colors[.incorrect]!,
                    "timeout": answer_colors[.timeout]!,
                ])
            }
            Spacer()
                HStack {
                    Button(role: .destructive) {
                        do {
                            try modelContext.delete(model: HistoricalData.self)
                        } catch {
                            fatalError(error.localizedDescription)
                        }
                    } label: {
                        Label("Delete Interval History", systemImage: "trash").opacity(0.7)
                    }.scaleEffect(0.8)
                    Spacer()
            }
            Spacer()
        }
    }
}

struct StatsTriadView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Query() var historicalData: [HistoricalData]
    
    var body: some View {
        VStack{
            Text("Triads").font(.title)
            GroupBox("Practice and listening") {
                Chart {
                    ForEach(historicalData, id: \.self) { d in
                        BarMark(x: .value("Id", d.id),
                                y: .value("practice+listening", d.practice + d.listening)).foregroundStyle(by: .value("practice+listening", "practice+listening"))
                    }
                }
                .padding()
                .chartForegroundStyleScale([
                    "practice+listening" : .gray,
                ])
            }
            GroupBox("Quiz") {
                Chart {
                    ForEach(historicalData, id: \.self) { d in
                        BarMark(x: .value("Id", d.id),
                                y: .value("res", d.correct)
                        ).foregroundStyle(by: .value("correct", "correct"))
                    }
                    ForEach(historicalData, id: \.self) { d in
                        BarMark(x: .value("Id", d.id),
                                y: .value("res", d.incorrect)
                        ).foregroundStyle(by: .value("error", "error"))
                    }
                    ForEach(historicalData, id: \.self) { d in
                        BarMark(x: .value("Id", d.id),
                                y: .value("res", d.timeout)
                        ).foregroundStyle(by: .value("timeout", "timeout"))
                    }
                }
                .padding()
                .chartForegroundStyleScale([
                    "correct" : .blue,
                    "error": .red,
                    "timeout": .red.opacity(0.5)
                ])
            }
            Spacer()
            HStack {
                Button(role: .destructive) {  } label: {
                    Label("Reset Triad History", systemImage: "trash").opacity(0.7)
                }.scaleEffect(0.8)
                Spacer()
            }
            Spacer()
        }
    }
}


struct StatsScaleDegreeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query() var historicalData: [HistoricalData]
    
    var body: some View {
        
        VStack{
            Text("Scale Degrees").font(.title)
            GroupBox("Practice and listening") {
                Chart {
                    ForEach(historicalData, id: \.self) { d in
                        BarMark(x: .value("Id", d.id),
                                y: .value("practice+listening", d.practice + d.listening)).foregroundStyle(by: .value("practice+listening", "practice+listening"))
                    }
                }
                .chartForegroundStyleScale([
                    "practice+listening" : .gray,
                ])
            }
            GroupBox("Quiz") {
                Chart {
                    ForEach(historicalData, id: \.self) { d in
                        BarMark(x: .value("Id", d.id),
                                y: .value("res", d.correct)
                        ).foregroundStyle(by: .value("correct", "correct"))
                    }
                    ForEach(historicalData, id: \.self) { d in
                        BarMark(x: .value("Id", d.id),
                                y: .value("res", d.incorrect)
                        ).foregroundStyle(by: .value("error", "error"))
                    }
                    ForEach(historicalData, id: \.self) { d in
                        BarMark(x: .value("Id", d.id),
                                y: .value("res", d.timeout)
                        ).foregroundStyle(by: .value("timeout", "timeout"))
                    }
                }
                .padding()
                .chartForegroundStyleScale([
                    "correct" : .blue,
                    "error": .red,
                    "timeout": .red.opacity(0.5)
                ])
            }
            Spacer()
            HStack {
                Button(role: .destructive) {  } label: {
                    Label("Reset Scale Degree History", systemImage: "trash").opacity(0.7)
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
