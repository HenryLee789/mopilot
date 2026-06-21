import SwiftUI

struct LogOutputView: View {
    let text: String

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                Text(text.isEmpty ? "暂无日志输出" : text)
                    .font(.system(.callout, design: .monospaced))
                    .textSelection(.enabled)
                    .foregroundStyle(text.isEmpty ? .secondary : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .id("log-end")
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(nsColor: .textBackgroundColor).opacity(0.62),
                        MoPilotPalette.blue.opacity(0.045),
                        MoPilotPalette.violet.opacity(0.035)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(MoPilotPalette.blue.opacity(0.16), lineWidth: 1)
            }
            .onChange(of: text) { _ in
                withAnimation(.easeOut(duration: 0.15)) {
                    proxy.scrollTo("log-end", anchor: .bottom)
                }
            }
        }
        .frame(minHeight: 280)
    }
}
