import Foundation

struct Recording: Identifiable, Equatable {
    let id: UUID
    let fileURL: URL
    let createdAt: Date
    let title: String
    let duration: TimeInterval
    
    init(fileURL: URL, createdAt: Date, title: String? = nil, duration: TimeInterval) {
        self.id = UUID()
        self.fileURL = fileURL
        self.createdAt = createdAt
        self.title = title ?? fileURL.deletingPathExtension().lastPathComponent
        self.duration = duration
    }
}
