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
                        Color.black.opacity(0.10),
                        MoPilotPalette.teal.opacity(0.055),
                        Color.black.opacity(0.055)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(MoPilotPalette.teal.opacity(0.16), lineWidth: 1)
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
