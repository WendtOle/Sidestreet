//
//  Props to https://fatbobman.com/en/snippet/how-to-make-a-swiftui-sheet-automatically-adjust-height/
//

import SwiftUI

struct SheetWrapper<Content: View>: View {
    @Binding var isPresented: Bool
    let nullableTitle: String?
    let exitTitle: String
    let content: Content
    let nullableOnPrevious: (() -> Void)?

    init(
        isPresented: Binding<Bool>,
        title: String? = nil,
        exitTitle: String? = nil,
        onPrevious: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        _isPresented = isPresented
        self.nullableTitle = title
        self.content = content()
        self.exitTitle = exitTitle ?? "Done"
        self.nullableOnPrevious = onPrevious
    }

    var body: some View {
        VStack(spacing: 16) {
            if let title = nullableTitle {
                Text(title)
                    .font(.title2)
            }
            content
        }
        .padding(.top, 20)
        .padding(.horizontal, 20)
        .overlay(alignment: .topLeading) {
            if let onPrevious = nullableOnPrevious {
                Button("Back") {
                    onPrevious()
                }
                .buttonStyle(.plain)
                .padding(20)
            }
        }
        .overlay(alignment: .topTrailing) {
            Button(exitTitle) {
                isPresented = false
            }
            .buttonStyle(.plain)
            .padding(20)
        }
    }
}

extension View {
    func adaptiveSheet<SheetContent: View>(
        isPresent: Binding<Bool>,
        title: String? = nil,
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
    
    func adaptiveRawSheet<SheetContent: View>(
        isPresent: Binding<Bool>,
        @ViewBuilder sheetContent: () -> SheetContent
    ) -> some View {
        modifier(
            AdaptiveSheetModifier(isPresented: isPresent) {
                sheetContent()
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
