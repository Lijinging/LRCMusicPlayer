//
//  LRCPreviewView.swift
//  LRCMusicPlayer
//
//  Created by 李京 on 3/24/24.
//

import SwiftUI

struct LRCPreviewView: View {
    private let playContext:PlayContext = PlayContext.shared
    private let audioPlayer:AudioPlayer = AudioPlayer.shared
    
    @State var currentTime: TimeInterval = 0
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ScrollView {
            if let lrcInfos = playContext.getCurrentLRC() {
                VStack(alignment: .leading) {
                    ForEach(0..<lrcInfos.lyrics.count, id: \.self) { index in
                        HStack(spacing: 0) {
                            Spacer()
                            Text(lrcInfos.lyrics[index].text)
                                .multilineTextAlignment(.center)
                                .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                                .font(.system(size: CGFloat(Float(ConfigManager.shared.fontSize) ?? 24)))
                            Spacer()
                        }
                    }
                }
            } else {
                Text("无歌词").font(.title3)
            }
        }.onReceive(timer) { _ in
            // 完成逻辑，使用方法通过audioPlayer.currentTime
        }
    }
}

#Preview {
    LRCPreviewView()
}
