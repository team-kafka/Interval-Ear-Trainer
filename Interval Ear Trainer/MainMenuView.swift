//
//  MainMenu.swift
//  My First App
//
//  Created by Nicolas on 2024/12/10.
//

import SwiftUI


struct MainMenu: View {
    //@AppStorage("dftFilter") var dftFilter: [Int] = [-1, 2, 3]
    @AppStorage("dftFilter") var dftDelay: Double = 4.1

    var body: some View {
        NavigationStack{
            List{
                Section(header: Text("Practice")) {
                    NavigationLink(destination: IntervalPracticeView().navigationBarBackButtonHidden(true)){
                        Text("Interval Recognition").font(.headline)
                    }
                }.navigationTitle(Text("Interval Ear Trainer"))
                Section(header: Text("Quizz")) {
                    NavigationLink(destination: IntervalQuizzView().navigationBarBackButtonHidden(true)){
                        Text("Interval Recognition").font(.headline)
                    }
                }
                let dftFilter: [Int] = [-1, 2, 3]
                //let dftDelay: Double = 4.0
                
                let dftParams = IntervalParameters(upper_bound: 107,
                                               lower_bound: 64,
                                               active_intervals: Set<Int>(dftFilter),
                                               delay: dftDelay,
                                               delay_sequence: 0.8,
                                               largeIntevalsProba: 0.0)
                Section(header: Text("Passive Listening")) {
                    IntervalListeningView(params:dftParams)
                    IntervalListeningView(params:IntervalParameters.init_value_passive2)
                    IntervalListeningView(params:IntervalParameters.init_value_passive3)
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
