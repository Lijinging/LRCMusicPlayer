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
    @State private var isPickerPresented = false
    @State private var searchQuery = ""
    
    var body: some View {
            VStack {
                HStack {
                    Menu {
                        Button("导入", action: {
                            isPickerPresented = true
                        })
                        Button("设置", action: {
                            self.showSettingsMenu = true
                        })
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                    }.padding()
                    
                    Spacer()
                    
                    TextField("搜索文件名", text: $searchQuery)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding()

                    Spacer()

                    Button(action: {
                        self.showMusicPlayer = true
                    }) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 24))
                    }
                    .padding()
                }

                List(filteredFiles, id: \.name) { file in
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
                            AudioPlayer.shared.stop()
                            AudioPlayer.shared.loadFile(from: file.filePath)
                        }
                    }
                }
            }
            .onAppear(perform: { loadFiles() })
            .sheet(isPresented: $showSettingsMenu) {
                SettingsView()
            }
            .sheet(isPresented: $isPickerPresented) {
                DocumentPicker { urls in
                    for url in urls {
                        saveDocumentAt(url)
                    }
                }
            }
            .fullScreenCover(isPresented: $showMusicPlayer) {
                MusicPlayerView(dismiss: {
                    self.showMusicPlayer = false
                })
            }.gesture(DragGesture().onEnded { gesture in
                if gesture.translation.width < 100 {
                    self.showMusicPlayer = true
                }
            })
        }
    
    var filteredFiles: [FileInfo] {
            if searchQuery.isEmpty {
                return files
            } else {
                return files.filter { $0.name.localizedCaseInsensitiveContains(searchQuery) }
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
    
    func saveDocumentAt(_ url: URL) {
            // 这里实现将文件保存到应用的Documents目录下的逻辑
            // 示例代码省略了错误处理和具体实现细节
            let fileManager = FileManager.default
            guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            let destinationURL = documentsPath.appendingPathComponent(url.lastPathComponent)
            
            do {
                if fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.removeItem(at: destinationURL)
                }
                try fileManager.copyItem(at: url, to: destinationURL)
            } catch {
                print("无法保存文件: \(error)")
            }
        }

}

struct PlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistView()
    }
}
