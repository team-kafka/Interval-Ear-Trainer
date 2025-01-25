//
//  MainMenu.swift
//  My First App
//
//  Created by Nicolas on 2024/12/10.
//

import SwiftUI
import SwiftData

struct MainMenu: View {
    @Environment(\.modelContext) private var modelContext
    @Query() private var usageData: [HistoricalData]
    
    @AppStorage("saveUsageData") var saveUsageData: Bool = true
    
    @AppStorage("paramsIP") var paramsIP: String = Parameters(type:.interval).encode()
    @AppStorage("paramsTP") var paramsTP: String = Parameters(type:.triad, n_notes:3, is_chord:true).encode()
    @AppStorage("paramsSP") var paramsSP: String = Parameters(type:.scale_degree, n_notes:1).encode()

    @AppStorage("paramsIQ") var paramsIQ: String = Parameters(type:.interval).encode()
    @AppStorage("paramsTQ") var paramsTQ: String = Parameters(type:.triad, n_notes:3, is_chord:true).encode()
    @AppStorage("paramsSQ") var paramsSQ: String = Parameters(type:.scale_degree, n_notes:1).encode()

    @AppStorage("paramsIL1") var paramsIL1: String = Parameters(type:.interval, active_intervals:[3, 4]).encode()
    @AppStorage("paramsIL2") var paramsIL2: String = Parameters(type:.interval, active_intervals:[8, 9, 10]).encode()
    @AppStorage("paramsIL3") var paramsIL3: String = Parameters(type:.interval, active_intervals:[-8, -9, -10]).encode()
    @AppStorage("paramsTL") var paramsTL: String = Parameters(type:.triad, n_notes:3, is_chord:true).encode()
    @AppStorage("paramsSL") var paramsSL: String = Parameters(type:.scale_degree, n_notes:1).encode()
    
    var body: some View {
        NavigationStack{
            List{
                Section(header: Text("Practice")) {
                    NavigationLink(destination: PracticeView(params: Parameters.decode(paramsIP), dftParams: $paramsIP, saveUsageData: $saveUsageData).modelContainer(for: HistoricalData.self).navigationBarBackButtonHidden(true)){
                        Text("Intervals").font(.headline)
                    }
                    NavigationLink(destination:
                                    PracticeView(params: Parameters.decode(paramsTP), dftParams: $paramsTP, saveUsageData: $saveUsageData, fixed_n_notes:true).modelContainer(for: HistoricalData.self).navigationBarBackButtonHidden(true)){
                        Text("Triads").font(.headline)
                    }
                    NavigationLink(destination:
                                    PracticeView(params: Parameters.decode(paramsSP), dftParams: $paramsSP, saveUsageData: $saveUsageData, chord_active: false).modelContainer(for: HistoricalData.self).navigationBarBackButtonHidden(true)){
                        Text("Scale Degrees").font(.headline)
                    }
                }.navigationTitle(Text("Interval Ear Trainer"))
            
                Section(header: Text("Quiz")) {
                    NavigationLink(destination: QuizView(params: Parameters.decode(paramsIQ), dftParams: $paramsIQ, saveUsageData: $saveUsageData).modelContainer(for: HistoricalData.self).navigationBarBackButtonHidden(true)){
                        Text("Intervals").font(.headline)
                    }

                    NavigationLink(destination: QuizView(params: Parameters.decode(paramsTQ), dftParams: $paramsTQ, saveUsageData: $saveUsageData, n_notes:3, fixed_n_notes:true, chord: true).modelContainer(for: HistoricalData.self).navigationBarBackButtonHidden(true)){
                        Text("Triads").font(.headline)
                    }
                    NavigationLink(destination: QuizView(params: Parameters.decode(paramsSQ), dftParams: $paramsSQ, saveUsageData: $saveUsageData, n_notes:1, chord_active: false).modelContainer(for: HistoricalData.self).navigationBarBackButtonHidden(true)){
                        Text("Scale Degrees").font(.headline)
                    }
                }
                Section(header: Text("Listening")) {
                    ListeningView(params:Parameters.decode(paramsIL1), dftParams: $paramsIL1, saveUsageData: $saveUsageData, id:"LVI1").modelContainer(for: HistoricalData.self)
                    ListeningView(params:Parameters.decode(paramsIL2), dftParams: $paramsIL2, saveUsageData: $saveUsageData, id:"LVI2").modelContainer(for: HistoricalData.self)
                    ListeningView(params:Parameters.decode(paramsIL3), dftParams: $paramsIL3, saveUsageData: $saveUsageData, id:"LVI3").modelContainer(for: HistoricalData.self)
                    ListeningView(params:Parameters.decode(paramsTL), dftParams: $paramsTL, saveUsageData: $saveUsageData, id:"LVT1").modelContainer(for: HistoricalData.self)
                    ListeningView(params:Parameters.decode(paramsSL), dftParams: $paramsSL, saveUsageData: $saveUsageData, id:"LVS1").modelContainer(for: HistoricalData.self)
                }
                Section(header: Text("Statistics")) {
                        NavigationLink(destination: StatView().navigationBarBackButtonHidden(true)){Image(systemName: "chart.line.uptrend.xyaxis")
                            Text("View").font(.headline)
                        }
                        NavigationLink(destination:
                            StatParamsView(saveUsageData: $saveUsageData).modelContainer(for: HistoricalData.self).navigationBarBackButtonHidden(true)){Image(systemName: "gearshape.fill")
                            Text("Settings").font(.headline)
                        }
                    }
            }
        }.onAppear(){
            compressPastData()
        }
    }
    
    func compressPastData()
    {
        let olderUD = usageData.filter({ $0.date < rounded_date(date:Date()) })
        print("before compressing: \(olderUD.count) entries")
        let allKeys = Array(Set(olderUD.map{usageDataKey(date:$0.date, type:$0.type, id:$0.id)}))
        if allKeys.count < olderUD.count {
            var newUsageData: [HistoricalData] = []
            for key in allKeys {
                let filteredData = olderUD.filter({$0.date == key.date && $0.type == key.type && $0.id == key.id})
                if filteredData.count > 1 {
                    let newUD = HistoricalData(date:key.date, type: key.type, id:key.id)
                    for ud in filteredData {
                        newUD.listening += ud.listening
                        newUD.practice += ud.practice
                        newUD.correct += ud.correct
                        newUD.timeout += ud.timeout
                        newUD.incorrect += ud.incorrect
                    }
                    newUsageData.append(newUD)
                    
                    modelContext.insert(newUD)
                    for ud in filteredData {
                        modelContext.delete(ud)
                    }
                } else {
                    newUsageData.append(filteredData[0])
                }
            }
            print("after: \(newUsageData.count) entries")
            try! modelContext.save()
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

extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
