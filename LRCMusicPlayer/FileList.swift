//
//  FileList.swift
//  LRCMusicPlayer
//
//  Created by 李京 on 2024/3/22.
//

import Foundation
import SwiftUI

struct FileFormatLabel: View {
    let format: String

    var body: some View {
        Text(format.lowercased())
            .font(.caption2)
            .lineLimit(1)
            .frame(width: 24, alignment: .center)
            .padding(.vertical, 4)
            .padding(.horizontal, 4)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(4)
    }
}

// 文件信息模型
struct FileInfo {
    let name: String // 文件名
    let type: String // 文件格式
    let isDirectory: Bool // 是否是文件夹
    let hasLRC: Bool // 是否有同名的.lrc文件
    let filePath: URL
}

// 歌单页面视图
struct PlaylistView: View {
    @State private var files: [FileInfo] = []
    @State private var currentDir: URL? = nil
    @State private var showMusicPlayer: Bool = false
    @State private var selectedMusic: FileInfo? = nil
    @State private var showAddMenu: Bool = false
    @State private var showSettingsMenu: Bool = false
    
    var body: some View {
            VStack {
                HStack {
//                    Button(action: {
//                        self.showAddMenu = true
//                    }) {
//                        Image(systemName: "plus")
//                    }
//                    .padding()
//                    .sheet(isPresented: $showAddMenu) {
//                        Text("plus")
//                    }
                    Menu {
                        Button("Option 1", action: {})
                        Button("Option 2", action: {})
                    } label: {
                        Image(systemName: "plus")
                    }.padding()

                    Spacer()
                    
                    
//                    Menu {
//                        Button("Option 1", action: {})
//                        Button("Option 2", action: {})
//                    } label: {
//                        Image(systemName: "gear")
//                    }.padding()

                    Button(action: {
                        self.showSettingsMenu = true
                    }) {
                        Image(systemName: "gear")
                    }
                    .padding()
                    .sheet(isPresented: $showSettingsMenu) {
                        SettingsView()
                    }
                }

                List(files, id: \.name) { file in
                    HStack {
                        if file.isDirectory {
                            Image(systemName: "folder")
                        } else {
                            FileFormatLabel(format: file.type) // 假设您已定义FileFormatLabel视图
                        }
                        Text(file.name)
                        if file.hasLRC {
                            Spacer()
                            Image(systemName: "music.note.list")
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        let fullPath = file.filePath
                        if file.isDirectory {
                            loadFiles(from: fullPath)
                            self.currentDir = fullPath
                        } else {
                            self.selectedMusic = file
                            self.showMusicPlayer = true
                            PlayContext.shared.currentMusicHasLRC = file.hasLRC
                            PlayContext.shared.currentMusicName = file.name
                            PlayContext.shared.currentMusicPath = file.filePath
                            PlayContext.shared.currentMusicType = file.type
                        }
                    }
                }
            }
            .onAppear(perform: { loadFiles() })
            .fullScreenCover(isPresented: $showMusicPlayer) {
                MusicPlayerView(dismiss: {
                    self.showMusicPlayer = false
                })
            }
        }
    
    func loadFiles(from directory: URL? = nil) {
        let fileManager = FileManager.default
        let documentsPath = directory ?? fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsPath, includingPropertiesForKeys: [.isDirectoryKey], options: [])
            
            var newFiles: [FileInfo] = []
            
            for url in fileURLs {
                let resourceValues = try url.resourceValues(forKeys: [.isDirectoryKey])
                let isDirectory = resourceValues.isDirectory ?? false
                
                if isDirectory || ["mp3", "aac", "flac", "wav", "m4a", "mp4"].contains(url.pathExtension) {
                    let hasLRC = fileURLs.contains { $0.deletingPathExtension().lastPathComponent == url.deletingPathExtension().lastPathComponent && $0.pathExtension == "lrc" }
                    
                    newFiles.append(FileInfo(name: url.deletingPathExtension().lastPathComponent, type: url.pathExtension, isDirectory: isDirectory, hasLRC: hasLRC, filePath:url))
                }
            }
            
            self.files = newFiles
        } catch {
            print("Error loading files: \(error)")
        }
    }

}

struct PlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistView()
    }
}
