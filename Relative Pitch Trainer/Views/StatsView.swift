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
    @State var showPercent: Bool

    init(data: [HistoricalData], keys: [String]) {
        self.data = data
        self.keys = keys
        _selectedIndex = .init(initialValue: nil)
        _showPercent = .init(initialValue: false)
    }
    
    var body: some View {
        GroupBox(label: HStack{
            Text("Quiz").foregroundColor(.secondary)
            Text(selectedIndex ?? "").foregroundColor(.secondary).fontWeight(.bold)
            Spacer()
            Image(systemName: "percent").padding(1).overlay(RoundedRectangle(cornerRadius: 4).stroke(lineWidth:2)).foregroundColor(.secondary).opacity(showPercent ? 1 : 0.5).scaleEffect(0.6)
                .onTapGesture { showPercent.toggle() }
        }) {
            let filteredData = flattenData(data: selectedIndex != nil ? data.filter{ $0.id == selectedIndex } : data, ignoreId: true)
            let flatData = flattenData(data: data)
            if showPercent{
                Chart{
                    ForEach(filteredData.sorted(by: {$0.valueType < $1.valueType}).sorted(by: {$0.date < $1.date}))  { d in
                        AreaMark(x: .value("date", d.date, unit: .day),
                                 y: .value("res", d.value),
                                 stacking: .normalized
                        ).foregroundStyle( by: .value("res", d.valueType))
                    }
                }.chartForegroundStyleScale([
                    "correct" : ANSWER_COLORS[.correct]!,
                    "error": ANSWER_COLORS[.incorrect]!,
                    "timeout": ANSWER_COLORS[.timeout]!,
                ])
            } else {
                Chart {
                    BarMark(x: .value("date", rounded_date(date: Date()), unit: .day),
                            y: .value("res", 0)
                    )
                    BarMark(x: .value("date", rounded_date(date: Date()).addingTimeInterval(TimeInterval(-86400*7)), unit: .day),
                            y: .value("res", 0)
                    )
                    ForEach(filteredData.sorted(by: {$0.valueType < $1.valueType}), id: \.self) { d in
                        BarMark(x: .value("date", d.date, unit: .day),
                                y: .value("res", d.value)
                        ).foregroundStyle( by: .value("res", d.valueType))
                    }
                }.chartForegroundStyleScale([
                    "correct" : ANSWER_COLORS[.correct]!,
                    "error": ANSWER_COLORS[.incorrect]!,
                    "timeout": ANSWER_COLORS[.timeout]!,
                ]).chartLegend(position: .bottom, alignment: .leading)
            }
            Chart {
                ForEach(keys, id: \.self) { k in
                    BarMark(x: .value("Id", short_answer(answer:k)),
                            y: .value("res",0))
                }
                ForEach(flatData.sorted(by: {$0.valueType < $1.valueType}), id: \.self) { d in
                    BarMark(x: .value("id", d.id),
                            y: .value("res", d.value),
                            stacking: showPercent ? .normalized : .standard
                    ).foregroundStyle( by: .value("res", d.valueType))
                }
            }.padding(.bottom).chartLegend(.hidden).chartXSelection(value: $selectedIndex)
                .chartForegroundStyleScale([
                    "correct" : ANSWER_COLORS[.correct]!,
                    "error": ANSWER_COLORS[.incorrect]!,
                    "timeout": ANSWER_COLORS[.timeout]!,
                ])
        }
    }
}

struct PracticeChart: View {
    @State var histData: [HistoricalData]
    @State var detailledData: [HistoricalData]
    @State var keys: [String]
    @State var selectedIndex: Date?
    var formatter  = DateFormatter()
    
    init(histData: [HistoricalData], detailledData: [HistoricalData], keys: [String]) {
        _histData = .init(initialValue: histData)
        _detailledData = .init(initialValue: detailledData)
        _keys = .init(initialValue: keys)
        _selectedIndex = .init(initialValue: nil)
        formatter.dateStyle = .short
    }
    
    var body: some View {
        GroupBox(label: HStack{
            Text("Listening").foregroundColor(.secondary)
            if selectedIndex != nil {Text(formatter.string(from: selectedIndex!)).foregroundColor(.secondary).fontWeight(.bold)}
        }) {
            Chart {
                ForEach(keys, id: \.self) { k in
                    BarMark(x: .value("Id", short_answer(answer:k)),
                            y: .value("res",0))
                }
                if selectedIndex == nil {
                    ForEach(detailledData, id: \.self) { d in
                        if keys.contains(d.id) {
                            BarMark(x: .value("id", d.id),
                                    y: .value("practice+listening", d.listening))
                        }
                    }
                } else {
                    ForEach(detailledData.filter{ d in Calendar.current.isDate(d.date, equalTo: selectedIndex!, toGranularity: .day) }, id: \.self) { d in
                        if keys.contains(d.id)  {
                            BarMark(x: .value("id", d.id),
                                    y: .value("practice+listening", d.listening))
                        }
                    }
                }
            }
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
            }.chartXSelection(value: $selectedIndex)
        }
    }
}
