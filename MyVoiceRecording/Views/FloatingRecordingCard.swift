import SwiftUI

struct FloatingRecordingCard: View {
    @ObservedObject var audioRecorderManager: AudioRecorderManager
    var onDone: () -> Void
    
    var body: some View {
        ZStack(alignment: .top) {
            // Main Card Body
            VStack(spacing: 0) {
                // Waveform Pill
                ZStack {
                    Capsule()
                        .fill(Color(red: 0.93, green: 0.93, blue: 0.95)) // Light gray background
                        .frame(height: 64)
                    
                    LiveWaveformView(powerLevels: audioRecorderManager.powerLevels)
                        .clipShape(Capsule())
                        .frame(height: 64)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "pause.fill")
                            .font(.system(size: 14, weight: .bold))
                        Text(timeString(time: audioRecorderManager.recordingDuration))
                            .font(.system(size: 16, weight: .bold))
                            .monospacedDigit()
                    }
                    .foregroundColor(.black)
                }
                .padding(.horizontal, 24)
                .padding(.top, 32) // Space inside the card before pill
                .padding(.bottom, 16)
                
                // Done Button
                Button(action: {
                    #if os(iOS)
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    #endif
                    onDone()
                }) {
                    HStack {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                        Text("Done")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(red: 0.89, green: 0.96, blue: 0.92)) // Light green
                    .foregroundColor(Color(red: 0.17, green: 0.41, blue: 0.31)) // Dark green
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .background(Color.white)
            .cornerRadius(32)
            .padding(.top, 18) // Shift down so the bump sticks out halfway
            
            // The top bump with chevron
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 36, height: 36)
                Image(systemName: "chevron.up")
                    .foregroundColor(Color(UIColor.tertiaryLabel))
                    .font(.system(size: 14, weight: .bold))
            }
        }
        .compositingGroup()
        .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 5)
        .padding(.horizontal, 16)
        .padding(.bottom, 16) // Spacing from bottom safe area
    }
    
    private func timeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
