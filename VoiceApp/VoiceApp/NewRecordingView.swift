import SwiftUI

struct NewRecordingView: View {
    @EnvironmentObject var recordingManager: RecordingManager
    @State private var recordingTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var waveformData: [Float] = []

    var body: some View {
        VStack(spacing: 20) {
            Text("新規録音")
                .font(.largeTitle)
                .padding()

            Text(timeString(from: recordingTime))
                .font(.title2)
                .padding()

            WaveformView(data: waveformData)
                .frame(height: 100)
                .padding()

            if recordingManager.isRecording {
                Button(action: {
                    recordingManager.stopRecording(name: "")
                    stopTimer()
                    waveformData = []
                }) {
                    Image(systemName: "stop.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.red)
                }
            } else {
                Button(action: {
                    recordingManager.startRecording()
                    startTimer()
                    startWaveformUpdate()
                }) {
                    Image(systemName: "record.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.red)
                }
            }

            Spacer()
        }
        .padding()
    }

    private func startTimer() {
        recordingTime = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            recordingTime += 1
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        recordingTime = 0
    }

    private func startWaveformUpdate() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if recordingManager.isRecording {
                waveformData.append(Float.random(in: 0...1)) // ダミーデータ
                if waveformData.count > 100 {
                    waveformData.removeFirst()
                }
            }
        }
    }

    private func timeString(from time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct WaveformView: View {
    let data: [Float]

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let step = width / CGFloat(data.count)
                for (index, sample) in data.enumerated() {
                    let x = CGFloat(index) * step
                    let y = (1 - CGFloat(sample)) * height / 2
                    path.move(to: CGPoint(x: x, y: height / 2))
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(Color.blue, lineWidth: 1)
        }
    }
}
