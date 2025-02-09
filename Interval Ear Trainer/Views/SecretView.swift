//
//  SecretView.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2025/02/05.
//

import SwiftUI

struct SecretView: View {
    @ObservedObject var displayMgr: DisplayMgr = DisplayMgr()
    
    var body: some View {
        VStack {
            //Color.teal.ignoresSafeArea()
            Image( displayMgr.show2 ? "ETP2" :"ETP").resizable().scaledToFit().padding(.top, 100)
            Spacer()
        }.background(Color.teal)
            .onAppear {
            }
    }


}

@Observable class DisplayMgr : ObservableObject{
    var show2: Bool = false
    private var timer: Timer?
    
    init() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.7, repeats: true) { _ in self.show2.toggle() }
    }
}
#Preview {
    SecretView()
}
