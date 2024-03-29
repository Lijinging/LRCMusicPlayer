//
//  SettingView.swift
//  LRCMusicPlayer
//
//  Created by 李京 on 2024/3/23.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var configManager = ConfigManager.shared

    var body: some View {
        NavigationView {
            Form {
                Toggle(isOn: $configManager.enabledVolumeRamp) {
                    Text("淡入淡出")
                }
                
                HStack {
                    Text("淡入淡出时长")
                    Spacer()
                    TextField("1.6", text: $configManager.rampDuration)
                        .frame(width: 100)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                }

                NavigationLink(destination: SelectOptionView(cycleModeStr: $configManager.cyclicMode)) {
                    HStack {
                        Text("循环模式")
                        Spacer()
                        Text(configManager.getCycleModeStr)
                            .foregroundColor(.gray)
                    }
                }

                HStack {
                    Text("字号")
                    Spacer()
                    TextField("24", text: $configManager.fontSize)
                        .frame(width: 100)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                }
            }
            .navigationBarTitle("设置")
        }
    }
}

struct SelectOptionView: View {
    @Binding var cycleModeStr: String
    let options = ["不循环", "单曲循环", "列表循环"]

    var body: some View {
        List(options, id: \.self) { option in
            HStack {
                Text(option)
                Spacer()
                if option == cycleModeStr {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                cycleModeStr = option
            }
        }
        .navigationBarTitle("选择选项", displayMode: .inline)
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

