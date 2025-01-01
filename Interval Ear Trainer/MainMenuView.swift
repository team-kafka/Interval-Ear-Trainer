//
//  MainMenu.swift
//  My First App
//
//  Created by Nicolas on 2024/12/10.
//

import SwiftUI


struct MainMenu: View {
    @AppStorage("dftDelayIP") var dftDelayIP: Double = 3.0
    @AppStorage("dftDelayIQ") var dftDelayIQ: Double = 3.0
    @AppStorage("dftFilterStrIQ") var dftFilterStrIQ: String = "3♭ 3"
    @AppStorage("dftFilterStrIP") var dftFilterStrIP: String = "3♭ 3"
    
    @AppStorage("dftDelayIL1") var dftDelayIL1: Double = 3.0
    @AppStorage("dftDelayIL2") var dftDelayIL2: Double = 3.0
    @AppStorage("dftDelayIL3") var dftDelayIL3: Double = 3.0
    @AppStorage("dftFilterStrIL1") var dftFilterStrIL1: String = "3♭ 3"
    @AppStorage("dftFilterStrIL2") var dftFilterStrIL2: String = "6♭↑ 6↑ 7♭↑ 7↑"
    @AppStorage("dftFilterStrIL3") var dftFilterStrIL3: String = "6♭↓ 6↓ 7♭↓ 7↓"

    @AppStorage("dftDelayTP") var dftDelayTP: Double = 3.0
    @AppStorage("dftDelayTQ") var dftDelayTQ: Double = 3.0
    @AppStorage("dftDelayTL") var dftDelayTL: Double = 3.0
    @AppStorage("dftFilterStrTQ") var dftFilterStrTQ: String = "Major/Minor/Diminished/Augmented/Lydian|Root position/1st inversion/2nd inversion|Close/Open"
    @AppStorage("dftFilterStrTP") var dftFilterStrTP: String = "Major/Minor/Diminished/Augmented/Lydian|Root position/1st inversion/2nd inversion|Close/Open"
    @AppStorage("dftFilterStrTS") var dftFilterStrTS: String = "Major/Minor/Diminished/Augmented/Lydian|Root position/1st inversion/2nd inversion|Close/Open"

    @AppStorage("dftDelaySP") var dftDelaySP: Double = 3.0
    @AppStorage("dftFilterStrSP") var dftFilterStrSP: String = "1 2 3 4 5 6 7"

    @AppStorage("dftDelaySL") var dftDelaySL: Double = 3.0
    @AppStorage("dftFilterStrSL") var dftFilterStrSL: String = "1 2 3 4 5 6 7"

    @AppStorage("dftDelaySQ") var dftDelaySQ: Double = 3.0
    @AppStorage("dftFilterStrSQ") var dftFilterStrSQ: String = "1 2 3 4 5 6 7"

    var body: some View {
        NavigationStack{
            List{
                Section(header: Text("Practice")) {
                    let paramsIP = Parameters(type:.interval, delay: dftDelayIP, active_intervals: str_to_interval_filter(filter_str: dftFilterStrIP))
                    NavigationLink(destination: PracticeView(params: paramsIP, dftDelay: $dftDelayIP, dftFilterStr: $dftFilterStrIP ).navigationBarBackButtonHidden(true)){
                            Text("Interval Recognition").font(.headline)
                        }
                    let filtersTP = triad_filters_from_str(filter_str: dftFilterStrTP)
                    let paramsTP = Parameters(type:.triad, delay: dftDelayTP, active_qualities: filtersTP.0, active_inversions: filtersTP.1, active_voicings: filtersTP.2)
                    NavigationLink(destination:
                                    PracticeView(params: paramsTP, dftDelay: $dftDelayTP, dftFilterStr: $dftFilterStrTP, n_notes:3,
                                                 fixed_n_notes:true, chord:true).navigationBarBackButtonHidden(true)){
                        Text("Triad Recognition").font(.headline)
                    }
                        let paramsSP = Parameters(type:.scale_degree, delay: dftDelaySP, active_scale_degrees: str_to_scale_degree_filter(filter_str: dftFilterStrSP))
                        NavigationLink(destination:
                                        PracticeView(params: paramsSP, dftDelay: $dftDelaySP, dftFilterStr: $dftFilterStrSP, n_notes:1, chord_active: false).navigationBarBackButtonHidden(true)){
                            Text("Scale Degree Recognition").font(.headline)

                    }
                }.navigationTitle(Text("Interval Ear Trainer"))
                Section(header: Text("Quiz")) {
                    let paramsIQ = Parameters(type:.interval, delay: dftDelayIQ, active_intervals: str_to_interval_filter(filter_str: dftFilterStrIQ))
                    NavigationLink(destination: QuizView(params: paramsIQ, dftDelay: $dftDelayIQ, dftFilterStr: $dftFilterStrIQ).navigationBarBackButtonHidden(true)){
                        Text("Interval Recognition").font(.headline)
                    }
                    let filtersTQ = triad_filters_from_str(filter_str: dftFilterStrTQ)
                    let paramsTQ = Parameters(type: .triad, delay: dftDelayTQ, active_qualities: filtersTQ.0, active_inversions: filtersTQ.1, active_voicings: filtersTQ.2)
                    NavigationLink(destination: QuizView(params: paramsTQ, dftDelay: $dftDelayTQ, dftFilterStr: $dftFilterStrTQ, n_notes:3,
                                                         fixed_n_notes:true, chord: true).navigationBarBackButtonHidden(true)){
                        Text("Triad Recognition").font(.headline)
                    }
                    let paramsSQ = Parameters(type: .scale_degree, delay: dftDelaySQ, active_scale_degrees: str_to_scale_degree_filter(filter_str: dftFilterStrSQ))
                    NavigationLink(destination: QuizView(params: paramsSQ, dftDelay: $dftDelaySQ, dftFilterStr: $dftFilterStrSQ, n_notes:1, chord_active: false).navigationBarBackButtonHidden(true)){
                        Text("Scale Degree Recognition").font(.headline)
                    }
                }
                Section(header: Text("Passive Listening")) {
                    let paramsIL1 = Parameters(type:.interval, delay: dftDelayIL1, active_intervals: str_to_interval_filter(filter_str: dftFilterStrIL1))
                    ListeningView(params:paramsIL1, sequenceGenerator: IntervalGenerator(), chord:false, dftDelay: $dftDelayIL1, dftFilterStr: $dftFilterStrIL1)
                    
                    let paramsIL2 = Parameters(type:.interval, delay: dftDelayIL2, active_intervals: str_to_interval_filter(filter_str: dftFilterStrIL2))
                    ListeningView(params:paramsIL2, sequenceGenerator: IntervalGenerator(), chord:false, dftDelay: $dftDelayIL2, dftFilterStr: $dftFilterStrIL2)
                    
                    let paramsIL3 = Parameters(type:.interval, delay: dftDelayIL3, active_intervals: str_to_interval_filter(filter_str: dftFilterStrIL3))
                    ListeningView(params: paramsIL3, sequenceGenerator: IntervalGenerator(), chord:false, dftDelay: $dftDelayIL3, dftFilterStr: $dftFilterStrIL3)
                    
                    let filtersTL = triad_filters_from_str(filter_str: dftFilterStrTS)
                    let dftParamsTL = Parameters(type: .triad,
                        delay: dftDelayTQ, active_qualities: filtersTL.0, active_inversions: filtersTL.1, active_voicings: filtersTL.2)
                    ListeningView(params: dftParamsTL, sequenceGenerator: TriadGenerator(), dftDelay: $dftDelayTL, dftFilterStr: $dftFilterStrTS)
               
//                let dftParamsSL = Parameters(type: .scale_degree,
//                    delay: dftDelaySL, active_scale_degrees: str_to_scale_degree_filter(filter_str: dftFilterStrSL))
//                ListeningView(params: dftParamsSL, sequenceGenerator: ScaleDegreeGenerator(), dftDelay: $dftDelaySL, dftFilterStr: $dftFilterStrSL)
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
