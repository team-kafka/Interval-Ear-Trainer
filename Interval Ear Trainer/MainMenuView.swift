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
                Section(header: Text("Main Menu")) {
                        NavigationLink(destination: PracticeView().navigationBarBackButtonHidden(true)){
                            Text("Recognize intervals - Practice Mode").font(.headline)
                        }
                }.navigationTitle(Text("Interval Ear Trainer"))
            }
        }
        }
    }

#Preview {
    MainMenu()
}
