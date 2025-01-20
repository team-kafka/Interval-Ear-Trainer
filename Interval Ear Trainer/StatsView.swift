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
            StatsTriadView(useTestData: $useTestData).modelContainer(for: HistoricalData.self)
            .tabItem {
                Label("Triads", systemImage: "music.quarternote.3")
            }
            .tag(1)
            StatsScaleDegreeView(useTestData: $useTestData).modelContainer(for: HistoricalData.self)
            .tabItem {
                Text("Scale Degrees")
                Image(systemName: "key")
            }
            .tag(2)
            StatParamsView(useTestData: $useTestData).modelContainer(for: HistoricalData.self)
            .tabItem {
                Text("Settings")
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
    
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<HistoricalData> {$0.type == "interval"})  var historicalData: [HistoricalData]
    @Query(filter: #Predicate<HistoricalData> {$0.id.contains("↑") && $0.type == "interval"}) var ascData: [HistoricalData]
    @Query(filter: #Predicate<HistoricalData> {$0.id.contains("↓") && $0.type == "interval"}) var descData: [HistoricalData]

    @Binding var useTestData: Bool

    var body: some View {

        VStack{
            Text("Intervals").font(.title)
            if useTestData{
                PracticeChart(histData: historicalData + HistoricalData.self.samples_int_desc + HistoricalData.self.samples_int_asc,
                              detailledData: [ascData  + HistoricalData.self.samples_int_asc , descData + HistoricalData.self.samples_int_desc],
                              allKeys:[INTERVAL_KEYS.map{"↑" + $0}, INTERVAL_KEYS.map{"↓" + $0}])
                QuizzChart(allData: [ascData  + HistoricalData.self.samples_int_asc, descData + HistoricalData.self.samples_int_desc],
                           allKeys:[INTERVAL_KEYS.map{"↑" + $0}, INTERVAL_KEYS.map{"↓" + $0}])
            }else{
                PracticeChart(histData: historicalData ,
                              detailledData: [ascData, descData],
                              allKeys:[INTERVAL_KEYS.map{"↑" + $0}, INTERVAL_KEYS.map{"↓" + $0}])
                QuizzChart(allData: [ascData, descData],
                           allKeys:[INTERVAL_KEYS.map{"↑" + $0}, INTERVAL_KEYS.map{"↓" + $0}])
            }
            Spacer()
        }
    }
}

struct StatsTriadView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<HistoricalData> {$0.type == "triad"})  var historicalData: [HistoricalData]

    @State var selectedIndex: String?
    @Binding var useTestData: Bool

    var body: some View {
        VStack{
            Text("Triads").font(.title)
            if useTestData {
                PracticeChart(histData:historicalData + HistoricalData.self.samples_triad,
                              detailledData: [historicalData + HistoricalData.self.samples_triad],
                              allKeys:[TRIAD_KEYS])
                QuizzChart(allData: [historicalData + HistoricalData.self.samples_triad], allKeys: [TRIAD_KEYS])
            } else {
                PracticeChart(histData:historicalData,
                              detailledData: [historicalData],
                              allKeys:[TRIAD_KEYS])
                QuizzChart(allData: [historicalData], allKeys: [TRIAD_KEYS])

            }
            Spacer()
        }
    }
}

struct StatsScaleDegreeView: View {
        
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<HistoricalData> {$0.type == "scale_degree"})  var historicalData: [HistoricalData]
    
    @Binding var useTestData: Bool

    var body: some View {

        VStack{
            Text("Scale Degrees").font(.title)
            if useTestData {
                PracticeChart(histData:historicalData + HistoricalData.self.samples_scale_degree,
                              detailledData: [historicalData + HistoricalData.self.samples_scale_degree],
                              allKeys:[SCALE_DEGREE_KEYS_W_ALT])
                QuizzChart(allData: [historicalData + HistoricalData.self.samples_scale_degree], allKeys: [SCALE_DEGREE_KEYS_W_ALT])
            } else {
                PracticeChart(histData:historicalData,
                              detailledData: [historicalData],
                              allKeys:[SCALE_DEGREE_KEYS_W_ALT])
                QuizzChart(allData: [historicalData], allKeys: [SCALE_DEGREE_KEYS_W_ALT])

            }
            Spacer()
        }
    }
}

struct QuizzChart: View {
   
    @State var allData: [[HistoricalData]]
    @State var allKeys: [[String]]
    
    @State var selectedIndex: String?

    var body: some View {
        GroupBox("Quiz") {
            ForEach(Array(zip(allData, allKeys)), id: \.0){ data, keys in
                Chart {
                    ForEach(keys, id: \.self) { k in
                        BarMark(x: .value("Id", short_answer(answer:k)),
                                y: .value("res",0))
                    }
                    ForEach(data, id: \.self) { d in
                        BarMark(x: .value("Id", d.id),
                                y: .value("res", d.correct)
                        ).foregroundStyle(answer_colors[.correct]!)
                    }
                    ForEach(data, id: \.self) { d in
                        BarMark(x: .value("Id", d.id),
                                y: .value("res", d.timeout)
                        ).foregroundStyle(answer_colors[.timeout]!)
                    }
                    ForEach(data, id: \.self) { d in
                        BarMark(x: .value("Id", d.id),
                                y: .value("res", d.incorrect)
                        ).foregroundStyle(answer_colors[.incorrect]!)
                    }
                }.chartXSelection(value: $selectedIndex)
                    .chartForegroundStyleScale([
                        "correct" : answer_colors[.correct]!,
                        "timeout": answer_colors[.timeout]!,
                        "error": answer_colors[.incorrect]!,
                    ])
                    .chartOverlay { pr in
                        if selectedIndex != nil {
                            let filtered_data = data.filter{ $0.id == selectedIndex }
                            OverlayView(filtered_data: filtered_data)
                        }
                    }
            }
        }
    }
}

struct OverlayView: View {
    @State var filtered_data: [HistoricalData]
    
    var body: some View {
        if !filtered_data.isEmpty{
            RoundedRectangle(cornerRadius: 5).foregroundStyle(Color(UIColor.secondarySystemBackground).opacity(0.95)).scaleEffect(1.1)
            GroupBox(filtered_data[0].id) {
                Chart {
                    BarMark(x: .value("date", rounded_date(date: Date()), unit: .day),
                            y: .value("res", 0)
                    )
                    BarMark(x: .value("date", rounded_date(date: Date()).addingTimeInterval(TimeInterval(-86400*7)), unit: .day),
                            y: .value("res", 0)
                    )
                    ForEach(filtered_data, id: \.self) { d in
                        BarMark(x: .value("date", d.date),
                                y: .value("res", d.correct)
                        ).foregroundStyle(answer_colors[.correct]!)
                    }
                    ForEach(filtered_data, id: \.self) { d in
                        BarMark(x: .value("date", d.date),
                                y: .value("res", d.timeout)
                        ).foregroundStyle(answer_colors[.timeout]!)
                    }
                    ForEach(filtered_data, id: \.self) { d in
                        BarMark(x: .value("date", d.date),
                                y: .value("res", d.incorrect)
                        ).foregroundStyle(answer_colors[.incorrect]!)
                    }
                }
            }
        }
    }
}

struct PracticeChart: View {
    @State var histData: [HistoricalData]
    @State var detailledData: [[HistoricalData]]
    @State var allKeys: [[String]]
    
    var body: some View {
        GroupBox("Practice and listening") {
            Chart {
                BarMark(x: .value("date", Date(), unit: .day),
                        y: .value("practice+listening", 0)
                )
                BarMark(x: .value("date", Date().addingTimeInterval(TimeInterval(-86400*7)), unit: .day),
                        y: .value("practice+listening", 0)
                )
                ForEach(histData, id: \.self) { d in
                    BarMark(x: .value("date", d.date, unit: .day),
                            y: .value("practice+listening", d.practice + d.listening)
                    )
                }
            }
            ForEach(Array(zip(detailledData, allKeys)), id: \.0){ data, keys in
                Chart {
                    ForEach(keys, id: \.self) { k in
                        BarMark(x: .value("Id",  short_answer(answer:k)),
                                y: .value("res",0))
                    }
                    ForEach(data, id: \.self) { d in
                        BarMark(x: .value("id", d.id),
                                y: .value("practice+listening", d.practice + d.listening)
                        )
                    }
                }
            }
        }
    }
}


#Preview {
    StatView()
}
