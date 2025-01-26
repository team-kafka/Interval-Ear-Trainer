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
    
    @State private var paramsPresented: Bool = false
    @State private var selectedIndex: Int = 0
    @Binding var saveUsageData: Bool
    
    init(saveUsageData: Binding<Bool>) {
        _selectedIndex = .init(initialValue: 0)
        _paramsPresented = .init(initialValue: false)
        _saveUsageData = .init(projectedValue: saveUsageData)
    }
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            StatsIntervalTopView()
                .tabItem {
                    Label("Intervals", systemImage: "arrow.up.and.down.square.fill")
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
        }
        .toolbar {
            Button(action: {paramsPresented = true}){
                Image(systemName: "gearshape.fill")
            }
        }
        .sheet(isPresented: $paramsPresented) {
            NavigationStack{
                StatParamsView(saveUsageData: $saveUsageData).modelContainer(for: HistoricalData.self)
            }
        }
        .toolbarRole(.editor)
        .tint(Color.gray.opacity(0.7))
        .onAppear(perform: {
            UITabBar.appearance().unselectedItemTintColor = .systemGray
            UITabBarItem.appearance().badgeColor = .systemGray
            UITabBar.appearance().backgroundColor = .systemGray4.withAlphaComponent(0.4)
            UINavigationBar.appearance()
        })
    }
}

struct StatsIntervalTopView: View {
    @State private var selectedIndex: Int = 0
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            StatsIntervalView(filter:"↑", title: "Ascending Intervals").modelContainer(for: HistoricalData.self)
                .tabItem {}.tag(0)
            StatsIntervalView(filter:"↓", title:"Descending Intervals").modelContainer(for: HistoricalData.self)
                .tabItem {}.tag(1)
            StatsIntervalView(filter:"H", title:"Harmonic Intervals").modelContainer(for: HistoricalData.self)
                .tabItem {}.tag(2)
        }.tint(Color.gray.opacity(0.7)).tabViewStyle(.page(indexDisplayMode: .automatic))
            .onAppear(perform: {
                UITabBar.appearance().unselectedItemTintColor = .systemGray
                UITabBarItem.appearance().badgeColor = .systemGray
                UITabBar.appearance().backgroundColor = .systemGray4.withAlphaComponent(0.4)
                UINavigationBar.appearance()
            })
    }
}

struct StatsIntervalView: View {
    
    var filter: String
    var title: String

    @Environment(\.modelContext) private var modelContext

    @Query var data: [HistoricalData]

    init(filter: String, title:String) {
        self.filter = filter
        self.title = title
        let typeI = ex_type_to_str(ex_type:.interval)
        self._data = Query(filter: #Predicate<HistoricalData> {$0.id.contains(filter) && $0.type == typeI})
    }
    var body: some View {

        VStack{
            Text(title).font(.title)
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
    @Query var data: [HistoricalData]

    init() {
        let typeT = ex_type_to_str(ex_type:.triad)
        self._data = Query(filter: #Predicate<HistoricalData> {$0.type == typeT})
    }
    
    var body: some View {
        VStack{
            Text("Triads").font(.title)
            PracticeChart(histData:data,
                          detailledData: data,
                          keys:TRIAD_KEYS)
            QuizzChart(data: data, keys: TRIAD_KEYS)
            Spacer()
        }
    }
}

struct StatsScaleDegreeView: View {
        
    @Environment(\.modelContext) private var modelContext
    @Query var data: [HistoricalData]
    
    init() {
        let typeS = ex_type_to_str(ex_type:.scale_degree)
        self._data = Query(filter: #Predicate<HistoricalData> {$0.type == typeS})
    }
    
    var body: some View {
        VStack{
            Text("Scale Degrees").font(.title)
            PracticeChart(histData:data,
                          detailledData: data,
                          keys:SCALE_DEGREE_KEYS_W_ALT)
            QuizzChart(data: data, keys: SCALE_DEGREE_KEYS_W_ALT)
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
                }.padding(.bottom).chartLegend(position: .bottom, alignment: .leading).chartXSelection(value: $selectedIndex)
                    .chartForegroundStyleScale([
                        "correct" : answer_colors[.correct]!,
                        "error": answer_colors[.incorrect]!,
                        "timeout": answer_colors[.timeout]!,
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

