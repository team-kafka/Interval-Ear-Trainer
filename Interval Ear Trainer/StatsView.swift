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
            StatsIntervalView(filter:"↑").modelContainer(for: HistoricalData.self)
                .tabItem {
                    Label("Inter", systemImage: "arrow.up.square")
                }
                .tag(0)
            StatsIntervalView(filter:"↓").modelContainer(for: HistoricalData.self)
                .tabItem {
                    Label("Inter", systemImage: "arrow.down.square")
                }
                .tag(1)
            StatsIntervalView(filter:"H").modelContainer(for: HistoricalData.self)
                .tabItem {
                    Label("Inter", systemImage: "h.square")
                }
                .tag(2)
            StatsTriadView().modelContainer(for: HistoricalData.self)
            .tabItem {
                Label("Triads", systemImage: "music.quarternote.3")
            }
            .tag(3)
            StatsScaleDegreeView().modelContainer(for: HistoricalData.self)
            .tabItem {
                Text("Scale Degrees")
                Image(systemName: "key")
            }
            .tag(4)
            StatParamsView().modelContainer(for: HistoricalData.self)
            .tabItem {
                Text("Settings")
                Image(systemName: "gearshape.fill")
            }
            .tag(5)
        }//.tabViewStyle()
        .tint(Color.gray.opacity(0.7))
        .onAppear(perform: {
            UITabBar.appearance().unselectedItemTintColor = .systemGray
            UITabBarItem.appearance().badgeColor = .systemGray
            UITabBar.appearance().backgroundColor = .systemGray4.withAlphaComponent(0.4)
            UINavigationBar.appearance()//.largeTitleTextAttributes = [.foregroundColor: UIColor.systemGray]
        })
    }
}
//extension UITabBarController {
//    override open func viewDidLoad() {
//        let standardAppearance = UITabBarAppearance()
//        
////        standardAppearance.st
//        standardAppearance.stackedItemPositioning = .centered
//        standardAppearance.stackedItemSpacing = 10
//        standardAppearance.stackedItemWidth = 30
//        
//        tabBar.standardAppearance = standardAppearance
//    }
//}

struct StatsIntervalView: View {
    
    var filter: String
    
    @Environment(\.modelContext) private var modelContext

    @Query var data: [HistoricalData]

    init(filter: String) {
        self.filter = filter
        self._data = Query(filter: #Predicate<HistoricalData> {$0.id.contains(filter) && $0.type == "interval"})
    }
    var body: some View {

        VStack{
            Text("Intervals").font(.title)
            PracticeChart(histData: data ,
                          detailledData: data,
                          keys:INTERVAL_KEYS.map{filter + $0})
                       QuizzChart(data: data,
                       keys:INTERVAL_KEYS.map{filter + $0})
            Spacer()
        }
    }
}

struct StatsTriadView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<HistoricalData> {$0.type == "triad"})  var historicalData: [HistoricalData]

    var body: some View {
        VStack{
            Text("Triads").font(.title)
            PracticeChart(histData:historicalData,
                          detailledData: historicalData,
                          keys:TRIAD_KEYS)
            QuizzChart(data: historicalData, keys: TRIAD_KEYS)
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
            PracticeChart(histData:historicalData,
                          detailledData: historicalData,
                          keys:SCALE_DEGREE_KEYS_W_ALT)
            QuizzChart(data: historicalData, keys: SCALE_DEGREE_KEYS_W_ALT)
            Spacer()
        }
    }
}

struct QuizzChart: View {
   
    @State var data: [HistoricalData]
    @State var keys: [String]
    
    @State var selectedIndex: String?

    var body: some View {
        GroupBox("Quiz") {
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
                        BarMark(x: .value("date", d.date, unit: .day),
                                y: .value("res", d.correct)
                        ).foregroundStyle(answer_colors[.correct]!)
                    }
                    ForEach(filtered_data, id: \.self) { d in
                        BarMark(x: .value("date", d.date, unit: .day),
                                y: .value("res", d.timeout)
                        ).foregroundStyle(answer_colors[.timeout]!)
                    }
                    ForEach(filtered_data, id: \.self) { d in
                        BarMark(x: .value("date", d.date, unit: .day),
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
    @State var detailledData: [HistoricalData]
    @State var keys: [String]
    
    var body: some View {
        GroupBox("Practice and listening") {
            Chart {
                BarMark(x: .value("date", rounded_date(date: Date()), unit: .day),
                        y: .value("practice+listening", 0)
                )
                BarMark(x: .value("date", rounded_date(date: Date().addingTimeInterval(TimeInterval(-86400*7))), unit: .day),
                        y: .value("practice+listening", 0)
                )
                ForEach(histData, id: \.self) { d in
                    BarMark(x: .value("date", d.date, unit: .day),
                            y: .value("practice+listening", d.practice + d.listening)
                    )
                }
            }
            Chart {
                ForEach(keys, id: \.self) { k in
                    BarMark(x: .value("Id", short_answer(answer:k)),
                            y: .value("res",0))
                }
                ForEach(detailledData, id: \.self) { d in
                    BarMark(x: .value("id", d.id),
                            y: .value("practice+listening", d.practice + d.listening)
                    )
                }
            }
        }
    }
}


#Preview {
    StatView()
}
