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
}

// 歌单页面视图
struct PlaylistView: View {
    @State private var files: [FileInfo] = []
    @State private var currentPath: URL? = nil
    
    var body: some View {
        List(files, id: \.name) { file in
            HStack {
                if (file.isDirectory) {
                    Image(systemName: "folder")
                } else {
                    FileFormatLabel(format: file.type)
                }
                Text(file.name)
                if file.hasLRC {
                    Spacer()
                    Image(systemName: "music.note.list")
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if file.isDirectory {
                    let newPath = currentPath?.appendingPathComponent(file.name) ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(file.name)
                    loadFiles(from: newPath)
                    currentPath = newPath
                } else {
                    let musicPath = currentPath?.appendingPathComponent(file.name) ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(file.name)
                    print("Will play music: ", musicPath)
                    
                }
            }
        }
        .onAppear(perform: { loadFiles() })
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
                    
                    newFiles.append(FileInfo(name: url.deletingPathExtension().lastPathComponent, type: url.pathExtension, isDirectory: isDirectory, hasLRC: hasLRC))
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
