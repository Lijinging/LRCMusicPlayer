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
    private var timeSinceSeek: TimeInterval = 0
    var isPaused: Bool = false
    
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
    
    func isLoaded() -> Bool {
        return audioFile != nil
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
            self?.isPaused = true // 在暂停时更新状态
            self?.updateCurrentPlaybackTime()
        }
    }

    func resume() {
        // 在恢复播放前更新当前播放时间
        updateCurrentPlaybackTime()
        isPaused = false // 重置暂停状态
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
                
        isPaused = false // 重置暂停状态
        currentPlaybackTime = time // 更新播放时间

        let sampleRate = audioFile.processingFormat.sampleRate
        let framePosition = AVAudioFramePosition(time * sampleRate)
        audioPlayerNode.stop()

        audioEngine.stop() // 确保在调度新片段前引擎停止
        try? audioEngine.start() // 重启引擎

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
            timeSinceSeek = Double(playerTime.sampleTime) / playerTime.sampleRate
            return timeSinceSeek + currentPlaybackTime // 确保加上之前已播放的时间
        }
        return timeSinceSeek + currentPlaybackTime
    }
    
    @discardableResult
    private func updateCurrentPlaybackTime() -> TimeInterval {
        if let nodeTime = audioPlayerNode.lastRenderTime, let playerTime = audioPlayerNode.playerTime(forNodeTime: nodeTime) {
            currentPlaybackTime = Double(playerTime.sampleTime) / playerTime.sampleRate
        }
        return currentPlaybackTime
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
