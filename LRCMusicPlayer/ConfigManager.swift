//
//  ConfigManager.swift
//  LRCMusicPlayer
//
//  Created by 李京 on 2024/3/23.
//

import Foundation

class ConfigManager: ObservableObject {
    static let shared = ConfigManager()
    
    @Published var enabledVolumeRamp: Bool {
        didSet {
            UserDefaults.standard.set(enabledVolumeRamp, forKey: "enabledVolumeRamp")
        }
    }
    
    @Published var selectedOption: String {
        didSet {
            UserDefaults.standard.set(selectedOption, forKey: "selectedOption")
        }
    }
    
    @Published var fontSize: String {
        didSet {
            UserDefaults.standard.set(fontSize, forKey: "fontSize")
        }
    }
    
    @Published var rampDuration: Float {
        didSet {
            UserDefaults.standard.set(rampDuration, forKey: "rampDuration")
        }
    }

    private init() {
        UserDefaults.standard.register(defaults: [
            "enabledVolumeRamp": true,
            "rampDuration": 1.6
        ])
        
        self.enabledVolumeRamp = UserDefaults.standard.bool(forKey: "enabledVolumeRamp")
        self.selectedOption = UserDefaults.standard.string(forKey: "selectedOption") ?? "Option 1"
        self.fontSize = UserDefaults.standard.string(forKey: "fontSize") ?? ""
        self.rampDuration = UserDefaults.standard.float(forKey: "rampDuration")
    }
}
