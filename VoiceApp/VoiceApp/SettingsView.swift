//
//  Setting.swift
//  VoiceApp
//
//  Created by Kosuke Shigematsu on 4/26/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var recordingManager: RecordingManager

    var body: some View {
        Form {
            Section(header: Text("再生設定")) {
                Toggle("繰り返し再生", isOn: $recordingManager.loopPlayback)
            }
        }
        .navigationTitle("設定")
    }
}

