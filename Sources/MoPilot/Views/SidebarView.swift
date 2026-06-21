import SwiftUI

struct SidebarView: View {
    @Binding var selection: AppSection?
    let cliInstalled: Bool
    @State private var collapsedGroups: Set<SidebarGroup> = []

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
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(MoPilotPalette.smartGradient)
                Image(systemName: "sparkles")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
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
        return HStack(spacing: 6) {
            Image(systemName: isCollapsed ? "chevron.right" : "chevron.down")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.secondary)
                .frame(width: 14)
            Text(group.title.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.top, 6)
        .contentShape(Rectangle())
        .onTapGesture {
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
        Button {
            selection = .settings
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "gearshape")
                    .font(.system(size: 13))
                    .foregroundStyle(selection == .settings ? MoPilotTheme.settings.accentColor : Color.secondary)
                Text("Settings")
                    .font(.system(size: 13, weight: .medium))
                Spacer()
                Text("v0.6.0")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(selection == .settings ? Color.primary.opacity(0.10) : Color.clear)
        )
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
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
