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
    @Published var currentLyricIndex: Int = 0
    var lyrics: [LyricLine] = []
    private var cancellables = Set<AnyCancellable>()

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
                self?.currentLyricIndex = 0
            }
            .store(in: &cancellables)

        if let lrcInfo = playContext.getCurrentLRC() {
            self.lyrics = lrcInfo.lyrics
        }
    }

    private func updateCurrentLyricIndex(using currentTime: TimeInterval) {
        guard !lyrics.isEmpty else { return }
        
        var newIndex = currentLyricIndex;
        for index in currentLyricIndex+1..<lyrics.count {
            if lyrics[index].time < currentTime {
                newIndex = index
            }
        }

        if newIndex != currentLyricIndex {
            print("[TIME:\(currentTime)]update current lyric index \(String(describing: currentLyricIndex)) -> \(newIndex) : \(lyrics[newIndex])")
            currentLyricIndex = newIndex
        }
    }
}
