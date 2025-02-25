//
//  ConfigManager.swift
//  LRCMusicPlayer
//
//  Created by 李京 on 2024/3/23.
//

import Foundation

let kCyclicModeType_None = 0
let kCyclicModeType_Single = 1
let kCyclicModeType_List = 2

let kCyclicModeType_Name = ["不循环", "单曲循环", "列表循环"]

class ConfigManager: ObservableObject {
    static let shared = ConfigManager()
    
    @Published var enabledVolumeRamp: Bool {
        didSet {
            UserDefaults.standard.set(enabledVolumeRamp, forKey: "enabledVolumeRamp")
        }
    }
    
    @Published var cyclicMode: String {
        didSet {
            UserDefaults.standard.set(Int(cyclicMode), forKey: "cyclicMode")
        }
    }
    
    @Published var fontSize: String {
        didSet {
            UserDefaults.standard.set(fontSize, forKey: "fontSize")
        }
    }
    
    @Published var fadeInDuration: String {
        didSet {
            UserDefaults.standard.set(Float(fadeInDuration), forKey: "fadeInDuration")
        }
    }
    
    @Published var fadeOutDuration: String {
        didSet {
            UserDefaults.standard.set(Float(fadeOutDuration), forKey: "fadeOutDuration")
        }
    }
    
    public var getCycleModeStr:String {
        switch Int(cyclicMode) {
        case kCyclicModeType_None: return "不循环"
        case kCyclicModeType_Single: return "单曲循环"
        case kCyclicModeType_List: return "列表循环"
        case .none:
            return "不循环"
        case .some(_):
            return "不循环"
        }
    }

    private init() {
        UserDefaults.standard.register(defaults: [
            "enabledVolumeRamp": true,
            "fadeInDuration": 0.5,
            "fadeOutDuration": 2.0,
            "cyclicMode": kCyclicModeType_None,
            "fontSize": "24"
        ])
        
        self.enabledVolumeRamp = UserDefaults.standard.bool(forKey: "enabledVolumeRamp")
        self.cyclicMode = String(UserDefaults.standard.float(forKey: "cyclicMode"))
        self.fontSize = UserDefaults.standard.string(forKey: "fontSize") ?? ""
        self.fadeInDuration = String(UserDefaults.standard.float(forKey: "fadeInDuration"))
        self.fadeOutDuration = String(UserDefaults.standard.float(forKey: "fadeOutDuration"))
    }
}
