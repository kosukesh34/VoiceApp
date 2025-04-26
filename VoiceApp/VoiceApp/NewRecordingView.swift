//
//  NewRecordingView.swift
//  VoiceApp
//
//  Created by Kosuke Shigematsu on 4/26/25.
//

import SwiftUI

struct NewRecordingView: View {
    @EnvironmentObject var recordingManager: RecordingManager
    @State private var recordingName = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("新規録音")
                .font(.largeTitle)
                .padding()

            TextField("録音の名前", text: $recordingName)
                .textFieldStyle(.roundedBorder)
                .padding()

            if recordingManager.isRecording {
                Button(action: {
                    recordingManager.stopRecording(name: recordingName)
                    recordingName = ""
                }) {
                    Text("録音停止")
                        .font(.title2)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            } else {
                Button(action: {
                    recordingManager.startRecording()
                }) {
                    Text("録音開始")
                        .font(.title2)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }

            Spacer()
        }
        .padding()
    }
}

