//
//  MidiPlayer.swift
//  My First App
//
//  Created by Nicolas on 2024/12/06.
//

import Foundation
import AVFoundation

class MidiPlayer {
    var midiPlayer: AVMIDIPlayer?
    var bankURL: URL
    
    init() {
        guard let bankURL = Bundle.main.url(forResource: "Arnold___David_Classical_Piano", withExtension: "sf2") else {
            fatalError("\"Arnold___David_Classical_Piano.sf2\" file not found.")
        }
        self.bankURL = bankURL
    }
    
    func prepareSong(note:Int, duration:Double){
        var data: Unmanaged<CFData>?
        var musicSequence: MusicSequence?
        NewMusicSequence(&musicSequence)
        var musicNote = MIDINoteMessage(channel: 0,
                                        note: UInt8(note),
                                        velocity: 64,
                                        releaseVelocity: 0,
                                        duration: Float(duration))
        var track: MusicTrack?
        
        guard MusicSequenceNewTrack(musicSequence!, &track) == OSStatus(noErr) else {
            fatalError("Cannot add track")
        }
        guard MusicTrackNewMIDINoteEvent(track!, MusicTimeStamp(0), &musicNote) == OSStatus(noErr) else {
            fatalError("Cannot add Note")
        }
        guard MusicSequenceFileCreateData(musicSequence!,
                                          MusicSequenceFileTypeID.midiType,
                                          MusicSequenceFileFlags.eraseFile,
                                          480, &data) == OSStatus(noErr) else {
            fatalError("Cannot create music midi data")
        }
        
        if let md = data {
            let midiData = md.takeUnretainedValue() as Data
            do {
                try self.midiPlayer = AVMIDIPlayer(data: midiData, soundBankURL: self.bankURL)
            } catch let error {
                fatalError(error.localizedDescription)
            }
        }
        self.midiPlayer!.prepareToPlay()
    }
    
    func playSong() {
        if let md = self.midiPlayer {
            md.currentPosition = 0
            md.play()
        }
    }
    func playNote(note:Int, duration: Double){
        self.prepareSong(note: note, duration:duration)
        self.playSong()
    }
    
}
