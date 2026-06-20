import SwiftUI

struct SidebarView: View {
    @Binding var selection: AppSection
    let cliInstalled: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            brandHeader

            VStack(alignment: .leading, spacing: 14) {
                sidebarGroup("智能维护", sections: [.dashboard])
                sidebarGroup("清理", sections: [.clean, .analyze])
                sidebarGroup("应用", sections: [.uninstall])
                sidebarGroup("性能", sections: [.optimize, .status])
                sidebarGroup("系统", sections: [.settings])
            }

            Spacer()

            VStack(alignment: .leading, spacing: 6) {
                Label(cliInstalled ? "Mole CLI 已连接" : "Mole CLI 未检测到", systemImage: cliInstalled ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(cliInstalled ? MoPilotPalette.mint : MoPilotPalette.amber)
                Text("MoPilot 只调用本机 mo")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .padding(18)
        .frame(width: 258)
        .background(
            LinearGradient(
                colors: [
                    Color.black.opacity(0.18),
                    MoPilotPalette.violet.opacity(0.12),
                    MoPilotPalette.teal.opacity(0.07)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(.white.opacity(0.08))
                .frame(width: 1)
        }
    }

    private var brandHeader: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(MoPilotPalette.smartGradient)
                Image(systemName: "sparkles")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
            }
            .frame(width: 44, height: 44)
            .shadow(color: MoPilotPalette.blue.opacity(0.2), radius: 10, y: 6)

            VStack(alignment: .leading, spacing: 2) {
                Text("MoPilot")
                    .font(.title3.weight(.bold))
                Text("Smart CLI Care")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private func sidebarGroup(_ title: String, sections: [AppSection]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 10)

            ForEach(sections) { section in
                sidebarRow(section)
            }
        }
    }

    private func sidebarRow(_ section: AppSection) -> some View {
        Button {
            selection = section
        } label: {
            HStack(spacing: 11) {
                Image(systemName: section.systemImage)
                    .font(.system(size: 15, weight: .semibold))
                    .frame(width: 20)
                    .foregroundStyle(selection == section ? .white : sectionAccent(section))

                VStack(alignment: .leading, spacing: 1) {
                    Text(section.shortTitle)
                        .font(.callout.weight(.semibold))
                    Text(section.sidebarSubtitle)
                        .font(.caption2)
                        .foregroundStyle(selection == section ? .white.opacity(0.72) : .secondary)
                        .lineLimit(1)
                }

                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                if selection == section {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(sectionAccent(section).gradient)
                        .shadow(color: sectionAccent(section).opacity(0.22), radius: 12, x: 0, y: 6)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(!cliInstalled && section != .settings && section != .dashboard)
        .opacity((cliInstalled || section == .settings || section == .dashboard) ? 1 : 0.45)
    }

    private func sectionAccent(_ section: AppSection) -> Color {
        switch section {
        case .dashboard:
            return MoPilotPalette.blue
        case .clean:
            return MoPilotPalette.mint
        case .analyze:
            return MoPilotPalette.teal
        case .uninstall:
            return MoPilotPalette.rose
        case .optimize:
            return MoPilotPalette.amber
        case .status:
            return MoPilotPalette.violet
        case .settings:
            return .secondary
        }
    }
}
