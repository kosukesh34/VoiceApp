import SwiftUI

struct RecordingListView: View {
    @EnvironmentObject var recordingManager: RecordingManager
    @State private var selectedRecording: Recording?
    @State private var playlist: [Recording] = []
    @State private var isPlayingPlaylist = false

    var body: some View {
        NavigationView {
            List {
                ForEach(recordingManager.recordings) { recording in
                    HStack {
                        Button(action: {
                            selectedRecording = recording
                            recordingManager.playRecording(recording)
                        }) {
                            Image(systemName: "play.circle")
                                .foregroundColor(.blue)
                        }
                        Text(recording.name)
                    }
                }
                .onDelete { indices in
                    if let index = indices.first {
                        recordingManager.deleteRecording(recordingManager.recordings[index])
                    }
                }
            }
            .navigationTitle("録音一覧")
            .toolbar {
                Button(action: {
                    playlist = recordingManager.recordings
                    isPlayingPlaylist = true
                }) {
                    Text("プレイリスト")
                }
            }
        }
        .sheet(isPresented: $isPlayingPlaylist) {
            PlaylistView(playlist: $playlist, recordingManager: recordingManager)
        }
        .overlay(
            VStack {
                Spacer()
                if selectedRecording != nil {
                    PlaybackControlView(recording: selectedRecording!)
                }
            }
        )
    }
}

struct PlaybackControlView: View {
    @EnvironmentObject var recordingManager: RecordingManager
    let recording: Recording

    var body: some View {
        VStack {
            Slider(value: $recordingManager.currentTime, in: 0...max(recordingManager.duration, 0), step: 0.1, onEditingChanged: { editing in
                if !editing {
                    recordingManager.seek(to: recordingManager.currentTime)
                }
            })
            .accentColor(.blue)

            HStack {
                Text(timeString(from: recordingManager.currentTime))
                Spacer()
                Text("-\(timeString(from: max(recordingManager.duration - recordingManager.currentTime, 0)))")
            }
            .font(.caption)

            HStack(spacing: 20) {
                Button(action: {
                    recordingManager.skipBackward(15)
                }) {
                    Image(systemName: "gobackward.15")
                        .font(.title)
                }

                Button(action: {
                    if recordingManager.isPlaying {
                        recordingManager.pausePlaying()
                    } else {
                        recordingManager.playRecording(recording)
                    }
                }) {
                    Image(systemName: recordingManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.blue)
                }

                Button(action: {
                    recordingManager.skipForward(15)
                }) {
                    Image(systemName: "goforward.15")
                        .font(.title)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .shadow(radius: 5)
    }

    private func timeString(from time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct PlaylistView: View {
    @Binding var playlist: [Recording]
    @ObservedObject var recordingManager: RecordingManager

    var body: some View {
        List {
            ForEach(playlist) { recording in
                Text(recording.name)
            }
            .onMove { indices, newOffset in
                playlist.move(fromOffsets: indices, toOffset: newOffset)
            }
        }
        .toolbar {
            Button("再生") {
                // プレイリスト再生（未実装）
            }
        }
    }
}
