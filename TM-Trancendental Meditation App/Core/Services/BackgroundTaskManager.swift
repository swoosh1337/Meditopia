import Foundation
import AVFoundation
import UIKit

/// Manages background tasks and audio to keep the app running when in background
class BackgroundTaskManager {
    private static let shared = BackgroundTaskManager()
    
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var audioPlayer: AVAudioPlayer?
    private var isBackgroundAudioPlaying = false
    
    // Timer to periodically extend the background task
    private var keepAliveTimer: Timer?
    
    static func startBackgroundSupport() {
        shared.setupAudioSession()
        shared.startBackgroundTask()
        shared.startSilentAudio()
    }
    
    static func stopBackgroundSupport() {
        shared.stopSilentAudio()
        shared.stopBackgroundTask()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func startBackgroundTask() {
        // If there's already a task running, end it first
        stopBackgroundTask()
        
        // Start a new background task
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.stopBackgroundTask()
        }
        
        // Start a timer to periodically report activity to prevent early termination
        keepAliveTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            if let self = self, self.backgroundTask != .invalid {
                // Print debug info
                print("Background time remaining: \(UIApplication.shared.backgroundTimeRemaining)")
                
                // Recreate the background task if needed
                if UIApplication.shared.backgroundTimeRemaining < 30 {
                    self.startBackgroundTask()
                }
            }
        }
    }
    
    private func stopBackgroundTask() {
        // Stop the keep-alive timer
        keepAliveTimer?.invalidate()
        keepAliveTimer = nil
        
        // End the background task if it's valid
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    
    private func startSilentAudio() {
        guard audioPlayer == nil && !isBackgroundAudioPlaying else { return }
        
        do {
            // Generate 10 seconds of silence
            let silenceURL = Bundle.main.url(forResource: "silence", withExtension: "mp3") ?? createSilenceFile()
            audioPlayer = try AVAudioPlayer(contentsOf: silenceURL)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.volume = 0.01
            audioPlayer?.play()
            
            isBackgroundAudioPlaying = true
        } catch {
            print("Could not start audio: \(error)")
        }
    }
    
    private func stopSilentAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
        isBackgroundAudioPlaying = false
    }
    
    private func createSilenceFile() -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let silenceURL = tempDir.appendingPathComponent("silence.mp3")
        
        // Check if we already created the silence file
        if FileManager.default.fileExists(atPath: silenceURL.path) {
            return silenceURL
        }
        
        // Create a simple MP3 file with near-silence
        if let silenceData = Data(base64Encoded: "SUQzBAAAAAAAF1RJVDIAAAAZAAAAc2lsZW5jZSBmb3IgaU9TAAAAAAAAAAAAAAAA//tQxAAAAAAAAAAAAAAAAAAAAAAASW5mbwAAAA8AAAAFAAAESAAkJCQkJCQkJCQkJCQkJDw8PDw8PDw8PDw8PDw8VVVVVVVVVVVVVVVVVVVnZ2dnZ2dnZ2dnZ2dnZ2d5eXl5eXl5eXl5eXl5eXl5//////////////////////////////////////////////////////////////////8AAAA5TEFNRTMuMTAwAZYAAAAAAAAAABQ4JAMGQgAAOAAAACTI4qzbAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA//sQxAACUmYlC0MMABYh6RzjMYYBAAAADQAAAAAnqJRrZdAGADAMDAwMDAwMDAwMDAwMDAwMD//////////////////////////////////////////////////////////////////AAEg//sQxBYAUlI5HYGGAAo5WnvBAYAAAAANAAAAAP///////////////////////////////////////////////////////////////////////////////////////////wAAUg==") {
            try? silenceData.write(to: silenceURL)
        }
        
        return silenceURL
    }
} 