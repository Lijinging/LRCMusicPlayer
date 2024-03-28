//
//  MusicPlayerViewModel.swift
//  LRCMusicPlayer
//
//  Created by 李京 on 2024/3/28.
//

import Foundation
import Combine

class MusicPlayerViewModel: ObservableObject {
    private let audioPlayer: AudioPlayer = AudioPlayer.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isPlaying = false
    @Published var currentLyricIndex = 0
    @Published var currentProgress: Double = 0.0
    var songDuration: Double = 240.0
    
    init() {
        setupAudioPlayer()
    }
    
    func setupAudioPlayer() {
        if !audioPlayer.isLoaded() {
            audioPlayer.loadFile(from: PlayContext.shared.currentMusicPath)
        }
        songDuration = audioPlayer.songInfo?.duration ?? 240.0
        
        // 监听播放器的当前时间，并更新进度条
        Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in
                self?.updateProgress()
            }.store(in: &cancellables)
    }
    
    func updateProgress() {
        self.currentProgress = self.audioPlayer.currentTime
        if self.currentProgress > self.songDuration {
            self.currentProgress = self.songDuration
        }
    }
    
    func playOrPause() {
        if isPlaying {
            audioPlayer.pause()
        } else {
            audioPlayer.play()
        }
        isPlaying.toggle()
    }
    
    func formatTime(seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
//    func enableCheckProgress () {
//        flag = true;
//    }
//    
//    func disableCheckProgress () {
//        flag = false;
//    }
}

