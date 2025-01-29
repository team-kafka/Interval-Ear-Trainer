//
//  InfoView.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2025/01/27.
//

import SwiftUI

let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

struct InfoView: View {
    var body: some View {
        NavigationView{
            List{
                Section(header: Text("Interval Ear Trainer")) {
                    HStack{
                        Text("App Version:")
                        Spacer()
                        Text(appVersion!)
                    }
                    HStack{
                        Text("Feedback:")
                        Spacer()
                        Text("dev@team_kafka")
                    }
                }
            }
        }.toolbarRole(.editor)
    }
}
