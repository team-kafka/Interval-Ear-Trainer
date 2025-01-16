//
//  MainMenu.swift
//  My First App
//
//  Created by Nicolas on 2024/12/10.
//

import SwiftUI
import SwiftData

struct MainMenu: View {
    
    @AppStorage("paramsIP") var paramsIP: String = Parameters(type:.interval).encode()
    @AppStorage("paramsTP") var paramsTP: String = Parameters(type:.triad, is_chord:true).encode()
    @AppStorage("paramsSP") var paramsSP: String = Parameters(type:.scale_degree, n_notes:1).encode()

    @AppStorage("paramsIQ") var paramsIQ: String = Parameters(type:.interval).encode()
    @AppStorage("paramsTQ") var paramsTQ: String = Parameters(type:.triad, is_chord:true).encode()
    @AppStorage("paramsSQ") var paramsSQ: String = Parameters(type:.scale_degree, n_notes:1).encode()

    @AppStorage("paramsIL1") var paramsIL1: String = Parameters(type:.interval, active_intervals:[3, 4]).encode()
    @AppStorage("paramsIL2") var paramsIL2: String = Parameters(type:.interval, active_intervals:[8, 9, 10]).encode()
    @AppStorage("paramsIL3") var paramsIL3: String = Parameters(type:.interval, active_intervals:[-8, -9, -10]).encode()
    @AppStorage("paramsTL") var paramsTL: String = Parameters(type:.triad, is_chord:true).encode()
    @AppStorage("paramsSL") var paramsSL: String = Parameters(type:.scale_degree, n_notes:1).encode()
    
    var body: some View {
        NavigationStack{
            List{
                Section(header: Text("Practice")) {
                    NavigationLink(destination: PracticeView(params: Parameters.decode(paramsIP), dftParams: $paramsIP ).navigationBarBackButtonHidden(true)){
                        Text("Intervals").font(.headline)
                    }
                    NavigationLink(destination:
                                    PracticeView(params: Parameters.decode(paramsTP), dftParams: $paramsTP, fixed_n_notes:true).navigationBarBackButtonHidden(true)){
                        Text("Triads").font(.headline)
                    }
                    NavigationLink(destination:
                                    PracticeView(params: Parameters.decode(paramsSP), dftParams: $paramsSP, chord_active: false).navigationBarBackButtonHidden(true)){
                        Text("Scale Degrees").font(.headline)
                        
                    }
                }.navigationTitle(Text("Interval Ear Trainer"))
            
                Section(header: Text("Quiz")) {
                    NavigationLink(destination: QuizView(params: Parameters.decode(paramsIQ), dftParams: $paramsIQ).navigationBarBackButtonHidden(true)){
                        Text("Intervals").font(.headline)
                    }

                    NavigationLink(destination: QuizView(params: Parameters.decode(paramsTQ), dftParams: $paramsTQ, n_notes:3, fixed_n_notes:true, chord: true).navigationBarBackButtonHidden(true)){
                        Text("Triads").font(.headline)
                    }
                    NavigationLink(destination: QuizView(params: Parameters.decode(paramsSQ), dftParams: $paramsSQ, n_notes:1, chord_active: false).navigationBarBackButtonHidden(true)){
                        Text("Scale Degrees").font(.headline)
                    }
                }
                Section(header: Text("Listening")) {
                    ListeningView(params:Parameters.decode(paramsIL1), dftParams: $paramsIL1).modelContainer(for: HistoricalData.self)
                    ListeningView(params:Parameters.decode(paramsIL2), dftParams: $paramsIL2).modelContainer(for: HistoricalData.self)
                    ListeningView(params:Parameters.decode(paramsIL3), dftParams: $paramsIL3).modelContainer(for: HistoricalData.self)
                    ListeningView(params:Parameters.decode(paramsTL), dftParams: $paramsTL).modelContainer(for: HistoricalData.self)
                    ListeningView(params:Parameters.decode(paramsSL), dftParams: $paramsSL).modelContainer(for: HistoricalData.self)
            }
                Section(header: Text("Stats")) {
                    NavigationLink(destination: StatView().navigationBarBackButtonHidden(true)){Image(systemName: "chart.line.uptrend.xyaxis")
                        Text("Statistics").font(.headline)
                    }
                }
            }
        }
    }  
}

#Preview {
    MainMenu()
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
