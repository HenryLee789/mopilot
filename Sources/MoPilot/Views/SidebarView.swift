import AppKit
import SwiftUI

struct SidebarView: View {
    @Binding var selection: AppSection?
    let cliInstalled: Bool
    @State private var collapsedGroups: Set<SidebarGroup> = []
    @State private var isSettingsHovered = false

    var body: some View {
        VStack(spacing: 0) {
            List(selection: $selection) {
                Section {
                    brandHeader
                        .listRowSeparator(.hidden)
                }

                ForEach(SidebarGroup.allCases.filter { $0 != .system }) { group in
                    if group == .main {
                        ForEach(group.sections) { section in
                            sidebarRow(section)
                        }
                    } else if !group.sections.isEmpty {
                        sectionHeader(group)
                        if !collapsedGroups.contains(group) {
                            ForEach(group.sections) { section in
                                sidebarRow(section)
                            }
                        }
                    }
                }
            }
            .listStyle(.sidebar)

            Divider().opacity(0.4)
            settingsFooter
            cliStatusFooter
        }
        .navigationSplitViewColumnWidth(min: 210, ideal: 230, max: 270)
    }

    private var brandHeader: some View {
        HStack(spacing: 10) {
            ZStack {
                AppIconThumbnail()
            }
            .frame(width: 36, height: 36)
            .shadow(color: MoPilotPalette.blue.opacity(0.18), radius: 8, y: 5)

            VStack(alignment: .leading, spacing: 2) {
                Text("MoPilot")
                    .font(.headline.weight(.bold))
                Text("mo GUI Wrapper")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .textCase(nil)
        .padding(.vertical, 10)
    }

    private func sectionHeader(_ group: SidebarGroup) -> some View {
        let isCollapsed = collapsedGroups.contains(group)
        return SidebarSectionHeader(group: group, isCollapsed: isCollapsed) {
            withAnimation(.easeInOut(duration: 0.18)) {
                if isCollapsed {
                    collapsedGroups.remove(group)
                } else {
                    collapsedGroups.insert(group)
                }
            }
        }
        .listRowSeparator(.hidden)
    }

    private func sidebarRow(_ section: AppSection) -> some View {
        SidebarItem(
            section: section,
            isSelected: selection == section,
            isEnabled: isEnabled(section)
        )
        .tag(section)
        .disabled(!isEnabled(section))
    }

    private var settingsFooter: some View {
        let isSelected = selection == .settings
        return Button {
            selection = .settings
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "gearshape")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(isSelected || isSettingsHovered ? MoPilotTheme.settings.accentColor : Color.secondary)
                    .scaleEffect(isSettingsHovered ? 1.08 : 1)
                Text("Settings")
                    .font(.system(size: 13, weight: .medium))
                Spacer()
                Text("v0.6.2")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(isSelected || isSettingsHovered ? Color.primary : Color.primary.opacity(0.82))
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(settingsFooterFill(isSelected: isSelected))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isSettingsHovered ? MoPilotTheme.settings.accentColor.opacity(0.22) : Color.clear, lineWidth: 1)
        )
        .scaleEffect(isSettingsHovered ? 1.012 : 1)
        .offset(x: isSettingsHovered ? 2 : 0)
        .pointingHandOnHover()
        .onHover { isSettingsHovered = $0 }
        .animation(.easeOut(duration: 0.14), value: isSettingsHovered)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
    }

    private func settingsFooterFill(isSelected: Bool) -> Color {
        if isSelected {
            return MoPilotTheme.settings.accentColor.opacity(0.14)
        }
        if isSettingsHovered {
            return MoPilotTheme.settings.accentColor.opacity(0.08)
        }
        return Color.clear
    }

    private var cliStatusFooter: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(cliInstalled ? "Mole CLI 已连接" : "未检测到 mo", systemImage: cliInstalled ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(cliInstalled ? MoPilotPalette.mint : MoPilotPalette.amber)
            Text("非官方 GUI，只调用本机 Mole CLI。")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(MoPilotSuperEllipse(cornerRadius: 16))
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private func isEnabled(_ section: AppSection) -> Bool {
        cliInstalled || section == .dashboard || section == .settings
    }
}

private struct SidebarSectionHeader: View {
    let group: SidebarGroup
    let isCollapsed: Bool
    let toggle: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: toggle) {
            HStack(spacing: 6) {
                Image(systemName: isCollapsed ? "chevron.right" : "chevron.down")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(isHovered ? Color.primary.opacity(0.68) : Color.secondary)
                    .frame(width: 14)
                    .offset(x: isHovered ? 1 : 0)
                Text(group.title.uppercased())
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(isHovered ? Color.primary.opacity(0.70) : Color.secondary)
                Spacer()
            }
            .padding(.horizontal, 5)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(isHovered ? Color.primary.opacity(0.055) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .pointingHandOnHover()
        .onHover { isHovered = $0 }
        .animation(.easeOut(duration: 0.14), value: isHovered)
        .padding(.top, 6)
    }
}

private struct AppIconThumbnail: View {
    var body: some View {
        Group {
            if let image = Self.image {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(MoPilotPalette.smartGradient)
                    Image(systemName: "sparkles")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private static var image: NSImage? {
        if let namedImage = NSImage(named: "AppIcon") {
            return namedImage
        }
        if let pngURL = Bundle.main.url(forResource: "AppIcon", withExtension: "png") {
            return NSImage(contentsOf: pngURL)
        }
        if let icnsURL = Bundle.main.url(forResource: "AppIcon", withExtension: "icns") {
            return NSImage(contentsOf: icnsURL)
        }
        return nil
    }
}
