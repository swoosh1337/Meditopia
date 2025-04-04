import Foundation
import WatchConnectivity

class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    private let session = WCSession.default
    @Published var isWatchAppInstalled = false
    
    override init() {
        super.init()
        
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }
    
    func sendMeditationCompletedMessage() {
        guard session.activationState == .activated else {
            print("Watch session not active")
            return
        }
        
        // First check if the Watch app is installed
        if session.isWatchAppInstalled {
            isWatchAppInstalled = true
            
            do {
                try session.updateApplicationContext([
                    "meditationCompleted": true,
                    "timestamp": Date().timeIntervalSince1970
                ])
                
                // Also send a more immediate message
                session.sendMessage([
                    "meditationCompleted": true,
                    "timestamp": Date().timeIntervalSince1970
                ], replyHandler: nil) { error in
                    print("Error sending meditation completion to watch: \(error.localizedDescription)")
                }
                
                print("Sent meditation completion to Apple Watch")
            } catch {
                print("Error updating app context: \(error.localizedDescription)")
            }
        } else {
            isWatchAppInstalled = false
            print("Watch app is not installed")
        }
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed with error: \(error.localizedDescription)")
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.isWatchAppInstalled = session.isWatchAppInstalled
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WCSession became inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("WCSession deactivated")
        // Reactivate session if needed
        session.activate()
    }
    
    #if os(iOS)
    func sessionWatchStateDidChange(_ session: WCSession) {
        DispatchQueue.main.async { [weak self] in
            self?.isWatchAppInstalled = session.isWatchAppInstalled
        }
    }
    #endif
} 