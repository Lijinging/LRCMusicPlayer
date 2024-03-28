//
//  PlayContext.swift
//  LRCMusicPlayer
//
//  Created by 李京 on 3/24/24.
//

import Foundation
import Combine

class PlayContext: ObservableObject {
    static let shared = PlayContext()
    
    private var currentLRC: LRCParseResult?
    private var timer: AnyCancellable?
    
    @Published var currentTime: TimeInterval = 0
    @Published var currentMusicPath: URL {
        didSet {
            UserDefaults.standard.set(currentMusicPath, forKey: "currentMusicPath")
            self.updateCurrentLRC()
        }
    }
    
    @Published var currentMusicName: String {
        didSet {
            UserDefaults.standard.set(currentMusicName, forKey: "currentMusicName")
        }
    }
    
    @Published var currentMusicType: String {
        didSet {
            UserDefaults.standard.set(currentMusicType, forKey: "currentMusicType")
        }
    }
    
    @Published var currentMusicHasLRC: Bool {
        didSet {
            UserDefaults.standard.set(currentMusicHasLRC, forKey: "currentMusicHasLRC")
        }
    }

    private init() {
        UserDefaults.standard.register(defaults: [
            "enabledVolumeRamp": true,
            "rampDuration": 1.6,
            "cyclicMode": kCyclicModeType_None
        ])
        
        self.currentMusicPath = UserDefaults.standard.url(forKey: "currentMusicPath") ?? URL(fileURLWithPath: "nil")
        self.currentMusicName = UserDefaults.standard.string(forKey: "currentMusicName") ?? "暂未播放歌曲"
        self.currentMusicType = UserDefaults.standard.string(forKey: "currentMusicType") ?? "nil"
        self.currentMusicHasLRC = UserDefaults.standard.bool(forKey: "currentMusicHasLRC")

        // 初始化定时器
        self.timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            self?.currentTime = AudioPlayer.shared.currentTime
        }
    }
    
    func getCurrentLRC() -> LRCParseResult? {
        return self.currentLRC
    }
    
    private func getLRCURL() -> URL? {
        let mp3Path = self.currentMusicPath.deletingPathExtension().path
        let lrcPath = mp3Path + ".lrc"
        return URL(fileURLWithPath: lrcPath)
    }
    
    private func updateCurrentLRC() {
        if self.currentMusicHasLRC {
            if let lrcUrl = getLRCURL() {
                self.currentLRC = parseLRC(from: lrcUrl)
            } else {
                self.currentLRC = nil
            }
        } else {
            self.currentLRC = nil
        }
    }
}
