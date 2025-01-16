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
struct Interval_Ear_TrainerApp: App {
    
    init () {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSession.Category.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch let error as NSError {
            print("Failed to set the audio session category and mode: \(error.localizedDescription)")
        }

    }
    var body: some Scene {
        WindowGroup {
            MainMenu()
        }
    }
}

