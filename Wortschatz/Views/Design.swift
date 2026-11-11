import SwiftUI

struct Eyebrow: View {
    @Environment(\.appTheme) private var theme
    let text: String
    var body: some View { Text(text.uppercased()).font(.system(.caption, design: .monospaced).weight(.semibold)).tracking(2).foregroundStyle(theme.muted) }
}
struct PrimaryButton: View {
    @Environment(\.appTheme) private var theme
    let title: String
    var icon: String = "arrow.right"
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack { Text(title); Spacer(); Image(systemName: icon) }
                .font(.headline).padding(19).foregroundStyle(theme.onAction)
                .background(theme.action, in: RoundedRectangle(cornerRadius: 19))
        }.buttonStyle(.plain)
    }
}
struct WordRow: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.appTheme) private var theme
    @Environment(AppStore.self) private var store
    let entry: WordEntry
    var body: some View {
        HStack(spacing: 14) {
            NavigationLink(value: entry) {
                HStack(spacing: 14) {
                    Text(entry.badgeText)
                        .font(.system(entry.article == nil ? .title3 : .subheadline, design: .serif).weight(.medium))
                        .foregroundStyle(entry.nounGender.map(theme.nounColor) ?? theme.accent).frame(width: 48, height: 52)
                        .background((entry.nounGender.map(theme.nounColor) ?? theme.accent).opacity(0.07), in: RoundedRectangle(cornerRadius: 13))
                    VStack(alignment: .leading, spacing: 5) {
                        Text(entry.headword).font(.system(.title3, design: .serif).weight(.semibold)).foregroundStyle(theme.wordColor(entry)).lineLimit(2)
                        Text(entry.meaning).font(.subheadline).foregroundStyle(theme.muted).lineLimit(2)
                    }
                    Spacer(minLength: 0)
                    Text(entry.level).font(.caption2.weight(.medium)).foregroundStyle(theme.muted)
                }.contentShape(Rectangle())
            }.buttonStyle(.plain).accessibilityIdentifier("wordResult-\(entry.id)").accessibilityValue(entry.level)
            Button {
                withAnimation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.8)) { store.toggle(entry) }
            } label: {
                Image(systemName: store.contains(entry) ? "checkmark" : "plus")
                    .contentTransition(reduceMotion ? .identity : .symbolEffect(.replace))
                    .symbolEffect(.bounce, options: .nonRepeating, value: !reduceMotion && store.contains(entry))
                    .font(.system(size: 15, weight: .semibold)).frame(width: 44, height: 44)
                    .foregroundStyle(store.contains(entry) ? theme.onAction : theme.accent)
                    .background(store.contains(entry) ? theme.action : theme.accent.opacity(0.06), in: Circle())
            }.buttonStyle(.plain)
                .accessibilityLabel(store.contains(entry) ? "Remove \(entry.headword) from deck" : "Add \(entry.headword) to deck")
        }.padding(.vertical, 13)
    }
}
struct EmptyState: View {
    @Environment(\.appTheme) private var theme
    let icon: String
    let title: String
    let detail: String
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon).font(.system(size: 42, weight: .light)).foregroundStyle(theme.accent).padding(24)
                .background(theme.accent.opacity(0.07), in: RoundedRectangle(cornerRadius: 28))
            Text(title).font(.system(.title2, design: .serif).weight(.semibold))
            Text(detail).font(.subheadline).foregroundStyle(theme.muted).multilineTextAlignment(.center)
        }.frame(maxWidth: .infinity).padding(.vertical, 48)
    }
}

struct NounGenderKey: View {
    @Environment(\.appTheme) private var theme
    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 16) { labels }
            VStack(alignment: .leading, spacing: 8) { labels }
        }
        .font(.caption)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Noun colors: der, masculine, blue; die, feminine, red; das, neuter, green")
    }
    private var labels: some View {
        ForEach(NounGender.allCases, id: \.self) { gender in
            HStack(spacing: 5) {
                Circle().fill(theme.nounColor(gender)).frame(width: 6, height: 6)
                Text(gender.article).fontWeight(.semibold)
                Text(gender.rawValue)
            }.foregroundStyle(theme.nounColor(gender))
        }
    }
}
