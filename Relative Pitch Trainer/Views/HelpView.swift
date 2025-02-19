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
            content.presentationCompactAdaptation(.none).preferredColorScheme(.dark)
        }
    }
}

struct HelpListeningPOView: View {
    var body: some View {
        VStack(alignment: .leading)
        {
            Text("Play a stream of random intervals, chords, or ").textCase(.none)
            Text("degrees, for passive studying").textCase(.none)
            Text("Use device controls to pause/resume").textCase(.none)
        }.padding()
    }
}

struct HelpListeningIntervalsPOView: View {
    var body: some View {
        VStack(alignment: .leading)
        {
            Text("Play random intervals").textCase(.none)
            HStack(spacing:3){
                Image(systemName: "00.square.hi")
                Text(": Melodic intervals")
            }
            HStack(spacing:3){
                Image(systemName: "00.square.hi").rotationEffect(.init(degrees: 90))
                Text(": Harmonic intervals")
            }
            HStack{
                Text("Use").textCase(.none)
                Image(systemName: "backward")
                Image(systemName: "forward")
                Text("to cycle players").textCase(.none)
            }
        }.padding()
    }
}

struct HelpListeningIntervalComparisonPOView: View {
    var body: some View {
        VStack(alignment: .leading)
        {
            Text("Select a random note and play all selected\n intervals starting with that note").textCase(.none)
            HStack{
                Image(systemName: "shuffle.circle")
                Text(": Play intervals in ascending order")
            }
            HStack{
                Image(systemName: "shuffle.circle.fill")
                Text(": Play intervals in random order")
            }
            HStack{
                Image(systemName: "00.square.hi")
                Text(": Melodic intervals")
            }
            HStack{
                Image(systemName: "00.square.hi").rotationEffect(.init(degrees: 90))
                Text(": Harmonic intervals")
            }
        }.padding()
    }
}

struct HelpListeningTriadPOView: View {
    var body: some View {
        VStack(alignment: .leading)
        {
            Text("Play stream of triads with random root, random voicing and random chord quality").textCase(.none)
            HStack{
                Image(systemName: "00.square.hi")
                Text(": Play notes sequentially")
            }
            HStack{
                Image(systemName: "00.square.hi").rotationEffect(.init(degrees: 90))
                Text(": Play as a chord")
            }
        }.padding()
    }
}

struct HelpListeningScaleDegreePOView: View {
    var body: some View {
        VStack(alignment: .leading)
        {
            Text("Play random degrees from the selected scale and key").textCase(.none)
            HStack{
                Image(systemName: "die.face.5")
                Text(": Pick a random key")
            }
            HStack{
                Image(systemName: "n.square")
                Text(": Play sequences of N notes")
            }
        }.padding()
    }
}

struct HelpTextView: View {
    var text: String = "Help text"
    var body: some View {
        VStack(alignment: .leading){
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
                    Text("Test mode:")
                }
                HStack{
                    Image(systemName:"clock").opacity(0.0)
                    Text("- limited time to answer")
                }
                HStack{
                    Image(systemName:"clock").opacity(0.0)
                    Text("(adjustable in settings)")
                }
                HStack{
                    Image(systemName:"clock").opacity(0.0)
                    Text("- results are saved to usage stats")
                }

                HStack{
                    Image(systemName:"infinity.circle")
                    Text("Practice mode:").textCase(.none)
                }
                HStack{
                    Image(systemName:"figure.walk.treadmill.circle").opacity(0.0)
                    Text("- infinite time to answer").textCase(.none)
                }
                HStack{
                    Image(systemName:"figure.walk.treadmill.circle").opacity(0.0)
                    Text("- sequences can be replayed").textCase(.none)
                }
                HStack{
                    Image(systemName:"figure.walk.treadmill.circle").opacity(0.0)
                    Text("- results are not saved to usage stats").textCase(.none)
                }
            }
        }.padding()
    }
}

struct HelpNotesPOView: View {
    var body: some View {
        VStack(alignment: .leading)
        {
            HStack{
                Text("replay the current sequence")
            }
        }.padding()
    }
}

struct HelpQuizChartPOView: View {
    var body: some View {
        VStack(alignment: .leading)
        {
            Text("Quiz results, grouped by day or by type").textCase(.none).font(.footnote).padding(.bottom, 3)
            Text("Tap and hold the bottom graph to filter ").textCase(.none).font(.footnote)
            HStack{
                PercentButtonView()
                Text("Display results as percentages").textCase(.none).font(.footnote)
            }
        }.padding()
    }
}

struct HelpListeningChartPOView: View {
    var body: some View {
        VStack(alignment: .leading)
        {
            Text("The number of sequences played in listening mode,").textCase(.none).font(.footnote).padding(.bottom, 3)
            Text("grouped by type or by day").textCase(.none).font(.footnote).padding(.bottom, 3)
            Text("Tap and hold the bottom graph to filter").textCase(.none).font(.footnote)
        }.padding()
    }
}

#Preview {
    HelpMarkView{ HelpListeningIntervalsPOView() }.environment(\.colorScheme, .dark)
}
