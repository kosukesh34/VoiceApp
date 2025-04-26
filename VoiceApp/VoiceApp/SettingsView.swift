import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var recordingManager: RecordingManager

    var body: some View {
        Form {
            Section(header: Text("Playback Settings")) {
                Toggle("Loop Playback", isOn: $recordingManager.loopPlayback)
            }
        }
        .navigationTitle("Settings")
    }
}
