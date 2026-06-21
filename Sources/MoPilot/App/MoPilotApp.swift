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
        relocalizeMainMenu()
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        relocalizeMainMenu()
    }

    private func relocalizeMainMenu() {
        DispatchQueue.main.async { [weak self] in
            self?.localizeMainMenu()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.localizeMainMenu()
        }
    }

    private func localizeMainMenu() {
        guard let mainMenu = NSApp.mainMenu else { return }
        mainMenu.items.forEach(localizeMenuItem)
    }

    private func localizeMenuItem(_ item: NSMenuItem) {
        if let translated = menuTitleTranslations[item.title] {
            item.title = translated
        }
        item.submenu?.items.forEach(localizeMenuItem)
    }

    private var menuTitleTranslations: [String: String] {
        [
            "About MoPilot": "关于 MoPilot",
            "Settings...": "设置...",
            "Settings…": "设置…",
            "Services": "服务",
            "Hide MoPilot": "隐藏 MoPilot",
            "Hide Others": "隐藏其他",
            "Show All": "全部显示",
            "Quit MoPilot": "退出 MoPilot",
            "Edit": "编辑",
            "Undo": "撤销",
            "Redo": "重做",
            "Cut": "剪切",
            "Copy": "复制",
            "Paste": "粘贴",
            "Paste and Match Style": "粘贴并匹配样式",
            "Delete": "删除",
            "Select All": "全选",
            "Substitutions": "替换",
            "Transformations": "转换",
            "Speech": "语音",
            "Start Speaking": "开始朗读",
            "Stop Speaking": "停止朗读",
            "Start Dictation…": "开始听写…",
            "Emoji & Symbols": "表情与符号",
            "View": "显示",
            "Show Toolbar": "显示工具栏",
            "Hide Toolbar": "隐藏工具栏",
            "Customize Toolbar…": "自定义工具栏…",
            "Enter Full Screen": "进入全屏",
            "Exit Full Screen": "退出全屏",
            "Window": "窗口",
            "Minimize": "最小化",
            "Zoom": "缩放",
            "Bring All to Front": "全部置于前台",
            "Help": "帮助",
            "MoPilot Help": "MoPilot 帮助"
        ]
    }
}
