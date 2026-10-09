//
//  SoundController.swift
//  WalkTracker
//
//  Created by Ole on 08.10.26.
//

import AVFAudio
import Combine
import CoreLocation

class SoundController: ObservableObject {
    @Published var isRunning: Bool = false
    var soundEffect: AVAudioPlayer?
    var soundTimer: Timer?
    var beepInterval: Double?
    
    
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
    
    func setBeepIntervalByDistance (distance: CLLocationDistance) {
        switch distance {
        case 500...:
            self.beepInterval = 4 + max(0,(distance - 500) / 50)

        case 200..<500:
            self.beepInterval = 2 + max(0, (distance - 200) / 150)

        case 100..<200:
            self.beepInterval = 1 + max(0, (distance - 100) / 100)

        case 50..<100:
            self.beepInterval = 0.5 + (max(0,(distance - 50) / 100))

        case 0..<50:
            self.beepInterval = 0.25 + (max(0,distance / 200))
            
        default:
            break // Ungültige Entfernung
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
        
        let nextTimer = Timer.scheduledTimer(withTimeInterval: beepInterval ?? 15, repeats: false, block: { [weak self] _ in
            guard let self else { return }

            if beepInterval != nil {
                self.soundEffect?.pause()
                self.soundEffect?.currentTime = 0
                self.soundEffect?.play()
            }
            self.scheduleNextBeep()
        })
        
        soundTimer = nextTimer
    }
    
    func stop() {
        isRunning = false
        soundTimer?.invalidate()
        
    }
}
