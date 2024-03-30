//
//  LyricsViewModel.swift
//  LRCMusicPlayer
//
//  Created by 李京 on 2024/3/28.
//

import Foundation
import Combine

class LRCViewModel: ObservableObject {
    private let playContext: PlayContext = PlayContext.shared
    @Published var currentLyricIndex: Int = -1
    var lyrics: [LyricLine] = []
    private var offset: TimeInterval = 0
    private var cancellables = Set<AnyCancellable>()
    private var lastTime: TimeInterval = 0

    init() {
        setupBindings()
    }

    private func setupBindings() {
        playContext.$currentTime
            .sink { [weak self] currentTime in
                self?.updateCurrentLyricIndex(using: currentTime)
            }
            .store(in: &cancellables)
        
        playContext.$currentMusicPath
            .sink { [weak self] _ in
                self?.currentLyricIndex = -1
                self?.offset = 0
            }
            .store(in: &cancellables)

        if let lrcInfo = playContext.getCurrentLRC() {
            self.lyrics = lrcInfo.lyrics
            self.offset = lrcInfo.offset ?? 0
        }
    }

    private func updateCurrentLyricIndex(using currentTime: TimeInterval) {
        guard !lyrics.isEmpty else { return }
        
        var newIndex = currentTime < lastTime ? -1 : currentLyricIndex;
        for index in currentLyricIndex+1..<lyrics.count {
            if (lyrics[index].time + offset) < currentTime {
                newIndex = index
            }
        }

        if newIndex != currentLyricIndex {
            if newIndex >= 0 {
                print("[TIME:\(currentTime)]update current lyric index \(String(describing: currentLyricIndex)) -> \(newIndex) : \(lyrics[newIndex])")
            }
            currentLyricIndex = newIndex
        }
        
        lastTime = currentTime
    }
}
