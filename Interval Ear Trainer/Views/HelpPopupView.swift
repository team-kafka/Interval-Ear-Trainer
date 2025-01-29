//
//  HelpPopupView.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2025/01/29.
//

import SwiftUI

struct HelpMark: View {
    @State var showingPopover = false
    
    var body: some View {
        Image(systemName: "questionmark.circle")
        .onTapGesture {
            self.showingPopover.toggle()
        }
        .popover(isPresented: $showingPopover) {
            HelpPopoverMessage().presentationCompactAdaptation(.none)
        }
    }
}

struct HelpPopoverMessage: View {
    var body: some View {
        VStack(alignment: .leading)
        {
            Text("Use device's controls to pause/resume")
            HStack{
                Text("Use")
                Image(systemName: "forward")
                Text("to cycle interval players")
            }
        }.padding()
    }
}



#Preview {
    HelpMark()
}
