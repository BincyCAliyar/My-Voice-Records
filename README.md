# My Voice Records

A modern, beautifully designed iOS application built with SwiftUI and AVFoundation for capturing, managing, and playing back voice recordings. 

The application was carefully crafted to provide an elegant, premium user experience, complete with dynamic liquid animations, haptic feedback, and an intuitive inline playback interface.

## ✨ Features

- **High-Quality Recording:** Utilizes AVFoundation for crisp `.m4a` audio capture.
- **Liquid Waveform Visualization:** A dynamic, physics-based liquid waveform that responds in real-time to microphone input power levels during recording.
- **Background Audio Support:** Continue capturing audio securely even when the app is sent to the background or your device is locked.
- **Playback Controls:** Inline playback controls elegantly expand directly within the recording list, complete with a progress slider.
- **Rename & Delete:** Easily manage your recordings by renaming them natively on the filesystem or sending them to the trash.
- **Real-Time Search:** Instantly filter through your saved voices with a dynamic search bar.
- **Haptic Feedback:** Enjoy tactile responses when starting, stopping, or pausing a recording for a premium feel.
- **Elegant UI/UX:** Built exactly to specification using modern design principles, featuring pill-shaped interactive elements, a clean white background, and fluid `.spring()` animations.

## 🚀 Setup Instructions

To run this project locally, you will need a Mac with Xcode installed.

1. Clone or download this repository to your local machine.
2. Open the `MyVoiceRecording.xcodeproj` file in Xcode (requires Xcode 14+ and targets iOS 16.0+).
3. Select your target device (an iPhone Simulator or a physical iOS device) from the scheme selector at the top.
4. If you are running on a physical device, navigate to the **Signing & Capabilities** tab in your project settings and configure your Apple Developer signing certificate.
5. Hit the **Play** button or press `Cmd + R` to Build and Run the application.

> **Note:** The first time you attempt to record, iOS will prompt you to grant Microphone permissions. You must tap "Allow" for the app to function properly.

## 📱 How to Use

- **Record a Voice:** Tap the large black microphone button on the main dashboard to start recording. A floating dashboard will smoothly appear, displaying your recording duration and the live liquid waveform.
- **Stop Recording:** Tap the red stop button on the floating dashboard or the green 'Done' button to finish and save your recording.
- **Play Back:** Tap on any recording in the list. The row will expand to reveal inline playback controls. Tap play to listen, and drag the slider to scrub through the audio.
- **Search:** Type any text into the search bar at the top of the screen to instantly filter your recordings by their titles.
- **Rename:** Tap on a recording, then tap the pencil icon to rename the file.
- **Delete:** Tap on a recording, then tap the red trash icon to delete it permanently.
