import AppIntents

struct ToggleTrackingSoundIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Toggle tracking sound"

    static var supportedModes: IntentModes { .background }

    static var authenticationPolicy: IntentAuthenticationPolicy {
        .alwaysAllowed
    }
    
    #if SIDESTREET_APP
    @Dependency private var soundController: SoundController
    #endif

    
    @MainActor
    func perform() async throws -> some IntentResult {
        #if SIDESTREET_APP
        if soundController.isRunning {
            soundController.stop()
        } else {
            soundController.start()
        }
        #endif

        return .result()
    }
}
