import AVFoundation
import Combine

class RecordingManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var loopPlayback = false
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    @Published var recordings: [Recording] = []
    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var playbackSpeed: Float = 1.0
    private var timer: Timer?

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
        let fileName = UUID().uuidString + ".caf" // .m4a -> .caf
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)

        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatAppleLossless, // 互換性向上
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

        let recording = Recording(id: UUID(), name: name.isEmpty ? "新規録音 \(recordings.count + 1)" : name, fileURL: audioRecorder!.url, date: Date())
        recordings.append(recording)
        saveRecordings()
    }

    func playRecording(_ recording: Recording) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: recording.fileURL)
            audioPlayer?.delegate = self
            audioPlayer?.enableRate = true
            audioPlayer?.rate = playbackSpeed
            duration = audioPlayer?.duration ?? 0
            audioPlayer?.play()
            isPlaying = true
            startTimer()
        } catch {
            print("再生エラー: \(error)")
        }
    }

    func pausePlaying() {
        audioPlayer?.pause()
        isPlaying = false
        stopTimer()
    }

    func stopPlaying() {
        audioPlayer?.stop()
        isPlaying = false
        currentTime = 0
        stopTimer()
    }

    func seek(to time: TimeInterval) {
        if let player = audioPlayer {
            let newTime = max(0, min(time, player.duration))
            player.currentTime = newTime
            currentTime = newTime
        }
    }

    func skipForward(_ seconds: TimeInterval) {
        if let player = audioPlayer {
            let newTime = min(player.currentTime + seconds, player.duration)
            seek(to: newTime)
        }
    }

    func skipBackward(_ seconds: TimeInterval) {
        if let player = audioPlayer {
            let newTime = max(player.currentTime - seconds, 0)
            seek(to: newTime)
        }
    }

    func setPlaybackSpeed(_ speed: Float) {
        playbackSpeed = speed
        audioPlayer?.rate = speed
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

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            if let player = self?.audioPlayer {
                self?.currentTime = player.currentTime
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        currentTime = 0
        stopTimer()
    }
}
