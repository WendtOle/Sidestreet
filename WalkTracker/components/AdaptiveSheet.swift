//
//  Props to https://fatbobman.com/en/snippet/how-to-make-a-swiftui-sheet-automatically-adjust-height/
//

import SwiftUI

struct SheetWrapper<Content: View>: View {
    @Binding var isPresented: Bool
    let title: String
    let exitTitle: String
    let content: Content

    init(
        isPresented: Binding<Bool>,
        title: String,
        exitTitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        _isPresented = isPresented
        self.title = title
        self.content = content()
        self.exitTitle = exitTitle ?? "Done"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()

                Button(exitTitle) {
                    isPresented = false
                }
            }

            Text(title)
                .font(.title)
                .padding(.bottom, 16)

            content
        }
        .padding(20)
    }
}

extension View {
    func adaptiveSheet<SheetContent: View>(
        isPresent: Binding<Bool>,
        title: String,
        exitTitle: String? = nil,
        @ViewBuilder sheetContent: () -> SheetContent
    ) -> some View {
        modifier(
            AdaptiveSheetModifier(isPresented: isPresent) {
                SheetWrapper(
                    isPresented: isPresent,
                    title: title,
                    exitTitle: exitTitle
                ) {
                        sheetContent()
                    }
            }
        )
    }
}

struct AdaptiveSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    @State private var sheetHeight: CGFloat = 0

    let sheetContent: SheetContent

    init(
        isPresented: Binding<Bool>,
        @ViewBuilder _ content: () -> SheetContent
    ) {
        _isPresented = isPresented
        sheetContent = content()
    }

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                sheetContent
                    // Let the wrapper use its natural height.
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .task(id: proxy.size.height) {
                                    let height = ceil(proxy.size.height)

                                    if height > 0, height != sheetHeight {
                                        sheetHeight = height
                                    }
                                }
                        }
                    )
                    // Apply this after measuring the content.
                    .frame(maxHeight: .infinity, alignment: .top)
                    .presentationDetents(
                        sheetHeight > 0
                            ? [.height(sheetHeight)]
                            : [.large]
                    )
            }
    }
}
