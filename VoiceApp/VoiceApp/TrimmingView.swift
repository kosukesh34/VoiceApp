//
//  TrimmingView.swift
//  VoiceApp
//
//  Created by Kosuke Shigematsu on 4/26/25.
//

import SwiftUI
import AVFoundation

struct TrimmingView: View {
    @EnvironmentObject var recordingManager: RecordingManager
    @Environment(\.dismiss) var dismiss
    let recording: Recording
    @State private var startTime: Double = 0
    @State private var endTime: Double = 0
    
    var body: some View {
        VStack {
            Text("トリミング: \(recording.name)")
                .font(.headline)
            Slider(value: $startTime, in: 0...endTime, step: 0.1)
                .padding()
            Slider(value: $endTime, in: startTime...recordingManager.duration, step: 0.1)
                .padding()
            HStack {
                Button("プレビュー") {
                    recordingManager.previewTrim(recording, start: startTime, end: endTime)
                }
                Button("保存") {
                    recordingManager.trimRecording(recording, start: startTime, end: endTime)
                    dismiss()
                }
            }
        }
        .onAppear {
            endTime = recordingManager.duration
        }
    }
}
