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
    @State var useTestData: Bool = false

    var body: some View {
        TabView(selection: $selectedIndex) {
            StatsIntervalView(useTestData: $useTestData).modelContainer(for: HistoricalData.self)
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
            StatParamsView(useTestData: $useTestData).modelContainer(for: HistoricalData.self)
            .tabItem {
                Text("Params")
                Image(systemName: "gearshape.fill")
            }
            .tag(3)
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
    
    @Binding var useTestData: Bool
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<HistoricalData> {$0.type == "interval"})  var historicalData: [HistoricalData]
    @Query(filter: #Predicate<HistoricalData> {$0.id.contains("↑") && $0.type == "interval"}) var ascData: [HistoricalData]
    @Query(filter: #Predicate<HistoricalData> {$0.id.contains("↓") && $0.type == "interval"}) var descData: [HistoricalData]

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
                    let all_data = useTestData ? historicalData + HistoricalData.self.samples_int_asc + HistoricalData.self.samples_int_desc : historicalData
                    ForEach(all_data, id: \.self) { d in
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
                    let all_data = useTestData ? ascData + HistoricalData.self.samples_int_asc : ascData
                    ForEach(all_data, id: \.self) { d in
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
                    let all_data = useTestData ? descData + HistoricalData.self.samples_int_desc : descData
                    ForEach(all_data, id: \.self) { d in
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
                    let all_data = useTestData ? ascData + HistoricalData.self.samples_int_asc : ascData
                    ForEach(all_data, id: \.self) { d in
                            BarMark(x: .value("Id", d.id),
                                    y: .value("res", d.correct)
                            ).foregroundStyle(by: .value("correct", "correct"))
                    }
                    ForEach(all_data, id: \.self) { d in
                            BarMark(x: .value("Id", d.id),
                                    y: .value("res", d.timeout)
                            ).foregroundStyle(by: .value("timeout", "timeout"))
                    }
                    ForEach(all_data, id: \.self) { d in
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
                    let all_data = useTestData ? descData + HistoricalData.self.samples_int_desc : descData
                    ForEach(all_data, id: \.self) { d in
                        BarMark(x: .value("Id", d.id),
                                y: .value("res", d.correct)
                        ).foregroundStyle(by: .value("correct", "correct"))
                    }
                    ForEach(all_data, id: \.self) { d in
                        BarMark(x: .value("Id", d.id),
                                y: .value("res", d.timeout)
                        ).foregroundStyle(by: .value("timeout", "timeout"))
                    }
                    ForEach(all_data, id: \.self) { d in
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

            Spacer()
        }
    }
}

struct StatsTriadView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<HistoricalData> {$0.type == "triad"})  var historicalData: [HistoricalData]

    @State var selectedIndex: String?

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
//                    ForEach(TRIAD_KEYS, id: \.self) { k in
//                        BarMark(x: .value("Id", short_answer(answer:k)),
//                                y: .value("res",0))
//                    }
                    ForEach(historicalData, id: \.self) { d in
                        let isSelected = selectedIndex != nil && d.id == selectedIndex!
                        BarMark(x: .value("Id", d.id),
                                y: .value("res", d.correct)
                        ).foregroundStyle(isSelected ? .yellow : answer_colors[.correct]!)//by: .value("correct", "correct"))
                    }
                    ForEach(historicalData, id: \.self) { d in
                        let isSelected = selectedIndex != nil && d.id == selectedIndex!
                        BarMark(x: .value("Id", d.id),
                                y: .value("res", d.timeout)
                        ).foregroundStyle(isSelected ? .yellow : answer_colors[.timeout]!)
                    }
                    ForEach(historicalData, id: \.self) { d in
                        let isSelected = selectedIndex != nil && d.id == selectedIndex!
                        BarMark(x: .value("Id", d.id),
                                y: .value("res", d.incorrect)
                        ).foregroundStyle(isSelected ? .yellow : answer_colors[.incorrect]!)
                    }
                }.chartXSelection(value: $selectedIndex)
                .chartForegroundStyleScale([
                    "correct" : answer_colors[.correct]!,
                    "timeout": answer_colors[.timeout]!,
                    "error": answer_colors[.incorrect]!,
                ])//.chartLegend(.hidden)//.chartXSelection(value: $selectedIndex)
            }
            Spacer()
        }
    }
}

struct StatsScaleDegreeView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<HistoricalData> {$0.type == "scale_degree"})  var historicalData: [HistoricalData]

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
        }
    }
}

#Preview {
    StatView()
}
