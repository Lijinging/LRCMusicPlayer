//
//  LRCLoader.swift
//  LRCMusicPlayer
//
//  Created by 李京 on 3/24/24.
//

import Foundation

struct LyricLine: Hashable {
    let id = UUID() // 添加一个唯一标识符
    let time: TimeInterval // 歌词对应的时间，以秒为单位
    let text: String // 歌词文本
}

struct LRCParseResult {
    var offset: TimeInterval? // 时间偏移量，以秒为单位
    var lyrics: [LyricLine] = [] // 所有歌词行及对应时间
}

func parseLRC(from lrcPath: URL) -> LRCParseResult {
    do {
        let lrcContent = try String(contentsOf: lrcPath)
        var result = LRCParseResult()
        let lines = lrcContent.split(separator: "\n")
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedLine.hasPrefix("[offset:") {
                // 解析offset
                let offsetString = trimmedLine
                    .replacingOccurrences(of: "[offset:", with: "")
                    .replacingOccurrences(of: "]", with: "")
                if let offset = TimeInterval(offsetString) {
                    result.offset = offset / 1000.0 // 将毫秒转换为秒
                }
            } else if trimmedLine.hasPrefix("[") {
                // 解析歌词行
                let components = trimmedLine.components(separatedBy: "]")
                if components.count >= 2, let time = parseTime(components[0] + "]") {
                    let text = components.dropFirst().joined(separator: "]")
                    result.lyrics.append(LyricLine(time: time, text: text))
                }
            }
        }
        
        return result
    } catch {
        print("Error reading LRC file: \(error.localizedDescription)")
        return LRCParseResult()
    }
}

func parseTime(_ timeString: String) -> TimeInterval? {
    let pattern = "\\[(\\d+):(\\d+)(?:\\.(\\d+))?\\]"
    if let regex = try? NSRegularExpression(pattern: pattern),
       let match = regex.firstMatch(in: timeString, options: [], range: NSRange(location: 0, length: timeString.utf16.count)) {
        
        let minuteRange = match.range(at: 1)
        let secondRange = match.range(at: 2)
        let millisecondRange = match.range(at: 3)
        
        if let minuteStr = Range(minuteRange, in: timeString),
           let secondStr = Range(secondRange, in: timeString) {
            
            let minute = TimeInterval((timeString[minuteStr] as NSString).doubleValue)
            let second = TimeInterval((timeString[secondStr] as NSString).doubleValue)
            var millisecond = TimeInterval(0)
            
            if let millisecondStr = Range(millisecondRange, in: timeString) {
                let millisecondText = String(timeString[millisecondStr])
                let millisecondValue = (millisecondText as NSString).doubleValue
                millisecond = millisecondValue / (millisecondText.count == 2 ? 100 : 1000)
            }
            print("timeString \(timeString) -> \(minute * 60 + second + millisecond)")
            return minute * 60 + second + millisecond
        }
    }
    
    return nil
}
