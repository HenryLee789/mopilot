import SwiftUI

struct LogOutputView: View {
    let text: String

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                Text(text.isEmpty ? "暂无日志输出" : text)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .id("log-end")
            }
            .background(.quaternary.opacity(0.18))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.quaternary, lineWidth: 1)
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
