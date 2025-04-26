//
//  ContentView.swift
//  VoiceApp
//
//  Created by Kosuke Shigematsu on 4/26/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var recordingManager = RecordingManager()

    var body: some View {
        TabView {
            NewRecordingView()
                .tabItem {
                    Label("新規録音", systemImage: "mic")
                }
                .environmentObject(recordingManager)

            RecordingListView()
                .tabItem {
                    Label("録音一覧", systemImage: "list.bullet")
                }
                .environmentObject(recordingManager)

            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gear")
                }
                .environmentObject(recordingManager)
        }
    }
}

