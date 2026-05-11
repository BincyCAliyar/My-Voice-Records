import Foundation
import AVFoundation

class AudioRecorderManager: NSObject, ObservableObject, AVAudioRecorderDelegate {
    var audioRecorder: AVAudioRecorder?
    
    @Published var isRecording = false
    @Published var powerLevels: [CGFloat] = Array(repeating: -50.0, count: 50)
    @Published var recordingDuration: TimeInterval = 0.0
    
    private var timer: Timer?
    
    override init() {
        super.init()
        setupSession()
    }
    
    func setupSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true)
            session.requestRecordPermission { allowed in
                if !allowed {
                    print("Microphone permission denied")
                }
            }
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func startRecording() {
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentPath.appendingPathComponent("Recording_\(Date().timeIntervalSince1970).m4a")
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            isRecording = true
            startMetering()
        } catch {
            print("Could not start recording: \(error)")
            stopRecording()
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        stopMetering()
    }
    
    private func startMetering() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self, let recorder = self.audioRecorder else { return }
            recorder.updateMeters()
            
            // Average power ranges from -160 (quiet) to 0 (max)
            // Normalizing to something more visual (e.g. 0 to 1)
            let power = CGFloat(recorder.averagePower(forChannel: 0))
            
            DispatchQueue.main.async {
                self.powerLevels.removeFirst()
                self.powerLevels.append(power)
                self.recordingDuration = recorder.currentTime
            }
        }
    }
    
    private func stopMetering() {
        timer?.invalidate()
        timer = nil
        powerLevels = Array(repeating: -50.0, count: 50)
        recordingDuration = 0.0
    }
}
