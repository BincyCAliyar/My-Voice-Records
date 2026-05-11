import Foundation
import AVFoundation

class RecordingsViewModel: ObservableObject {
    @Published var recordings: [Recording] = []
    
    init() {
        fetchRecordings()
    }
    
    func fetchRecordings() {
        recordings.removeAll()
        
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: documentPath, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles)
            
            var fetchedRecordings: [Recording] = []
            
            for url in urls where url.pathExtension == "m4a" {
                let asset = AVURLAsset(url: url)
                let duration = CMTimeGetSeconds(asset.duration)
                
                let resourceValues = try url.resourceValues(forKeys: [.creationDateKey])
                let createdAt = resourceValues.creationDate ?? Date()
                
                let recording = Recording(fileURL: url, createdAt: createdAt, duration: duration)
                fetchedRecordings.append(recording)
            }
            
            fetchedRecordings.sort(by: { $0.createdAt > $1.createdAt })
            
            DispatchQueue.main.async {
                self.recordings = fetchedRecordings
            }
            
        } catch {
            print("Failed to fetch recordings: \(error)")
        }
    }
    
    func deleteRecording(at offsets: IndexSet) {
        for index in offsets {
            let recording = recordings[index]
            do {
                try FileManager.default.removeItem(at: recording.fileURL)
            } catch {
                print("Could not delete recording: \(error)")
            }
        }
        recordings.remove(atOffsets: offsets)
    }
    
    func deleteRecording(_ recording: Recording) {
        if let index = recordings.firstIndex(where: { $0.id == recording.id }) {
            do {
                try FileManager.default.removeItem(at: recording.fileURL)
                recordings.remove(at: index)
            } catch {
                print("Could not delete recording: \(error)")
            }
        }
    }
    
    func renameRecording(_ recording: Recording, newName: String) {
        guard !newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let directory = recording.fileURL.deletingLastPathComponent()
        let newURL = directory.appendingPathComponent("\(newName).m4a")
        
        do {
            try FileManager.default.moveItem(at: recording.fileURL, to: newURL)
            
            if let index = recordings.firstIndex(where: { $0.id == recording.id }) {
                let updatedRecording = Recording(fileURL: newURL, createdAt: recording.createdAt, title: newName, duration: recording.duration)
                recordings[index] = updatedRecording
            }
        } catch {
            print("Failed to rename recording: \(error)")
        }
    }
}
