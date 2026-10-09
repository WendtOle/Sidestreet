//
//  SoundController.swift
//  WalkTracker
//
//  Created by Ole on 08.10.26.
//

import AVFAudio
import Combine

class SoundController: ObservableObject {
    @Published var isRunning: Bool = false
    var soundEffect: AVAudioPlayer?
    var soundTimer: Timer?
    var beepInterval: Double = 0.2
    
    
    init() {
        let path = Bundle.main.path(forResource: "sound.wav", ofType:nil)!
        let url = URL(fileURLWithPath: path)
        do {
            soundEffect = try AVAudioPlayer(contentsOf: url)
        } catch {
            
        }
    }
    
    deinit {
        soundTimer?.invalidate()
    }
    
    func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default, options: .mixWithOthers)
        } catch {
            print("Failed to set the audio session configuration", error)
        }
    }
    
    func setBeepInterval (interval: Double) {
        beepInterval = max(0.20, interval)
    }
    
    func start() {
        if soundTimer?.isValid == true {
            return
        }
        isRunning = true
        self.configureAudioSession()
        self.scheduleNextBeep()
    }
    
    func scheduleNextBeep () {
        soundTimer?.invalidate()
        
        let nextTimer = Timer.scheduledTimer(withTimeInterval: beepInterval, repeats: false, block: { [weak self] _ in
            guard let self else { return }

            self.soundEffect?.pause()
            self.soundEffect?.currentTime = 0
            self.soundEffect?.play()
            self.scheduleNextBeep()
        })
        
        soundTimer = nextTimer
    }
    
    func stop() {
        isRunning = false
        soundTimer?.invalidate()
        
    }
}
