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

                NavigationLink(destination: SelectOptionView(selectedOption: $configManager.selectedOption)) {
                    HStack {
                        Text("选择选项")
                        Spacer()
                        Text(configManager.selectedOption)
                            .foregroundColor(.gray)
                    }
                }

                HStack {
                    Text("字号")
                    Spacer()
                    TextField("18", text: $configManager.fontSize)
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
    @Binding var selectedOption: String
    let options = ["Option 1", "Option 2", "Option 3"]

    var body: some View {
        List(options, id: \.self) { option in
            HStack {
                Text(option)
                Spacer()
                if option == selectedOption {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                selectedOption = option
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

