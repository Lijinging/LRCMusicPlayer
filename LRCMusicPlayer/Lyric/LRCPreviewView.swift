//
//  LRCPreviewView.swift
//  LRCMusicPlayer
//
//  Created by 李京 on 3/24/24.
//

import SwiftUI

struct LRCPreviewView: View {
    @ObservedObject var viewModel = LRCViewModel()
    
    var body: some View {
        ScrollViewReader { scrollView in
            ScrollView {
                if let lrcInfos = PlayContext.shared.getCurrentLRC() {
                    VStack(alignment: .leading) {
                        ForEach(Array(lrcInfos.lyrics.enumerated()), id: \.element.id) { index, lyric in
                            HStack(spacing: 0) {
                                Spacer()
                                Text(lyric.text)
                                    .multilineTextAlignment(.center)
                                    .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                                    .font(.system(size: viewModel.currentLyricIndex == index ? CGFloat(Float(ConfigManager.shared.fontSize) ?? 24) + 2 : CGFloat(Float(ConfigManager.shared.fontSize) ?? 24)))
                                    .fontWeight(viewModel.currentLyricIndex == index ? .bold : .regular)
                                    .foregroundColor(viewModel.currentLyricIndex == index ? .red : .black)
                                Spacer()
                            }
                            .id(index)
                        }
                    }
                } else {
                    Text("无歌词").font(.title3)
                }
            }
            .onChange(of: viewModel.currentLyricIndex) { newIndex in
                withAnimation {
                    let targetIndex = newIndex < 0 ? 0 : newIndex
                    scrollView.scrollTo(targetIndex, anchor: .center)
                }
            }
            .onAppear {
                UIApplication.shared.isIdleTimerDisabled = true
            }
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false
            }
        }
    }
}

#Preview {
    LRCPreviewView()
}
