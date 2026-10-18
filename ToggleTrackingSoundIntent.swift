//
//  TestActivityIntent.swift
//  WalkTracker
//
//  Created by Ole on 17.10.26.
//

import AppIntents

struct ToggleTrackingSoundIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Toggle tracking sound"

    static var supportedModes: IntentModes { .background }

    static var authenticationPolicy: IntentAuthenticationPolicy {
        .alwaysAllowed
    }
    
    #if WALKTRACKER_APP
    @Dependency private var soundController: SoundController
    #endif

    
    @MainActor
    func perform() async throws -> some IntentResult {
        #if WALKTRACKER_APP
        if soundController.isRunning {
            soundController.stop()
        } else {
            soundController.start()
        }
        #endif

        return .result()
    }
}
