//
//  HelpPopupView.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2025/01/29.
//

import SwiftUI

struct HelpMarkView<Content: View>: View {
    var opacity: Double = 0.3
    @State var showingPopover = false
    @ViewBuilder let content: Content
    
    var body: some View {
        Image(systemName: "questionmark.circle").opacity(opacity)
        .onTapGesture {
            self.showingPopover.toggle()
        }
        .popover(isPresented: $showingPopover) {
            content.presentationCompactAdaptation(.none)
        }
    }
}

struct HelpListeningPOView: View {
    var body: some View {
        VStack(alignment: .leading)
        {
            Text("Play streams of random intervals, chords, or ").textCase(.none)
            Text("degrees, for passive studying.").textCase(.none)
            Text("Use device controls to pause/resume, ").textCase(.none)
            HStack{
                Text("and").textCase(.none)
                Image(systemName: "backward")
                Image(systemName: "forward")
                Text("to cycle interval players").textCase(.none)
            }
        }.padding()
    }
}

struct HelpTextView: View {
    var text: String = "Help text"
    var body: some View {
        VStack(alignment: .leading)
        {
            Text(text).textCase(.none)
        }.padding()
    }
}


struct HelpQuizPOView: View {
    var body: some View {
        VStack(alignment: .leading)
        {
            Text("Recognize intervals, chords and degrees").textCase(.none)
            HStack{
                Text("Scores are saved in the stats page").textCase(.none)
                Image(systemName: "chart.line.uptrend.xyaxis")
            }
            

        }.padding()
    }
}

struct HelpChordPOView: View {
    var body: some View {
        VStack(alignment: .leading)
        {
            HStack{
                Image(systemName:"00.square.hi").rotationEffect(Angle(degrees: 0))
                Text("Play notes in succession").textCase(.none)
            }
            HStack{
                Image(systemName:"00.square.hi").rotationEffect(Angle(degrees: 90))
                Text("Play notes as a chord").textCase(.none)
            }
        }.padding()
    }
}

struct HelpNNotesPOView: View {
    var body: some View {
        VStack(alignment: .leading)
        {
            HStack{
                Text("Play sequences of"); Image(systemName: "n.square"); Text("notes").textCase(.none)
            }
        }.padding()
    }
}

struct HelpTimerPOView: View {
    var body: some View {
        VStack(alignment: .leading)
        {
            VStack(alignment: .leading){
                HStack{
                    Image(systemName:"clock")
                    
                    Text("Play a new sequence after a set")
                }
                HStack{
                    Image(systemName:"clock").opacity(0.0)
                    Text("time interval (in settings)")
                }
            }
            HStack{
               // Text("Delay can be adjusted in settings").textCase(.none)
            }
            HStack{
                Image(systemName:"infinity.circle")
                Text("Wait for user input").textCase(.none)
            }
        }.padding()
    }
}

struct HelpNotesPOView: View {
    var body: some View {
        VStack(alignment: .leading)
        {
            HStack{
                Text("replay notes of the previous sequence")
            }
        }.padding()
    }
}


#Preview {
    HelpMarkView{ HelpTimerPOView() }
}
