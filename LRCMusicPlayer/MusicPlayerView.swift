//
//  MusicPlayerView.swift
//  LRCMusicPlayer
//
//  Created by 李京 on 2024/3/22.
//

import Foundation
import SwiftUI

// 定义一个简单的歌词模型
struct Lyric {
    let time: TimeInterval // 时间戳，用于同步
    let text: String // 歌词文本
}

// 主视图
struct MusicPlayerView: View {
    // 假设这是你的歌词数组
    let lyrics: [Lyric] = [
        Lyric(time: 0, text: "Here is the first line of a song"),
        Lyric(time: 15, text: "Here is the second line of the song"),
        Lyric(time: 40, text: "Here is the second line of the song"),
        Lyric(time: 41, text: "Here is the second line of the song"),
        Lyric(time: 44, text: "Here is the second line of the song"),
        Lyric(time: 45, text: "Here is the second line of the song"),
        Lyric(time: 15, text: "Here is the second line of the song"),
        Lyric(time: 15, text: "Here is the second line of the song"),
        // 添加更多歌词...
    ]
    
    @State private var isPlaying = false // 播放状态
    @State private var currentLyricIndex = 0 // 当前显示的歌词索引
    @State private var currentProgress: Double = 30.0
    var songDuration: Double = 240.0
    
    var body: some View {
        NavigationView {
            VStack {
                // 歌曲信息和控制按钮
                HStack {
                    Button(action: {
                        // 返回歌单操作
                    }) {
                        Image(systemName: "arrow.left")
                    }
                    
                    Spacer()
                    
                    Text("Song Title Here")
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
                
                // 歌词区域
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(0..<lyrics.count, id: \.self) { index in
                            Text(lyrics[index].text)
                                .padding(.vertical)
                                // 可以根据需要调整歌词的样式
                        }
                    }
                }
                
                // 进度条和时间
                HStack {
                    Text("\(formatTime(seconds: currentProgress))")
                    Spacer()
                    Slider(value: $currentProgress, in: 0...songDuration) {
                            Text("Progress")
                        } onEditingChanged: { editing in
                            NSLog("update progress %f", currentProgress/songDuration)
                        }
                        .accentColor(.blue) // 可以自定义滑块颜色
                    Spacer()
                    // 显示歌曲总时长
                    Text("\(formatTime(seconds: songDuration))")
                }
                .padding()
                
                // 底部控制按钮
                 HStack(spacing: 40) {
                     Button(action: {
                         // 变调操作
                     }) {
                         Image(systemName: "music.note")
                     }
                     
                     Button(action: {
                         // 上一曲操作
                     }) {
                         Image(systemName: "backward.end.fill")
                     }
                     
                     Button(action: {
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
            .navigationBarHidden(true) // 隐藏默认的导航栏，因为我们自定义了顶部控件
        }
    }
    
    func formatTime(seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct MusicPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        MusicPlayerView()
    }
}
