import SwiftUI
import SwiftData
import UIKit

struct TutorialView: View {
    let settings: SettingsData
    @Binding var isPresented: Bool

    @Environment(\.modelContext) private var modelContext
    
    @Query(filter: #Predicate<SettingsData> { $0.key == "app" })
    private var settingsRecords: [SettingsData]
    
    @State private var selectedPage = 0

    private let pages = TutorialPage.all

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: 0xBA9CBF),
                    Color(hex: 0xAF8CB5),
                    Color(hex: 0xA47DAB),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack() {
                Spacer()
                
                TabView(selection: $selectedPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        TutorialScreenshot(page: page)
                            .tag(index)
                    }
                }
                .shadow(
                    color: .black.opacity(0.28),
                    radius: 16,
                    x: 0,
                    y: 4
                )
                .frame(height: 650)
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(pages[selectedPage].title)
                        .font(.headline)
                    Text(pages[selectedPage].description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack {
                        if let settings = settingsRecords.first {
                            @Bindable var settings = settings
                            Button("Dismiss") {
                                isPresented = false
                                settings.introDismissed = true
                            }
                            .buttonStyle(.plain)
                        }
                        Spacer()
                        if selectedPage < pages.count - 1 {
                            Button("Continue") {
                                
                                selectedPage += 1
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(16)
                .glassEffect(in: .rect(cornerRadius: 20))
                .padding(8)
            }
            .overlay(alignment: .bottom) {
                HStack(spacing: 6) {
                    ForEach(pages.indices, id: \.self) { index in
                        Button {
                            withAnimation {
                                selectedPage = index
                            }
                        } label: {
                            Circle()
                                .fill(
                                    index == selectedPage
                                    ? Color.gray
                                    : Color.gray.opacity(0.25)
                                )
                                .frame(width: 8, height: 8) // Dot size
                                .frame(width: 28, height: 28) // Tap area
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Page \(index + 1)")
                        .accessibilityAddTraits(
                            index == selectedPage ? .isSelected : []
                        )
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .glassEffect(in: .capsule)
                .padding(.vertical, 4)
            }
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }
}

private struct TutorialScreenshot: View {
    let page: TutorialPage

    var body: some View {
        GeometryReader { geometry in
            Group {
                if let image = UIImage(named: page.assetName) {
                    
                    let scale = min(
                        geometry.size.width / image.size.width,
                        geometry.size.height / image.size.height
                    )

                    let width = image.size.width * scale
                    let height = image.size.height * scale
                    let cropTop = min(CGFloat(24), height) // Adjust crop amount
                    
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: width, height: height)
                        .offset(y: -cropTop)
                        .frame(
                            width: width,
                            height: height - cropTop,
                            alignment: .top
                        )
                        .clipShape(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                        )
                } else {
                    Rectangle()
                        .fill(Color.accentColor.opacity(0.06))
                        .overlay {
                            VStack(spacing: 12) {
                                Image(systemName: "photo")
                                    .font(.system(size: 32, weight: .ultraLight))
                                Text(page.title)
                                    .font(.title3.weight(.medium))
                            }
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("\(page.title). Screenshot placeholder.")
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

private struct TutorialPage {
    let assetName: String
    let title: String
    let description: String

    static let all: [TutorialPage] = [
        .init(
            assetName: "tutorial-start-walk",
            title: "Welcome to Sidestreet",
            description: "Tap Play and head out for a walk. Explore familiar streets or discover somewhere new."
        ),
        .init(
            assetName: "tutorial-walk-recording",
            title: "Ready for a challenge?",
            description: "See your route, distance, and time as you walk. Tap ‘Take on a Challenge?’ whenever you feel like adding a goal."
        ),
        .init(
            assetName: "tutorial-create-challenge",
            title: "Choose your adventure",
            description: "Choose a challenge that suits your mood, then pick a short or long adventure."
        ),
        .init(
            assetName: "tutorial-fullfill-challenge",
            title: "Explore at your own pace",
            description: "Work toward your challenge’s goal as you explore. Your blue trail shows where you’ve been. Tap Stop when you’re ready to finish your walk."
        ),
        .init(
            assetName: "tutorial-review-walk",
            title: "Look back on your walk",
            description: "Finish your walk to see the route you took, how far you went, and how long you were out. If you took on a challenge, you’ll see the result here too."
        ),
        .init(
            assetName: "tutorial-past-walks",
            title: "See how far you’ve come",
            description: "Open your history to revisit past walks and see your weekly totals. Tap a walk to take a closer look at its route and details."
        )
    ]
}
