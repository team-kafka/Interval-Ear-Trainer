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

    var body: some View {
        NavigationStack{
            List{
                let dftParamsIP = IntervalParameters(active_intervals: str_to_interval_filter(filter_str: dftFilterStrIP),
                                               delay: dftDelayIP)
                Section(header: Text("Practice")) {
                    NavigationLink(destination: IntervalPracticeView(params: dftParamsIP, dftDelay: $dftDelayIP, dftFilterStr: $dftFilterStrIP).navigationBarBackButtonHidden(true)){
                        Text("Interval Recognition").font(.headline)
                    }
                    let filtersTP = triad_filters_from_str(filter_str: dftFilterStrTP)
                    let dftParamsTP = TriadParameters(active_qualities: filtersTP.0, active_inversions: filtersTP.1, active_voicings: filtersTP.2, delay: dftDelayTP)
                    NavigationLink(destination:
                                    TriadPracticeView(params: dftParamsTP, dftDelay: $dftDelayTP, dftFilterStr: $dftFilterStrTP).navigationBarBackButtonHidden(true)){
                        Text("Triad Recognition").font(.headline)
                    }
                }.navigationTitle(Text("Interval Ear Trainer"))
                let dftParamsIQ = IntervalParameters(active_intervals: str_to_interval_filter(filter_str: dftFilterStrIQ),
                                               delay: dftDelayIQ)
                Section(header: Text("Quiz")) {
                    NavigationLink(destination: IntervalQuizView(params: dftParamsIQ, dftDelay: $dftDelayIQ, dftFilterStr: $dftFilterStrIQ).navigationBarBackButtonHidden(true)){
                        Text("Interval Recognition").font(.headline)
                    }
                    let filtersTQ = triad_filters_from_str(filter_str: dftFilterStrTQ)
                    let dftParamsTQ = TriadParameters(active_qualities: filtersTQ.0, active_inversions: filtersTQ.1, active_voicings: filtersTQ.2, delay: dftDelayTQ)
                    NavigationLink(destination: TriadQuizView(params: dftParamsTQ, dftDelay: $dftDelayTQ, dftFilterStr: $dftFilterStrTQ).navigationBarBackButtonHidden(true)){
                        Text("Triad Recognition").font(.headline)
                    }
                }
                Section(header: Text("Passive Listening")) {
                    let dftParamsIL1 = IntervalParameters(active_intervals: str_to_interval_filter(filter_str: dftFilterStrIL1),
                                                   delay: dftDelayIL1)
                    IntervalListeningView(params:dftParamsIL1, dftDelay: $dftDelayIL1, dftFilterStr: $dftFilterStrIL1)
                    let dftParamsIL2 = IntervalParameters(active_intervals: str_to_interval_filter(filter_str: dftFilterStrIL2),
                                                   delay: dftDelayIL2)
                    IntervalListeningView(params:dftParamsIL2, dftDelay: $dftDelayIL2, dftFilterStr: $dftFilterStrIL3)
                    let dftParamsIL3 = IntervalParameters(active_intervals: str_to_interval_filter(filter_str: dftFilterStrIL3),
                                                   delay: dftDelayIL3)
                    IntervalListeningView(params:dftParamsIL3, dftDelay: $dftDelayIL3, dftFilterStr: $dftFilterStrIL3)
                    let filtersTL = triad_filters_from_str(filter_str: dftFilterStrTS)
                    let dftParamsTL = TriadParameters(active_qualities: filtersTL.0, active_inversions: filtersTL.1, active_voicings: filtersTL.2, delay: dftDelayTQ)
                    TriadListeningView(params: dftParamsTL, dftDelay: $dftDelayTL, dftFilterStr: $dftFilterStrTS)
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
