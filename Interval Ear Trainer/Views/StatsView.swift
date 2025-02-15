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

let LABELS = ["Intervals", "Triads", "Scale degrees"]

struct StatView: View {
    
    @State private var selectedIndex: Int = 0
    
    init() {
        _selectedIndex = .init(initialValue: 0)
    }
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            StatsIntervalTopView()
                .tabItem {
                    Label(LABELS[0], systemImage: "arrow.up.and.down.square.fill")
                }
                .tag(0)
            StatsTriadView().modelContainer(for: HistoricalData.self)
                .tabItem {
                    Label(LABELS[1], systemImage: "music.quarternote.3")
                }
                .tag(1)
            StatsScaleDegreeView().modelContainer(for: HistoricalData.self)
                .tabItem {
                    Label(LABELS[2], systemImage: "key")
                }
                .tag(2)
        }
        .toolbarRole(.editor)
        .navigationTitle(LABELS[selectedIndex]).navigationBarTitleDisplayMode(.inline)
        .tint(Color.gray)
        .onAppear(perform: {
            UITabBar.appearance().unselectedItemTintColor = .systemGray
            UITabBarItem.appearance().badgeColor = .systemGray
            UITabBar.appearance().backgroundColor = .systemGray4.withAlphaComponent(0.7)
            UINavigationBar.appearance()
        })
    }
}

struct StatsIntervalTopView: View {
    @State private var selectedIndex: Int
    
    init() {
        _selectedIndex = .init(initialValue: 0)
    }
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            StatsIntervalView(filter:"↑").modelContainer(for: HistoricalData.self)
                .tabItem {}.tag(0)
            StatsIntervalView(filter:"↓").modelContainer(for: HistoricalData.self)
                .tabItem {}.tag(1)
            StatsIntervalView(filter:"H").modelContainer(for: HistoricalData.self)
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

    @Environment(\.modelContext) private var modelContext
    @Query var data: [HistoricalData]

    @State private var orientation: UIDeviceOrientation

    init(filter: String) {
        self.filter = filter
        let typeI = ex_type_to_str(ex_type:.interval)
        self._data = Query(filter: #Predicate<HistoricalData> {$0.id.contains(filter) && $0.type == typeI})
        self.orientation = UIDevice.current.orientation.isLandscape ? UIDeviceOrientation.landscapeLeft : UIDeviceOrientation.portrait
    }
    
    var body: some View {
        Group {
            if orientation.isPortrait {
                VStack{
                    PracticeChart(histData: data ,
                                  detailledData: data,
                                  keys:INTERVAL_KEYS.map{filter + $0})
                    QuizzChart(data: data,
                               keys:INTERVAL_KEYS.map{filter + $0})
                    Spacer()
                }
            } else {
                VStack{
                    ScrollView(.vertical) {
                        PracticeChart(histData: data ,
                                      detailledData: data,
                                      keys:INTERVAL_KEYS.map{filter + $0}).containerRelativeFrame(.vertical)
                        QuizzChart(data: data,
                                   keys:INTERVAL_KEYS.map{filter + $0}).containerRelativeFrame(.vertical)
                        Spacer()
                    }.scrollTargetBehavior(.paging)
                }.scrollTargetLayout()
            }
        }
        .onAppear {
            orientation = UIDevice.current.orientation.isLandscape ? UIDeviceOrientation.landscapeLeft : UIDeviceOrientation.portrait
        }
        .onRotate { newOrientation in
            if (newOrientation == UIDeviceOrientation.portrait || newOrientation == UIDeviceOrientation.landscapeLeft || newOrientation == UIDeviceOrientation.landscapeRight) { orientation = newOrientation }
            }
    }
}

struct StatsTriadView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query var data: [HistoricalData]
    
    @State private var orientation: UIDeviceOrientation
    
    init() {
        let typeT = ex_type_to_str(ex_type:.triad)
        self._data = Query(filter: #Predicate<HistoricalData> {$0.type == typeT})
        self.orientation = UIDevice.current.orientation.isLandscape ? UIDeviceOrientation.landscapeLeft : UIDeviceOrientation.portrait
    }
    
    var body: some View {
        Group {
            if orientation.isPortrait {
                VStack{
                    PracticeChart(histData:data,
                                  detailledData: data,
                                  keys:TRIAD_KEYS)
                    QuizzChart(data: data, keys: TRIAD_KEYS)
                    Spacer()
                }
            } else {
                VStack{
                    ScrollView(.vertical) {
                        PracticeChart(histData:data,
                                      detailledData: data,
                                      keys:TRIAD_KEYS).containerRelativeFrame(.vertical)
                        QuizzChart(data: data, keys: TRIAD_KEYS).containerRelativeFrame(.vertical)
                        Spacer()
                    }.scrollTargetBehavior(.paging)
                }.scrollTargetLayout()
            }
        }
        .onAppear {
            orientation = UIDevice.current.orientation.isLandscape ? UIDeviceOrientation.landscapeLeft : UIDeviceOrientation.portrait
        }
        .onRotate { newOrientation in
        if (newOrientation == UIDeviceOrientation.portrait || newOrientation == UIDeviceOrientation.landscapeLeft || newOrientation == UIDeviceOrientation.landscapeRight) { orientation = newOrientation }
        }
    }
}


struct StatsScaleDegreeView: View {
        
    @Environment(\.modelContext) private var modelContext
    @Query var data: [HistoricalData]
    @State private var orientation: UIDeviceOrientation

    init() {
        let typeS = ex_type_to_str(ex_type:.scale_degree)
        self._data = Query(filter: #Predicate<HistoricalData> {$0.type == typeS})
        self.orientation = UIDevice.current.orientation.isLandscape ? UIDeviceOrientation.landscapeLeft : UIDeviceOrientation.portrait
    }
    
    var body: some View {
        Group {
            if orientation.isPortrait {
                VStack{
                    PracticeChart(histData:data,
                                  detailledData: data,
                                  keys:SCALE_DEGREE_KEYS_W_ALT)
                    QuizzChart(data: data, keys: SCALE_DEGREE_KEYS_W_ALT)
                    Spacer()
                }
            } else {
                VStack{
                    ScrollView(.vertical) {
                        PracticeChart(histData:data,
                                      detailledData: data,
                                      keys:SCALE_DEGREE_KEYS_W_ALT).containerRelativeFrame(.vertical)
                        QuizzChart(data: data, keys: SCALE_DEGREE_KEYS_W_ALT).containerRelativeFrame(.vertical)
                        Spacer()
                    }.scrollTargetBehavior(.paging)
                }.scrollTargetLayout()
            }
        }
        .onAppear {
            orientation = UIDevice.current.orientation.isLandscape ? UIDeviceOrientation.landscapeLeft : UIDeviceOrientation.portrait
        }
        .onRotate { newOrientation in
            if (newOrientation == UIDeviceOrientation.portrait || newOrientation == UIDeviceOrientation.landscapeLeft || newOrientation == UIDeviceOrientation.landscapeRight) { orientation = newOrientation }
            }
    }
}

struct QuizzChart: View {
   
    var data: [HistoricalData]
    var keys: [String]
    @State var selectedIndex: String?

    init(data: [HistoricalData], keys: [String]) {
        self.data = data
        self.keys = keys
        _selectedIndex = .init(initialValue: nil)
    }
    
    var body: some View {
        GroupBox("Quiz") {
                Chart {
                    ForEach(keys, id: \.self) { k in
                        BarMark(x: .value("Id", short_answer(answer:k)),
                                y: .value("res",0))
                    }
                    ForEach(data, id: \.self) { d in
                        if keys.contains(d.id) {
                            BarMark(x: .value("Id", d.id),
                                    y: .value("res", d.correct)
                            ).foregroundStyle(ANSWER_COLORS[.correct]!)
                        }
                    }
                    ForEach(data, id: \.self) { d in
                        if keys.contains(d.id) {
                            BarMark(x: .value("Id", d.id),
                                    y: .value("res", d.timeout)
                            ).foregroundStyle(ANSWER_COLORS[.timeout]!)
                        }
                    }
                    ForEach(data, id: \.self) { d in
                        if keys.contains(d.id) {
                            BarMark(x: .value("Id", d.id),
                                    y: .value("res", d.incorrect)
                            ).foregroundStyle(ANSWER_COLORS[.incorrect]!)
                        }
                    }
                }.padding(.bottom).chartLegend(position: .bottom, alignment: .leading).chartXSelection(value: $selectedIndex)
                    .chartForegroundStyleScale([
                        "correct" : ANSWER_COLORS[.correct]!,
                        "error": ANSWER_COLORS[.incorrect]!,
                        "timeout": ANSWER_COLORS[.timeout]!,
                    ])
                    .chartOverlay { pr in
                        if selectedIndex != nil {
                            OverlayView(filteredData: data.filter{ $0.id == selectedIndex })
                        }
                    }
        }
    }
}

struct OverlayView: View {
    var filteredData: [HistoricalData]
    
    init(filteredData: [HistoricalData]) {
        self.filteredData = filteredData
    }
    
    var body: some View {
        if !filteredData.isEmpty{
            RoundedRectangle(cornerRadius: 5).foregroundStyle(Color(UIColor.secondarySystemBackground).opacity(0.95)).scaleEffect(1.05)
            GroupBox(filteredData[0].id) {
                Chart {
                    BarMark(x: .value("date", rounded_date(date: Date()), unit: .day),
                            y: .value("res", 0)
                    )
                    BarMark(x: .value("date", rounded_date(date: Date()).addingTimeInterval(TimeInterval(-86400*7)), unit: .day),
                            y: .value("res", 0)
                    )
                    ForEach(filteredData, id: \.self) { d in
                        BarMark(x: .value("date", d.date, unit: .day),
                                y: .value("res", d.correct)
                        ).foregroundStyle(ANSWER_COLORS[.correct]!)
                    }
                    ForEach(filteredData, id: \.self) { d in
                        BarMark(x: .value("date", d.date, unit: .day),
                                y: .value("res", d.timeout)
                        ).foregroundStyle(ANSWER_COLORS[.timeout]!)
                    }
                    ForEach(filteredData, id: \.self) { d in
                        BarMark(x: .value("date", d.date, unit: .day),
                                y: .value("res", d.incorrect)
                        ).foregroundStyle(ANSWER_COLORS[.incorrect]!)
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
    
    init(histData: [HistoricalData], detailledData: [HistoricalData], keys: [String]) {
        _histData = .init(initialValue: histData)
        _detailledData = .init(initialValue: detailledData)
        _keys = .init(initialValue: keys)
    }
    
    var body: some View {
        GroupBox("Listening") {
            Chart {
                BarMark(x: .value("date", rounded_date(date: Date()), unit: .day),
                        y: .value("practice+listening", 0))
                BarMark(x: .value("date", rounded_date(date: Date().addingTimeInterval(TimeInterval(-86400*7))), unit: .day),
                        y: .value("practice+listening", 0))
                ForEach(histData, id: \.self) { d in
                    BarMark(x: .value("date", d.date, unit: .day),
                            y: .value("practice+listening", d.listening)
                    )
                }
            }
//            .chartScrollableAxes(.horizontal)
//            .chartScrollPosition(initialX: Date())
//            .chartXVisibleDomain(length: 86400*20)
            Chart {
                ForEach(keys, id: \.self) { k in
                    BarMark(x: .value("Id", short_answer(answer:k)),
                            y: .value("res",0))
                }
                ForEach(detailledData, id: \.self) { d in
                    if keys.contains(d.id) {
                        BarMark(x: .value("id", d.id),
                                y: .value("practice+listening", d.listening))
                    }
                }
            }
        }
    }
}

