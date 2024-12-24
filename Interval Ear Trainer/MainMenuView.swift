//
//  MainMenu.swift
//  My First App
//
//  Created by Nicolas on 2024/12/10.
//

import SwiftUI

struct MainMenu: View {
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
                Section(header: Text("Passive Listening")) {
                    IntervalListeningView(params:Parameters.init_value_passive1)
                    IntervalListeningView(params:Parameters.init_value_passive2)
                    IntervalListeningView(params:Parameters.init_value_passive3)
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
