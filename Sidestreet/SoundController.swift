import AVFAudio
import Combine
import CoreLocation
import Observation

protocol Player {
    var isRunning: Bool {get}
    func start() -> Void
    func stop() -> Void
}

@Observable
@MainActor
final class SoundController: ObservableObject, Player {
    private(set) var isRunning = false

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()

    private var beepBuffer: AVAudioPCMBuffer?
    private(set) var beepInterval: Double = 15.0

    private enum AudioError: Error {
        case missingSound
        case invalidSound
        case invalidInterval
        case bufferCreationFailed
    }

    init() {
        do {
            guard let url = Bundle.main.url(
                forResource: "sound",
                withExtension: "wav"
            ) else {
                throw AudioError.missingSound
            }

            // Use non-interleaved Float samples for copying.
            let file = try AVAudioFile(
                forReading: url,
                commonFormat: .pcmFormatFloat32,
                interleaved: false
            )

            guard file.length > 0,
                  file.length <= AVAudioFramePosition(
                    AVAudioFrameCount.max
                  ),
                  let buffer = AVAudioPCMBuffer(
                    pcmFormat: file.processingFormat,
                    frameCapacity: AVAudioFrameCount(file.length)
                  ) else {
                throw AudioError.invalidSound
            }

            try file.read(into: buffer)

            guard buffer.frameLength > 0 else {
                throw AudioError.invalidSound
            }

            beepBuffer = buffer

            engine.attach(player)
            engine.connect(
                player,
                to: engine.mainMixerNode,
                format: buffer.format
            )
        } catch {
            print("Failed to load beep:", error)
        }
    }

    private func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()

        try session.setCategory(
            .playback,
            mode: .default,
            options: .mixWithOthers
        )

        try session.setActive(true)
    }

    // Build one complete cycle: beep + silence.
    private func makeLoopBuffer(
        interval: Double
    ) throws -> AVAudioPCMBuffer {
        guard let beepBuffer,
              let source = beepBuffer.floatChannelData else {
            throw AudioError.invalidSound
        }

        let frameCount = (
            interval * beepBuffer.format.sampleRate
        ).rounded()

        guard frameCount.isFinite,
              frameCount >= 1,
              frameCount <= Double(AVAudioFrameCount.max) else {
            throw AudioError.invalidInterval
        }

        let frames = AVAudioFrameCount(frameCount)

        guard let loop = AVAudioPCMBuffer(
            pcmFormat: beepBuffer.format,
            frameCapacity: frames
        ) else {
            throw AudioError.bufferCreationFailed
        }

        loop.frameLength = frames

        guard let destination = loop.floatChannelData else {
            throw AudioError.bufferCreationFailed
        }

        let copiedFrames = Int(
            min(beepBuffer.frameLength, frames)
        )

        for channel in 0..<Int(beepBuffer.format.channelCount) {
            // Fill the entire cycle with silence.
            destination[channel].update(
                repeating: 0,
                count: Int(frames)
            )

            // Put the beep at the beginning.
            destination[channel].update(
                from: source[channel],
                count: copiedFrames
            )
        }

        return loop
    }

    func setBeepInterval(interval: Double) {
        guard interval.isFinite else { return }

        let newInterval = max(0.20, interval)
        guard newInterval != beepInterval else { return }

        if isRunning {
            do {
                // Build before stopping the current loop.
                let loop = try makeLoopBuffer(
                    interval: newInterval
                )

                player.scheduleBuffer(
                    loop,
                    at: nil,
                    options: [.interruptsAtLoop, .loops],
                    completionHandler: nil
                )
            } catch {
                print("Failed to change beep interval:", error)
                return
            }
        }

        beepInterval = newInterval
    }

    func setBeepIntervalByDistance(
        distance: CLLocationDistance
    ) {
        guard distance.isFinite, distance >= 0 else { return }

        let interval: Double

        switch distance {
        case 500...:
            interval = 4 + (distance - 500) / 50

        case 200..<500:
            interval = 2 + (distance - 200) / 150

        case 100..<200:
            interval = 1 + (distance - 100) / 100

        case 50..<100:
            interval = 0.5 + (distance - 50) / 100

        default:
            interval = 0.25 + distance / 200
        }

        setBeepInterval(interval: interval)
    }

    func start() {
        guard !isRunning else { return }

        do {
            let loop = try makeLoopBuffer(
                interval: beepInterval
            )

            try configureAudioSession()

            engine.prepare()
            try engine.start()

            player.scheduleBuffer(
                loop,
                at: nil,
                options: .loops,
                completionHandler: nil
            )
            player.play()

            isRunning = true
        } catch {
            player.stop()
            engine.stop()
            print("Failed to start audio:", error)
        }
    }

    func stop() {
        player.stop()
        engine.stop()
        isRunning = false
    }
}
