import SwiftUI

struct PlaybackControlsView: View {
    @ObservedObject var playerManager: AudioPlayerManager
    var recording: Recording
    
    var body: some View {
        VStack(spacing: 16) {
            Text(recording.title)
                .font(.headline)
            
            Slider(value: Binding(
                get: { playerManager.progress },
                set: { newValue in playerManager.seek(to: newValue) }
            ), in: 0...(playerManager.duration > 0 ? playerManager.duration : recording.duration))
            .accentColor(.blue)
            
            HStack {
                Text(timeString(time: playerManager.progress))
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(timeString(time: recording.duration))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Button(action: {
                if playerManager.isPlaying {
                    playerManager.pause()
                } else {
                    if playerManager.duration == 0 {
                        playerManager.loadAndPlay(url: recording.fileURL)
                    } else {
                        playerManager.play()
                    }
                }
            }) {
                Image(systemName: playerManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .onDisappear {
            playerManager.stop()
        }
        .onAppear {
            playerManager.loadAndPlay(url: recording.fileURL)
        }
    }
    
    private func timeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
