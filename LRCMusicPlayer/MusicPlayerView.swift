//
//  MusicPlayerView.swift
//  LRCMusicPlayer
//
//  Created by 李京 on 2024/3/22.
//

import Foundation
import AVFoundation
import SwiftUI

var flag: Bool = true;

// 主视图
struct MusicPlayerView: View {
    @State private var isPlaying = false // 播放状态
    @State private var currentLyricIndex = 0 // 当前显示的歌词索引
    @State private var currentProgress: Double = 0.0
    var songDuration: Double = 240.0
    private let playContext:PlayContext = PlayContext.shared
    private let audioPlayer:AudioPlayer = AudioPlayer.shared
    private var needCheckProgress: Bool = true;
    let dissmiss: () -> Void?
    
    private let progressTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    init(dismiss: @escaping () -> Void?) {
        self.dissmiss = dismiss
        audioPlayer.loadFile(from: playContext.currentMusicPath)
        self.songDuration = audioPlayer.songInfo?.duration ?? 240.0
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // 歌曲信息和控制按钮
                HStack {
                    Button(action: {
                        self.dissmiss()
                    }) {
                        Image(systemName: "arrow.left")
                    }
                    
                    Spacer()
                    
                    Text(playContext.currentMusicName)
                        .font(.headline)
                    
                    Spacer()
                    
                    Menu {
                        Button("Option 1", action: {})
                        Button("Option 2", action: {})
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
                .padding()
                
                LRCPreviewView()
                
                // 进度条和时间
                HStack {
                    Text("\(formatTime(seconds: currentProgress))")
                    Spacer()
                    Slider(value: $currentProgress, in: 0...songDuration) {
                            Text("Progress")
                        } onEditingChanged: { editing in
                            if (editing) {
                                disableCheckProgress()
                            } else {
                                self.audioPlayer.seek(to: currentProgress)
                                enableCheckProgress()
                            }
                        }
                        .accentColor(.blue) // 可以自定义滑块颜色
                    Spacer()
                    // 显示歌曲总时长
                    Text("\(formatTime(seconds: songDuration))")
                }
                .padding()
                .onReceive(progressTimer) { _ in
                    if (flag) {
                        self.currentProgress = self.audioPlayer.currentTime
                        if self.currentProgress > self.songDuration {
                            self.currentProgress = self.songDuration
                            self.progressTimer.upstream.connect().cancel()
                        }
                    }
                }
                
                // 底部控制按钮
                 HStack(spacing: 40) {
                     Menu {
                         Button("+4", action: {AudioPlayer.shared.setPitch(400)})
                         Button("+3", action: {AudioPlayer.shared.setPitch(300)})
                         Button("+2", action: {AudioPlayer.shared.setPitch(200)})
                         Button("+1", action: {AudioPlayer.shared.setPitch(100)})
                         Button(" 0", action: {AudioPlayer.shared.setPitch(0)})
                         Button("-1", action: {AudioPlayer.shared.setPitch(-100)})
                         Button("-2", action: {AudioPlayer.shared.setPitch(-200)})
                         Button("-3", action: {AudioPlayer.shared.setPitch(-300)})
                         Button("-4", action: {AudioPlayer.shared.setPitch(-400)})
                     } label: {
                         Image(systemName: "music.note")
                     }
                     
                     Button(action: {
                     }) {
                         Image(systemName: "backward.end.fill")
                     }
                     
                     Button(action: {
                         if (isPlaying) {
                             audioPlayer.pause()
                         } else {
                             audioPlayer.play()
                         }
                         isPlaying.toggle() // 切换播放状态
                     }) {
                         Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                             .font(.system(size: 44)) // 固定图标大小
                     }
                     
                     Button(action: {
                         // 下一曲操作
                     }) {
                         Image(systemName: "forward.end.fill")
                     }
                     
                     Menu {
                         Button("Playlist Option 1", action: {})
                         Button("Playlist Option 2", action: {})
                     } label: {
                         Image(systemName: "music.note.list")
                     }
                 }
                 .padding()
            }
//            .navigationBarHidden(true) // 隐藏默认的导航栏，因为我们自定义了顶部控件
        }
        .onAppear() {
            let session = AVAudioSession.sharedInstance()
            do {
              try session.setActive(true)
              try session.setCategory(AVAudioSession.Category.playback)
            } catch {
              print(error)
            }
        }.gesture(DragGesture().onEnded { gesture in
            if gesture.translation.width > 100 {
                self.dissmiss()
            }        })
    }
    
    func enableCheckProgress () {
//        self.needCheckProgress = true;
        flag = true;
    }
    
    func disableCheckProgress () {
//        self.needCheckProgress = false;
        flag = false;
    }
    
    func formatTime(seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct MusicPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        MusicPlayerView(dismiss: {})
    }
}
