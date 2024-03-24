//
//  AudioPlayer.swift
//  LRCMusicPlayer
//
//  Created by 李京 on 2024/3/22.
//

import AVFoundation

class AudioPlayer {
    private var audioEngine: AVAudioEngine
    private var audioPlayerNode: AVAudioPlayerNode
    private var pitchControl: AVAudioUnitTimePitch
    private var audioFile: AVAudioFile?
    private var audioFileURL: URL?
    private var volumeRampTimer: Timer?
    private let volumeRampStep: Float = 0.08
    private let rampInterval: TimeInterval = 0.05
    private var currentPlaybackTime: TimeInterval = 0
    
    static let shared = AudioPlayer()


    init() {
        audioEngine = AVAudioEngine()
        audioPlayerNode = AVAudioPlayerNode()
        pitchControl = AVAudioUnitTimePitch()

        audioEngine.attach(audioPlayerNode)
        audioEngine.attach(pitchControl)

        audioEngine.connect(audioPlayerNode, to: pitchControl, format: nil)
        audioEngine.connect(pitchControl, to: audioEngine.mainMixerNode, format: nil)
        
        if (audioFileURL != nil) {
            do {
                audioFile = try AVAudioFile(forReading: audioFileURL!)
                print("File loaded successfully")
            } catch {
                print("Failed to load file: \(error)")
            }
        }
    }

    func loadFile(from path: URL) {
        if (audioFile != nil) {
            reset()
        }
        do {
            audioFileURL = path
            audioFile = try AVAudioFile(forReading: audioFileURL!)
            print("File loaded successfully")
        } catch {
            print("Failed to load file: \(error)")
        }
    }

    func play() {
        guard let audioFile = audioFile else { return }
        
        try? audioEngine.start()
        audioPlayerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
        fadeIn()
    }

    func pause() {
        fadeOut { [weak self] in
            self?.audioPlayerNode.pause()
        }
    }

    func resume() {
        try? audioEngine.start()
        fadeIn()
    }

    func stop() {
        fadeOut { [weak self] in
            self?.audioPlayerNode.stop()
            self?.audioEngine.stop()
        }
    }

    func setPitch(_ pitch: Float) {
        pitchControl.pitch = pitch
    }

    func seek(to time: TimeInterval) {
        guard let audioFile = audioFile else { return }
        
        currentPlaybackTime = time
        
        let sampleRate = audioFile.processingFormat.sampleRate
        let framePosition = AVAudioFramePosition(time * sampleRate)
        audioPlayerNode.stop()
        
        audioPlayerNode.scheduleSegment(audioFile, startingFrame: framePosition, frameCount: AVAudioFrameCount(audioFile.length - framePosition), at: nil, completionHandler: nil)
        audioPlayerNode.play()
    }

    var songInfo: (duration: TimeInterval, sampleRate: Double)? {
        guard let audioFile = audioFile else { return nil }
        
        let duration = Double(audioFile.length) / audioFile.processingFormat.sampleRate
        let sampleRate = audioFile.processingFormat.sampleRate
        return (duration, sampleRate)
    }
    
    var currentTime: TimeInterval {
        if let nodeTime = audioPlayerNode.lastRenderTime, let playerTime = audioPlayerNode.playerTime(forNodeTime: nodeTime) {
            let timeSinceSeek = Double(playerTime.sampleTime) / playerTime.sampleRate
            return timeSinceSeek + currentPlaybackTime;
        }
        return 0
    }
    
    private func fadeIn() {
        audioPlayerNode.volume = 0
        audioPlayerNode.play()
        volumeRampTimer?.invalidate()
        volumeRampTimer = Timer.scheduledTimer(withTimeInterval: rampInterval, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if self.audioPlayerNode.volume < 1.0 {
                self.audioPlayerNode.volume += self.volumeRampStep
            } else {
                timer.invalidate()
            }
        }
    }
    
    private func reset() {
        audioPlayerNode.stop()
        audioEngine.stop()
        
        audioEngine.reset()
        
        audioFile = nil
        audioFileURL = nil
        
        pitchControl.pitch = 0.0
    }

    private func fadeOut(completion: @escaping () -> Void) {
        volumeRampTimer?.invalidate()
        volumeRampTimer = Timer.scheduledTimer(withTimeInterval: rampInterval, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if self.audioPlayerNode.volume > 0 {
                self.audioPlayerNode.volume -= self.volumeRampStep
            } else {
                timer.invalidate()
                completion()
            }
        }
    }
}
