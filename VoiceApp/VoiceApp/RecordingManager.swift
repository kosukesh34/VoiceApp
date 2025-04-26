import AVFoundation
import Combine

class RecordingManager: NSObject, ObservableObject { 
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    @Published var recordings: [Recording] = []
    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var loopPlayback = false

    override init() {
        super.init()
        loadRecordings()
        configureAudioSession()
    }

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        try? session.setActive(true)
    }

    func startRecording() {
        let fileName = UUID().uuidString + ".m4a"
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)

        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.record()
            isRecording = true
        } catch {
            print("録音開始エラー: \(error)")
        }
    }

    func stopRecording(name: String) {
        audioRecorder?.stop()
        isRecording = false

        let recording = Recording(id: UUID(), name: name.isEmpty ? "録音 \(recordings.count + 1)" : name, fileURL: audioRecorder!.url, date: Date())
        recordings.append(recording)
        saveRecordings()
    }

    func playRecording(_ recording: Recording) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: recording.fileURL)
            audioPlayer?.isLooping = loopPlayback
            audioPlayer?.play()
            isPlaying = true
            audioPlayer?.delegate = self
        } catch {
            print("再生エラー: \(error)")
        }
    }

    func stopPlaying() {
        audioPlayer?.stop()
        isPlaying = false
    }

    func renameRecording(_ recording: Recording, newName: String) {
        if let index = recordings.firstIndex(where: { $0.id == recording.id }) {
            recordings[index].name = newName.isEmpty ? "録音 \(index + 1)" : newName
            saveRecordings()
        }
    }

    func deleteRecording(_ recording: Recording) {
        if let index = recordings.firstIndex(where: { $0.id == recording.id }) {
            recordings.remove(at: index)
            try? FileManager.default.removeItem(at: recording.fileURL)
            saveRecordings()
        }
    }

    func moveRecording(from sourceIndex: Int, to destinationIndex: Int) {
        let recording = recordings.remove(at: sourceIndex)
        recordings.insert(recording, at: destinationIndex)
        saveRecordings()
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private func saveRecordings() {
        let url = getDocumentsDirectory().appendingPathComponent("recordings.json")
        try? JSONEncoder().encode(recordings).write(to: url)
    }

    private func loadRecordings() {
        let url = getDocumentsDirectory().appendingPathComponent("recordings.json")
        if let data = try? Data(contentsOf: url) {
            recordings = (try? JSONDecoder().decode([Recording].self, from: data)) ?? []
        }
    }
}

extension RecordingManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
}

extension AVAudioPlayer {
    var isLooping: Bool {
        get { numberOfLoops < 0 }
        set { numberOfLoops = newValue ? -1 : 0 }
    }
}
