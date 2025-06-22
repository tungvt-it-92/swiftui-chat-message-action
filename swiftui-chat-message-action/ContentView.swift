import SwiftUI

@Observable
class MessageModel: Identifiable {
    let id: Int
    var text: String
    var action: String?

    init(id: Int, text: String, action: String?) {
        self.id = id
        self.text = text
        self.action = action
    }
}

struct MessageGeometryData {
    let message: MessageModel
    let anchor: Anchor<CGRect>
}

struct MessageFramePreferenceKey: PreferenceKey {
    static var defaultValue: [MessageGeometryData] = []

    static func reduce(value: inout [MessageGeometryData], nextValue: () -> [MessageGeometryData]) {
        value += nextValue()
    }
}

struct MessageListView: View {
    @State private var selectedId: Int?
    @Namespace private var namespace
    @State private var messages: [MessageModel] = []

    var body: some View {
        List(messages, id: \.id) { message in
            MessageView(message: message, namespace: namespace, selectedId: $selectedId)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
        }
        .overlayPreferenceValue(MessageFramePreferenceKey.self) { messagesWithGeo in
            GeometryReader { proxy in
                ForEach(messagesWithGeo, id: \.message.id) { msgWithGeo in
                    if msgWithGeo.message.id == selectedId {
                        let frame: CGRect = proxy[msgWithGeo.anchor]
                        ZStack {
                            Color.black
                                .blur(radius: 150)
                                .ignoresSafeArea()
                                .frame(width: proxy.size.width, height: proxy.size.height)
                                .onTapGesture { _ in
                                    withAnimation {
                                        selectedId = nil
                                    }
                                }

                            MessageWithActionView(
                                messageWithGeo: msgWithGeo,
                                namespace: namespace,
                                frame: frame,
                                selectedId: $selectedId
                            )
                        }   
                    }
                }
            }
        }
        .task {
            messages = Array(1...100).map {
                MessageModel(id: $0, text: "Message \($0)", action: nil)
            }
        }
    }
}

struct MessageView: View {
    let message: MessageModel
    let namespace: Namespace.ID
    @Binding var selectedId: Int?

    var body: some View {
        HStack {
            Spacer()

            Text(message.text)
                .padding()
                .background(Color.blue.opacity(0.1))
                .matchedGeometryEffect(id: message.id, in: namespace)
                .onTapGesture {
                    selectedId = message.id
                }
                .contentShape(Rectangle())
                .overlay(alignment: .bottomTrailing) {
                    if let action = message.action {
                        Text(action)
                            .padding(4)
                            .background(Color.clear)
                            .cornerRadius(6)
                            .offset(x: 10, y: 10)
                    }
                }
                .anchorPreference(key: MessageFramePreferenceKey.self, value: .bounds) { anchor in
                    [MessageGeometryData(message: message, anchor: anchor)]
                }

            Spacer()
        }
    }
}

struct MessageWithActionView: View {
    let messageWithGeo: MessageGeometryData
    let namespace: Namespace.ID
    let frame: CGRect
    @Binding var selectedId: Int?

    @State private var overlayAnimating = false
    @State private var showActions = false

    private var shouldMoveDown: Bool {
        frame.minY < 100
    }

    var body: some View {
        Text(messageWithGeo.message.text)
            .padding()
            .background(Color.yellow)
            .cornerRadius(8)
            .matchedGeometryEffect(id: messageWithGeo.message.id, in: namespace)
            .frame(maxWidth: .infinity)
            .onTapGesture {
                withAnimation {
                    selectedId = nil
                }
            }
            .overlay {
                if showActions {
                    reactionButtons
                        .transition(.scale(scale: 0.8).combined(with: .opacity))
                        .offset(y: -60)
                }
            }
            .position(
                x: frame.midX,
                y: frame.midY + (overlayAnimating ? (shouldMoveDown ? 50 : -50) : 0)
            )
            .task {
                try? await Task.sleep(nanoseconds: 100_000_000)
                withAnimation(.easeOut(duration: 0.3)) {
                    overlayAnimating = true
                }

                try? await Task.sleep(nanoseconds: 400_000_000)
                withAnimation(.easeIn(duration: 0.2)) {
                    showActions = true
                }
            }
            .onDisappear {
                overlayAnimating = false
                showActions = false
            }
    }

    private var reactionButtons: some View {
        HStack(spacing: 12) {
            ForEach(["❤️", "👎", "👍", "🤣", "🤬", "😭", "😱"], id: \.self) { emoji in
                Button {
                    withAnimation {
                        messageWithGeo.message.action = emoji
                        selectedId = nil
                    }
                } label: {
                    Text(emoji)
                        .font(.title2)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
        )
    }
}

#Preview {
    MessageListView()
}
