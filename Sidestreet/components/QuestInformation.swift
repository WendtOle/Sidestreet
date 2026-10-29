import SwiftUI

struct QuestInformation: View {
    let quest: QuestData
    
    var body: some View {
        HStack {
            Image(systemName: quest.type.symbol)
                .frame(width: 35)
            VStack(alignment: .leading) {
                Text(quest.type.name)
                    .font(.headline)
                HStack {
                    Text(
                        quest.createdAt,
                        format: .dateTime.day().month(.twoDigits).year()
                    )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("-")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(quest.createdAt, style: .time)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
    }
}
