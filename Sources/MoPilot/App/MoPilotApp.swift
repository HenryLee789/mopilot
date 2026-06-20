import AppKit
import SwiftUI

@main
struct MoPilotApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var appState = MoleAppState()

    var body: some Scene {
        WindowGroup("MoPilot") {
            ContentView()
                .environmentObject(appState)
                .frame(minWidth: 1280, minHeight: 800)
        }
        .commands {
            CommandGroup(replacing: .newItem) {}
        }

        Settings {
            SettingsView()
                .environmentObject(appState)
                .frame(width: 560, height: 420)
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}
