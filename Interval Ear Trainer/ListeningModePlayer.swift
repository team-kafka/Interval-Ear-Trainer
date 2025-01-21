//
//  LIsteningModePlayer.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2025/01/06.
//

import Foundation
import MediaPlayer
import SwiftUI

@Observable class ListeningModePlayer{
    
    var cacheData: [String: Int]
    static let player = MidiPlayer()
    var timer: Timer?
    var playing: Bool
    var notes: [Int]
    
    var seqGen: SequenceGenerator!
    var params: Parameters!
    var owner: String?
    
    init() {
        self.timer = nil
        self.playing = false
        self.notes = [0]
        self.cacheData = [:]
        self.seqGen = nil
        self.params = nil
        
        setupNowPlaying(info:"")
        setupRemoteTransportControls()
        setupNotifications()
    }
    
    func setSequenceGenerator(_ seqGen: SequenceGenerator) { self.seqGen = seqGen }
    func setParameters(_ params: Parameters) { self.params = params }
    func setOwner(_ id: String) { self.owner = id }
    func get_cacheData() -> [String:Int]{ return cacheData }
    func clear_cacheData() { cacheData = [:] }
    
    func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [unowned self] event in
            if !self.playing {
                let success = self.start()
                return success ? .success : .commandFailed
            }
            return .commandFailed
        }

        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.playing {
                self.stop()
                return .success
            }
            return .commandFailed
        }
    }

    func setupNowPlaying(info:String) {
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = info

        if let image = UIImage(named: AppIconProvider.appIcon()) {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { size in
                return image
            }
        }

        if (seqGen != nil && params != nil) {
            var artist_info = switch (self.params.type) {
                case .interval: "Intervals: "
                case .triad: "Triads: "
            case .scale_degree:  "Scale Degrees: "
            }
            artist_info += seqGen.generateLabelString(params: params)
            nowPlayingInfo[MPMediaItemPropertyArtist] = artist_info
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func setupNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(handleInterruption),
                                       name: AVAudioSession.interruptionNotification,
                                       object: nil)
    }

    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }
        if type == .began {
            self.stop()
        }
    }
    
    func start() -> Bool {
        if (seqGen != nil && params != nil) {
            setAVSession(active: true)
            playing = true
            setupNowPlaying(info:"")
            timer?.invalidate()
            if (params.type == .scale_degree) {
                ListeningModePlayer.player.playNotes(notes: scale_notes(scale: params.scale, key: params.key, upper_bound: params.upper_bound, lower_bound: params.lower_bound), duration:SCALE_DELAY)
                timer = Timer.scheduledTimer(withTimeInterval:SCALE_DELAY * 9, repeats: false) { t in
                    self.loopFunction()
                }
            } else {
                self.loopFunction()
            }
            return true
        } else {
            return false
        }
    }

    func stop(){
        self.setAVSession(active: false)
        self.playing = false
        setupNowPlaying(info:"")
        timer?.invalidate()
    }
    
    func loopFunction() {
        var total_delay = params.delay
        total_delay += play_sequence()
        timer = Timer.scheduledTimer(withTimeInterval:total_delay, repeats: false) { t in
            self.loopFunction()
        }
    }
    
    func play_sequence() -> Double {
        var delay: Double
        var duration: Double
        var new_notes: [Int]
        var answers: [String]
        
        (new_notes, duration, delay, answers, _) = seqGen.generateSequence(params: params, n_notes:params.n_notes, chord:params.is_chord,  prev_note:params.n_notes == 1 ? notes.last ?? 0 : notes.first ?? 0)
        setupNowPlaying(info:answers.joined(separator: " "))
        ListeningModePlayer.player.playNotes(notes: new_notes, duration: duration, chord: params.is_chord)
        notes = new_notes
        update_cacheData(answers:answers)
        return delay
    }
    
    func update_cacheData(answers:[String]) {
        for ans in answers{
            if !cacheData.keys.contains(ans){
                cacheData[ans] = 0
            }
            cacheData[ans]! += 1
        }
    }
    
    func setAVSession(active:Bool){
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(active)
        } catch let error as NSError {
            print("Failed (de)activate the audio session: \(error.localizedDescription)")
        }
    }
}
