//
//  RecordingListView.swift
//  VoiceApp
//
//  Created by Kosuke Shigematsu on 4/26/25.
//

import SwiftUI

struct RecordingListView: View {
    @EnvironmentObject var recordingManager: RecordingManager
    @State private var editMode: EditMode = .inactive
    @State private var renamingRecording: Recording?
    @State private var newName = ""

    var body: some View {
        NavigationView {
            List {
                ForEach(recordingManager.recordings) { recording in
                    HStack {
                        Button(action: {
                            if recordingManager.isPlaying {
                                recordingManager.stopPlaying()
                            } else {
                                recordingManager.playRecording(recording)
                            }
                        }) {
                            Image(systemName: recordingManager.isPlaying ? "stop.circle" : "play.circle")
                                .foregroundColor(.blue)
                        }

                        Text(recording.name)
                            .onTapGesture {
                                renamingRecording = recording
                                newName = recording.name
                            }
                    }
                }
                .onMove { indices, newOffset in
                    recordingManager.moveRecording(from: indices.first!, to: newOffset)
                }
                .onDelete { indices in
                    if let index = indices.first {
                        recordingManager.deleteRecording(recordingManager.recordings[index])
                    }
                }
            }
            .navigationTitle("録音一覧")
            .toolbar {
                EditButton()
            }
            .environment(\.editMode, $editMode)
        }
        .sheet(item: $renamingRecording) { recording in
            VStack {
                Text("名前を変更")
                    .font(.headline)
                TextField("新しい名前", text: $newName)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                HStack {
                    Button("キャンセル") {
                        renamingRecording = nil
                    }
                    Spacer()
                    Button("保存") {
                        recordingManager.renameRecording(recording, newName: newName)
                        renamingRecording = nil
                    }
                }
                .padding()
            }
            .padding()
        }
    }
}
