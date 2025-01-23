//
//  LIsteningModePlayer.swift
//  Interval Ear Trainer
//
//  Created by Nicolas Carre on 2025/01/06.
//

import Foundation
import MediaPlayer
import SwiftUI


let ANSWER_TIME = 0.8 // how long does the answer shows before moving on to the next question


@Observable class SequencePlayer{
    static let shared = SequencePlayer()
    
    // State variables
    var playing: Bool
    var notes: [Int]
    var answers: [String]
    var answerVisible: Double
    var rootNote: Int
    
    @ObservationIgnored() private var timer: Timer?
    @ObservationIgnored() private var timerAnswer: Timer?
    @ObservationIgnored() private var seqGen: SequenceGenerator!
    @ObservationIgnored() private var params: Parameters!
    @ObservationIgnored() private var owner: String?
    @ObservationIgnored() private var cacheData: [String: Int]

    private init() {
        self.timer = nil
        self.timerAnswer = nil
        self.playing = false
        self.notes = [0]
        self.rootNote = 0
        self.cacheData = [:]
        self.seqGen = nil
        self.params = nil
        self.answers = []
        self.answerVisible = 1

        setupNowPlaying()
        setupRemoteTransportControls()
        setupNotifications()
    }
    
    func setParameters(_ params: Parameters) {
        self.params = params
        if (params.type == .interval) {
            self.seqGen = IntervalGenerator()
        } else if (params.type == .triad){
            self.seqGen = TriadGenerator()
        } else {
            self.seqGen = ScaleDegreeGenerator()
        }
    }
    func setOwner(_ id: String) { self.owner = id }
    func getOwner() -> String? { return self.owner }
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

    func setupNowPlaying() {
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = short_answer(answer:answers.joined(separator: " "))

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
            artist_info += params.generateLabelString()
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
    
    func setAVSession(active:Bool){
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(active)
        } catch let error as NSError {
            print("Failed (de)activate the audio session: \(error.localizedDescription)")
        }
    }

    func start() -> Bool {
        if (seqGen != nil && params != nil) {
            setAVSession(active: true)
            playing = true
            setupNowPlaying()
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
        MidiPlayer.shared.stop()
        self.setAVSession(active: false)
        self.playing = false
        setupNowPlaying()
        timer?.invalidate()
        timerAnswer?.invalidate()
    }
    
    func step(){
        if (seqGen != nil && params != nil && !playing) {
            if answerVisible == 1.0 {
                answerVisible = 0.0
                setAVSession(active: true)
                let seq_duration = play_sequence()
                timer = Timer.scheduledTimer(withTimeInterval:seq_duration + params.delay_sequence + 0.1, repeats: false) { t in
                    self.setAVSession(active: false)
                }
            } else {
                answerVisible = 1.0
            }
        }
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
        setupNowPlaying()
        MidiPlayer.shared.playNotes(notes: params.n_notes == 1 ? [notes.last!] : notes, duration: note_duration, chord: params.is_chord)
        update_cacheData(answers:answers)
        return seq_duration
    }
    
    func update_cacheData(answers:[String]) {
        for ans in answers{
            if !cacheData.keys.contains(ans){
                cacheData[ans] = 0
            }
            cacheData[ans]! += 1
        }
    }
    
    func resetState(params: Parameters) {
        self.answers = []
        self.answerVisible = 1
        let note_size = (params.type == .interval) ? max(self.params.n_notes, 2) : self.params.n_notes
        self.notes = [Int].init(repeating: 0, count: note_size)
    }
}
