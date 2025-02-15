//
//  Interval_Ear_TrainerApp.swift
//  Interval Ear Trainer
//
//  Created by Nicolas on 2024/12/10.
//

import SwiftUI
import SwiftData
import AVFoundation

@main
struct Relative_Pitch_TrainerApp: App {
    
    init () {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
        } catch let error as NSError {
            print("Failed to set the audio session category and mode: \(error.localizedDescription)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainMenu().modelContainer(for: HistoricalData.self)
        }
    }
}

struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}
