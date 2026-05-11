import SwiftUI

struct ContentView: View {
    @StateObject var audioRecorderManager = AudioRecorderManager()
    @StateObject var recordingsViewModel = RecordingsViewModel()
    @StateObject var audioPlayerManager = AudioPlayerManager()
    
    @State private var selectedRecording: Recording?
    @State private var searchText = ""
    
    // Rename state
    @State private var showRenameAlert = false
    @State private var recordingToRename: Recording?
    @State private var newRecordingName = ""
    
    // Delete state
    @State private var showDeleteAlert = false
    @State private var recordingToDelete: Recording?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.white // Background #FFFFFF
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                headerView
                searchBar
                tabsView
                
                ScrollView {
                    if filteredRecordings.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Text("No voices available")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 80)
                    } else {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredRecordings) { recording in
                                recordingRow(recording: recording)
                            }
                        }
                        .padding(.bottom, 120) // Give space for floating card or record button
                    }
                }
                .padding(.top, 8)
            }
            
            floatingArea
        }
        .navigationBarHidden(true)
        .alert("Delete Recording", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let recording = recordingToDelete {
                    withAnimation {
                        if selectedRecording?.id == recording.id {
                            audioPlayerManager.stop()
                            selectedRecording = nil
                        }
                        recordingsViewModel.deleteRecording(recording)
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete this recording?")
        }
        .alert("Rename Recording", isPresented: $showRenameAlert) {
            TextField("New name", text: $newRecordingName)
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                if let recording = recordingToRename {
                    withAnimation {
                        recordingsViewModel.renameRecording(recording, newName: newRecordingName)
                        if selectedRecording?.id == recording.id {
                            selectedRecording = recordingsViewModel.recordings.first(where: { $0.id == recording.id }) ?? recording
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var filteredRecordings: [Recording] {
        if searchText.isEmpty {
            return recordingsViewModel.recordings
        } else {
            return recordingsViewModel.recordings.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        HStack {
            Text("My Voices")
                .font(.system(size: 34, weight: .bold))
            Spacer()
            HStack(spacing: 16) {
                Image(systemName: "plus")
                Image(systemName: "list.bullet.rectangle.portrait")
                Image(systemName: "gearshape")
            }
            .font(.system(size: 22, weight: .regular))
            .foregroundColor(.black)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(.leading, 12)
            
            TextField("Search", text: $searchText)
                .font(.system(size: 16))
            
            Button(action: {}) {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 12))
                    Text("Ask AI")
                        .font(.system(size: 12, weight: .bold))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                .foregroundColor(.black)
            }
            .padding(.trailing, 4)
        }
        .frame(height: 44)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(22)
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
    
    private var tabsView: some View {
        HStack(spacing: 12) {
            Text("All")
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(UIColor.systemGray5))
                .foregroundColor(.black)
                .clipShape(Capsule())
            
            Text("Shared")
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(UIColor.systemGray6))
                .foregroundColor(.gray)
                .clipShape(Capsule())
            
            Text("Starred")
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(UIColor.systemGray6))
                .foregroundColor(.gray)
                .clipShape(Capsule())
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
    
    @ViewBuilder
    private var floatingArea: some View {
        if audioRecorderManager.isRecording {
            FloatingRecordingCard(audioRecorderManager: audioRecorderManager) {
                audioRecorderManager.stopRecording()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    recordingsViewModel.fetchRecordings()
                }
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: audioRecorderManager.isRecording)
        } else {
            // Main start record button
            Button(action: {
                #if os(iOS)
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                #endif
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    audioRecorderManager.startRecording()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 60, height: 60)
                    Image(systemName: "mic.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                }
            }
            .padding(.bottom, 24)
            .transition(.scale.combined(with: .opacity))
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: audioRecorderManager.isRecording)
        }
    }
    
    private func recordingRow(recording: Recording) -> some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                Text(formatDate(recording.createdAt))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                Text(recording.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(2)
                
                if selectedRecording?.id == recording.id {
                    HStack(spacing: 12) {
                        // Expanded Playback Capsule
                        HStack(spacing: 12) {
                            Button(action: {
                                #if os(iOS)
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                #endif
                                if audioPlayerManager.isPlaying {
                                    audioPlayerManager.pause()
                                } else {
                                    audioPlayerManager.play()
                                }
                            }) {
                                Image(systemName: audioPlayerManager.isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                            }
                            
                            let duration = max(audioPlayerManager.duration, recording.duration, 0.1)
                            Slider(value: Binding(get: {
                                min(audioPlayerManager.progress, duration)
                            }, set: { newValue in
                                audioPlayerManager.seek(to: newValue)
                            }), in: 0...duration)
                            .tint(.black)
                            
                            Text(timeString(time: recording.duration))
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(UIColor.systemGray6))
                        .clipShape(Capsule())
                        
                        // Trailing circular icons
                        HStack(spacing: 8) {
                            Button(action: {
                                recordingToRename = recording
                                newRecordingName = recording.title
                                showRenameAlert = true
                            }) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                                    .frame(width: 36, height: 36)
                                    .background(Color(UIColor.systemGray6))
                                    .clipShape(Circle())
                            }
                            
                            Button(action: {}) {
                                Image(systemName: "wand.and.stars")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                                    .frame(width: 36, height: 36)
                                    .background(Color(UIColor.systemGray6))
                                    .clipShape(Circle())
                            }
                            
                            Button(action: {}) {
                                Image(systemName: "paperplane")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                                    .frame(width: 36, height: 36)
                                    .background(Color(UIColor.systemGray6))
                                    .clipShape(Circle())
                            }
                            
                            Button(action: {
                                recordingToDelete = recording
                                showDeleteAlert = true
                            }) {
                                Image(systemName: "trash")
                                    .font(.system(size: 14))
                                    .foregroundColor(.red)
                                    .frame(width: 36, height: 36)
                                    .background(Color(UIColor.systemGray6))
                                    .clipShape(Circle())
                            }
                        }
                    }
                } else {
                    // Default collapsed view
                    HStack {
                        HStack(spacing: 6) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 10))
                            Text(timeString(time: recording.duration))
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(UIColor.systemGray6))
                        .clipShape(Capsule())
                        
                        Spacer()
                        
                        HStack(spacing: 20) {
                            Button(action: {
                                recordingToRename = recording
                                newRecordingName = recording.title
                                showRenameAlert = true
                            }) {
                                Image(systemName: "pencil")
                                    .foregroundColor(.gray)
                            }
                            
                            Button(action: {}) {
                                Image(systemName: "paperplane")
                                    .foregroundColor(.gray)
                            }
                            
                            Button(action: {
                                recordingToDelete = recording
                                showDeleteAlert = true
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                        .font(.system(size: 16))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)
            .contentShape(Rectangle())
            .onTapGesture {
                if selectedRecording?.id == recording.id {
                    withAnimation {
                        selectedRecording = nil
                        audioPlayerManager.stop()
                    }
                } else {
                    withAnimation {
                        selectedRecording = recording
                        audioPlayerManager.loadAndPlay(url: recording.fileURL)
                    }
                }
            }
            
            Divider()
        }
    }
    
    private func timeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d · h:mm a"
        return formatter.string(from: date)
    }
}
