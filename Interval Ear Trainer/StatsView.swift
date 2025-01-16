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
            StatsIntervalView().modelContainer(for: IntervalData.self)
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
    @Query() var intervalData: [IntervalData]
    
    var body: some View {

        VStack{
            Text("Intervals").font(.title)

            GroupBox("Practice and listening") {
                Chart {
                    ForEach(intervalData.sorted(by: { compare_intervals(lhs: $0.interval, rhs: $1.interval) }), id: \.self) { d in
                        BarMark(x: .value("date", d.date, unit: .day),
                                y: .value("practice+listening", d.practice + d.listening)
                        )
                    }
                }//.padding()
                Chart {
                    ForEach(intervalData.sorted(by: { compare_intervals(lhs: $0.interval, rhs: $1.interval) }), id: \.self) { d in
                        if d.interval.hasPrefix("↑") {
                            BarMark(x: .value("id", d.interval),
                                    y: .value("practice+listening", d.practice + d.listening)
                            )
                        }
                    }
                }//.padding()
                Chart {
                    ForEach(intervalData.sorted(by: { compare_intervals(lhs: $0.interval, rhs: $1.interval) }), id: \.self) { d in
                        if d.interval.hasPrefix("↓") {
                            BarMark(x: .value("id", d.interval),
                                    y: .value("practice+listening", d.practice + d.listening)
                            )
                        }
                    }
                }//.padding()
            }
            GroupBox("Quiz") {
                Chart {
                    ForEach(intervalData, id: \.self) { d in
                        BarMark(x: .value("Id", d.interval),
                                y: .value("res", d.correct)
                        ).foregroundStyle(by: .value("correct", "correct"))
                    }
                    ForEach(intervalData, id: \.self) { d in
                        BarMark(x: .value("Id", d.interval),
                                y: .value("res", d.incorrect)
                        ).foregroundStyle(by: .value("error", "error"))
                    }
                    ForEach(intervalData, id: \.self) { d in
                        BarMark(x: .value("Id", d.interval),
                                y: .value("res", d.timeout)
                        ).foregroundStyle(by: .value("timeout", "timeout"))
                    }
                }
                .padding()
                .chartForegroundStyleScale([
                    "correct" : .blue,
                    "error": .red,
                    "timeout": .red.opacity(0.7)
                ])
            }
            Spacer()
                HStack {
                    Button(role: .destructive) {
                        do {
                            try modelContext.delete(model: IntervalData.self)
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
    
    var body: some View {
        let data2 = sampleDF(ids:TRIAD_KEYS)
        VStack{
            Text("Triads").font(.title)
            GroupBox("Practice and listening") {
                Chart {
                    ForEach(data2.rows, id: \.index) { d in
                        BarMark(x: .value("Id", d["date", Date.self]!),
                                y: .value("practice+listening", d["practice", Int.self]! + d["listening", Int.self]!)).foregroundStyle(by: .value("practice+listening", "practice+listening"))
                    }
                }
                //.frame(height: 300)
                .padding()
                .chartForegroundStyleScale([
                    "practice+listening" : .gray,
                ])
            }
            GroupBox("Quiz") {
                Chart {
                    ForEach(data2.rows, id: \.index) { d in
                        BarMark(x: .value("Id", d["id", String.self]!),
                                y: .value("res", d["quiz_correct", Int.self]!)
                        ).foregroundStyle(by: .value("correct", "correct"))
                    }
                    ForEach(data2.rows, id: \.index) { d in
                        BarMark(x: .value("Id", d["id", String.self]!),
                                y: .value("res", d["quiz_error", Int.self]!)
                        ).foregroundStyle(by: .value("error", "error"))
                    }
                    ForEach(data2.rows, id: \.index) { d in
                        BarMark(x: .value("Id", d["id", String.self]!),
                                y: .value("res", d["quiz_timeout", Int.self]!)
                        ).foregroundStyle(by: .value("timeout", "timeout"))
                    }
                }
                //.frame(height: 300)
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

    var body: some View {
        let data2 = sampleDF(ids:SCALE_KEYS)
        
        VStack{
            Text("Scale Degrees").font(.title)
            GroupBox("Practice and listening") {
                Chart {
                    ForEach(data2.rows, id: \.index) { d in
                        BarMark(x: .value("Id", d["date", Date.self]!),
                                y: .value("practice+listening", d["practice", Int.self]! + d["listening", Int.self]!)).foregroundStyle(by: .value("practice+listening", "practice+listening"))
                    }
                }
                //.frame(height: 300)
                .padding()
                .chartForegroundStyleScale([
                    "practice+listening" : .gray,
                ])
            }
            GroupBox("Quiz") {
                Chart {
                    ForEach(data2.rows, id: \.index) { d in
                        BarMark(x: .value("Id", d["id", String.self]!),
                                y: .value("res", d["quiz_correct", Int.self]!)
                        ).foregroundStyle(by: .value("correct", "correct"))
                    }
                    ForEach(data2.rows, id: \.index) { d in
                        BarMark(x: .value("Id", d["id", String.self]!),
                                y: .value("res", d["quiz_error", Int.self]!)
                        ).foregroundStyle(by: .value("error", "error"))
                    }
                    ForEach(data2.rows, id: \.index) { d in
                        BarMark(x: .value("Id", d["id", String.self]!),
                                y: .value("res", d["quiz_timeout", Int.self]!)
                        ).foregroundStyle(by: .value("timeout", "timeout"))
                    }
                }
                //.frame(height: 300)
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
