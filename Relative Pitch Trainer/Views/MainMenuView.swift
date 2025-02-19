//
//  MainMenu.swift
//  My First App
//
//  Created by Nicolas on 2024/12/10.
//

import SwiftUI
import SwiftData

let INTERVAL_LISTENING_IDS = ["LVI1", "LVI2", "LVI3"]

struct MainMenu: View {
    @Environment(\.modelContext) private var modelContext
    @Query() private var usageData: [HistoricalData]
    @AppStorage("saveUsageData") var saveUsageData: Bool = true
    @AppStorage("showHelp") var showHelp: Bool = false

    var body: some View {
        NavigationStack{
            List{
                MainMenuListeningView()
                MainMenuQuizView().navigationTitle(Text("Relative Pitch Trainer")).navigationBarTitleDisplayMode(.inline)
            }.toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: StatView()) { Image(systemName: "chart.line.uptrend.xyaxis") }.padding([.leading])
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: showHelp ? "questionmark.circle.fill" : "questionmark.circle" ).foregroundStyle(.gray).opacity(showHelp ? 1 : 0.5).padding([.leading]).onTapGesture { showHelp.toggle() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView(saveUsageData: $saveUsageData).modelContainer(for: HistoricalData.self)) { Image(systemName: "gearshape.fill") }.padding([.trailing])
                }
            }
        }
        .environment(\.colorScheme, .dark)
        .tint(.gray)
        .onAppear(){
            compressPastData()
        }
    }

    func compressPastData()
    {
        let olderUD = usageData.filter({ $0.date < rounded_date(date:Date()) })
        let allKeys = Array(Set(olderUD.map{usageDataKey(date:$0.date, type:$0.type, id:$0.id)}))
        if allKeys.count < olderUD.count {
            for key in allKeys {
                let filteredData = olderUD.filter({$0.date == key.date && $0.type == key.type && $0.id == key.id})
                if filteredData.count > 1 {
                    let newUD = HistoricalData(date:key.date, type: key.type, id:key.id)
                    for ud in filteredData {
                        newUD.listening += ud.listening
                        newUD.correct   += ud.correct
                        newUD.timeout   += ud.timeout
                        newUD.incorrect += ud.incorrect
                    }
                    modelContext.insert(newUD)
                    for ud in filteredData {
                        modelContext.delete(ud)
                    }
                }
            }
            try! modelContext.save()
        }
    }
}

struct MainMenuListeningView: View {
    @Environment(\.modelContext) private var modelContext
    @Query() private var usageData: [HistoricalData]
    
    @AppStorage("saveUsageData") var saveUsageData: Bool = true
    @AppStorage("showHelp") var showHelp: Bool = false
    
    @AppStorage("paramsIL1") var paramsIL1: String = Parameters(type:.interval, active_intervals:[3, 4]).encode()
    @AppStorage("paramsIL2") var paramsIL2: String = Parameters(type:.interval, active_intervals:[-9]).encode()
    @AppStorage("paramsIL3") var paramsIL3: String = Parameters(type:.interval, active_intervals:[-8]).encode()
    @AppStorage("paramsILC") var paramsILC: String = Parameters(type:.interval, active_intervals:[-8, -9], compare_intervals:true).encode()
    @AppStorage("paramsTL") var paramsTL: String = Parameters(type:.triad, n_notes:3, is_chord:true).encode()
    @AppStorage("paramsSL") var paramsSL: String = Parameters(type:.scale_degree, n_notes:1).encode()
    
    var body: some View {
        Section(header: HStack{
            Text("Listening")
            if showHelp { HelpMarkView(opacity:0.7){HelpListeningPOView()} }
        }) {
            ListeningView(params:Parameters.decode(paramsIL1), dftParams: $paramsIL1, saveUsageData: $saveUsageData, id:"LVI1", label:"Intervals", helpText:AnyView(HelpListeningIntervalsPOView())).modelContainer(for: HistoricalData.self)
            ListeningView(params:Parameters.decode(paramsIL2), dftParams: $paramsIL2, saveUsageData: $saveUsageData, id:"LVI2").modelContainer(for: HistoricalData.self)
            ListeningView(params:Parameters.decode(paramsIL3), dftParams: $paramsIL3, saveUsageData: $saveUsageData, id:"LVI3").modelContainer(for: HistoricalData.self)
            ListeningView(params:Parameters.decode(paramsILC), dftParams: $paramsILC, saveUsageData: $saveUsageData, id:"LVIC", label:"Interval Comparison", helpText:AnyView(HelpListeningIntervalComparisonPOView())).modelContainer(for: HistoricalData.self)
            ListeningView(params:Parameters.decode(paramsTL), dftParams: $paramsTL, saveUsageData: $saveUsageData, id:"LVT1", label:"Triads", helpText:AnyView(HelpListeningTriadPOView())).modelContainer(for: HistoricalData.self)
            ListeningView(params:Parameters.decode(paramsSL), dftParams: $paramsSL, saveUsageData: $saveUsageData, id:"LVS1", label:"Scale Degrees", helpText:AnyView(HelpListeningScaleDegreePOView())).modelContainer(for: HistoricalData.self)
        }
    }
}

struct MainMenuQuizView: View {
    @Environment(\.modelContext) private var modelContext
    @Query() private var usageData: [HistoricalData]
    
    @AppStorage("saveUsageData") var saveUsageData: Bool = true
    @AppStorage("showHelp") var showHelp: Bool = false

    @AppStorage("paramsIQ") var paramsIQ: String = Parameters(type:.interval).encode()
    @AppStorage("paramsTQ") var paramsTQ: String = Parameters(type:.triad, n_notes:3, is_chord:true).encode()
    @AppStorage("paramsSQ") var paramsSQ: String = Parameters(type:.scale_degree, n_notes:1).encode()

    
    var body: some View {
        Section(header: HStack{
            Text("Quiz")
            if showHelp {HelpMarkView(opacity:0.7){HelpQuizPOView()}}
        }) {
            NavigationLink(destination: QuizView(params: Parameters.decode(paramsIQ), dftParams: $paramsIQ, saveUsageData: $saveUsageData).modelContainer(for: HistoricalData.self)){
                Text("Intervals").font(.headline)
            }
            NavigationLink(destination: QuizView(params: Parameters.decode(paramsTQ), dftParams: $paramsTQ, saveUsageData: $saveUsageData, n_notes:3, fixed_n_notes:true, chord: true).modelContainer(for: HistoricalData.self)){
                Text("Triads").font(.headline)
            }
            NavigationLink(destination: QuizView(params: Parameters.decode(paramsSQ), dftParams: $paramsSQ, saveUsageData: $saveUsageData, n_notes:1, chord_active: false).modelContainer(for: HistoricalData.self)){
                Text("Scale Degrees").font(.headline)
            }
        }
    }
}

#Preview {
    MainMenu().modelContainer(for: HistoricalData.self)
}

struct usageDataKey: Hashable{
    var date:Date
    var type:String
    var id:String
}
