import SwiftUI

struct SidebarView: View {
    @Binding var selection: AppSection?
    let cliInstalled: Bool

    var body: some View {
        List(selection: $selection) {
            Section {
                ForEach(AppSection.sidebarSections) { section in
                    SidebarItem(
                        section: section,
                        isSelected: selection == section,
                        isEnabled: isEnabled(section)
                    )
                    .tag(section)
                    .disabled(!isEnabled(section))
                }
            } header: {
                brandHeader
            }
        }
        .listStyle(.sidebar)
        .navigationSplitViewColumnWidth(min: 220, ideal: 248, max: 280)
        .safeAreaInset(edge: .bottom) {
            cliStatusFooter
        }
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
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private func isEnabled(_ section: AppSection) -> Bool {
        cliInstalled || section == .dashboard || section == .settings
    }
}
