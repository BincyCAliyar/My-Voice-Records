import XCTest
@testable import MyVoiceRecording

final class MyVoiceRecordingTests: XCTestCase {

    func testRecordingModelInitialization() {
        let url = URL(fileURLWithPath: "/path/to/test.m4a")
        let date = Date()
        let recording = Recording(fileURL: url, createdAt: date, duration: 10.0)
        
        XCTAssertEqual(recording.fileURL, url)
        XCTAssertEqual(recording.createdAt, date)
        XCTAssertEqual(recording.duration, 10.0)
        XCTAssertEqual(recording.title, "test")
    }
    
    func testAudioRecorderManagerInitialState() {
        let manager = AudioRecorderManager()
        XCTAssertFalse(manager.isRecording)
        XCTAssertEqual(manager.powerLevels.count, 50)
    }
    
    func testAudioPlayerManagerInitialState() {
        let manager = AudioPlayerManager()
        XCTAssertFalse(manager.isPlaying)
        XCTAssertEqual(manager.progress, 0.0)
        XCTAssertEqual(manager.duration, 0.0)
    }

}
