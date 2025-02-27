//
//  LIsteningModePlayer.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2025/01/06.
//

import Foundation
import MediaPlayer
import SwiftUI
import AVFoundation

let ANSWER_TIME = 0.8 // (s) how long does the answer shows before moving on to the next question

@Observable class SequencePlayer{
    static let shared = SequencePlayer()
        
    // State variables
    var playing: Bool
    var notes: [Int]
    var answers: [String]
    var answerVisible: Double
    var rootNote: Int
    var owner: String?

    @ObservationIgnored() private var timer: Timer?
    @ObservationIgnored() private var timerAnswer: Timer?
    @ObservationIgnored() private var seqGen: SequenceGenerator!
    var params: Parameters!

    private init() {
        self.timer = nil
        self.timerAnswer = nil
        self.playing = false
        self.notes = [0]
        self.rootNote = 0
        self.seqGen = nil
        self.params = nil
        self.answers = []
        self.answerVisible = 1
        setupRemoteTransportControls()
        setupNotifications()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setParameters(_ params: Parameters) {
        if (self.params == nil) || (params.type != self.params.type) {
            if (params.type == .interval) {
                self.seqGen = IntervalGenerator()
            } else if (params.type == .triad){
                self.seqGen = TriadGenerator()
            } else {
                self.seqGen = ScaleDegreeGenerator()
            }
        }
        self.params = params
        updateNowPlaying()
    }
    
    func setOwner(_ id: String) { self.owner = id }
    
    // *************************
    // Main interface
    // *************************
    func start() -> Bool {
        if (seqGen != nil && params != nil) {
            setAVSession(active: true)
            updateNowPlaying()
            playing = true
            updateNowPlaying()
            timer?.invalidate()
            if (params.type == .scale_degree && notes[0] == 0) {
                MidiPlayer.shared.playNotes(notes: scale_notes(scale: params.scale, key: params.key, upper_bound: params.upper_bound, lower_bound: params.lower_bound), duration:SCALE_DELAY)
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
        timer?.invalidate()
        timerAnswer?.invalidate()
        MidiPlayer.shared.stop()
        self.setAVSession(active: false)
        self.playing = false
        updateNowPlaying()
    }
 
    func loopFunction() {
        timer?.invalidate()
        if answerVisible == 1.0 {
            answerVisible = 0.0
            let seq_duration = play_sequence()
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval:params.delay + seq_duration + ANSWER_TIME, repeats: false) { _ in self.loopFunction() }
            timerAnswer?.invalidate()
            timerAnswer = Timer.scheduledTimer(withTimeInterval:params.delay + seq_duration, repeats: false) { _ in self.answerVisible = 1.0 }
        } else {
            answerVisible = 1.0
            timer = Timer.scheduledTimer(withTimeInterval:ANSWER_TIME, repeats: false) { _ in self.loopFunction() }
        }
    }
    
    func play_sequence() -> Double {
        var seq_duration: Double
        var note_duration: Double
        let prev_note = params.n_notes == 1 ? notes.last ?? 0 : notes.first ?? 0
        (notes, note_duration, seq_duration, answers, rootNote) = seqGen.generateSequence(params: params, n_notes:params.n_notes, chord:params.is_chord,  prev_note:prev_note)
        updateNowPlaying()
        let notesToPlay = (params.n_notes == 1 && prev_note != 0) ? [notes.last!] : notes
        MidiPlayer.shared.playNotes(notes: notesToPlay, duration: note_duration, chord: params.is_chord)
        return seq_duration
    }
    
    func step(){
        if (seqGen != nil && params != nil && !playing) {
            if answerVisible == 1.0 {
                answerVisible = 0.0
                _ = play_sequence()
            } else {
                answerVisible = 1.0
            }
        }
    }

    func resetState(params: Parameters) {
        self.answers = []
        self.answerVisible = 1
        let note_size = (params.type == .interval) ? max(self.params.n_notes, 2) : self.params.n_notes
        self.notes = [Int].init(repeating: 0, count: note_size)
    }

    func playGuessNotes(guesses: [String], answers: [String]) {
        let notesToPlay: [Int] = seqGen.generateGuessNotes(notes: notes, guesses: guesses, answers: answers)
        MidiPlayer.shared.playNotes(notes: notesToPlay, duration: params.delay_sequence, chord: params.is_chord)
    }
    
    // *************************
    // I/O management related
    // *************************
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
        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            return self.changeTrack(delta: 1)
        }
        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            return self.changeTrack(delta: -1)
        }
    }

    func changeTrack(delta: Int) -> MPRemoteCommandHandlerStatus {
        let idx = INTERVAL_LISTENING_IDS.firstIndex(of: self.owner ?? "")
        if idx != nil {
            let nextIdx = (idx! + delta) % INTERVAL_LISTENING_IDS.count
            let nextIdxPos = nextIdx < 0 ? INTERVAL_LISTENING_IDS.count + nextIdx : nextIdx
            self.setOwner(INTERVAL_LISTENING_IDS[nextIdxPos])
            return MPRemoteCommandHandlerStatus.success
        } else {
            return MPRemoteCommandHandlerStatus.commandFailed
        }
    }
    
    func updateNowPlaying() {
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = short_answer(answer:answers.joined(separator: " "))

        if let image = UIImage(named: "icon_hires") {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { size in
                return image
            }
        }
        if (seqGen != nil && params != nil) {
            var artist_info = switch (self.params.type) {
                case .interval      : "Intervals: "
                case .triad         : "Triads: "
                case .scale_degree  : "Scale Degrees: "
            }
            artist_info += params.generateLabelString()
            nowPlayingInfo[MPMediaItemPropertyArtist] = artist_info
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func releaseNowPlaying() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
    
    func setupNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(handleInterruption),
                                       name: AVAudioSession.interruptionNotification,
                                       object: nil)
        notificationCenter.addObserver(self,
                                           selector: #selector(handleRouteChange),
                                           name: AVAudioSession.routeChangeNotification,
                                           object: AVAudioSession.sharedInstance())
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
    
    @objc func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }
        switch reason {
        case .oldDeviceUnavailable:
            self.stop()
        default:
            print()
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
