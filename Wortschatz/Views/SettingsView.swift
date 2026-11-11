import SwiftUI

struct SettingsView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.appTheme) private var theme
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    Eyebrow(text: "Make yourself at home").padding(.top, 20)
                    Text("A different\nkind of mood.")
                        .font(.system(size: 40, weight: .medium, design: .serif)).tracking(-1)
                    Text("Choose your palette and your learning level.")
                        .font(.subheadline).foregroundStyle(theme.muted)
                    VStack(alignment: .leading, spacing: 14) {
                        Eyebrow(text: "Appearance")
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 3), spacing: 18) {
                            ForEach([AppTheme.dark, .green, .blue, .dusk, .warm, .cold]) { option in
                                Button {
                                    store.theme = option
                                    UISelectionFeedbackGenerator().selectionChanged()
                                } label: {
                                    VStack(spacing: 8) {
                                        ZStack(alignment: .topTrailing) {
                                            RoundedRectangle(cornerRadius: 16).fill(option.paper)
                                            VStack(alignment: .leading, spacing: 6) {
                                                Text("Aa").font(.system(.title2, design: .serif)).foregroundStyle(option.ink)
                                                Capsule().fill(option.accent).frame(width: 25, height: 4)
                                            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                                            if store.theme == option {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.caption).foregroundStyle(option.accent)
                                                    .padding(6)
                                            }
                                        }.frame(height: 76)
                                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(store.theme == option ? theme.accent : theme.line, lineWidth: store.theme == option ? 2 : 1))
                                        Text(option.title).font(.caption.weight(.medium)).foregroundStyle(theme.ink)
                                            .lineLimit(1).minimumScaleFactor(0.8)
                                    }.frame(maxWidth: .infinity)
                                }.buttonStyle(.plain)
                                    .accessibilityLabel("\(option.title) theme")
                                    .accessibilityValue(store.theme == option ? "Selected" : "Not selected")
                                    .accessibilityAddTraits(store.theme == option ? .isSelected : [])
                            }
                        }.padding(2).accessibilityIdentifier("themeChoices")
                    }
                    VStack(alignment: .leading, spacing: 14) {
                        Eyebrow(text: "Your German level")
                        Text("What is your current level?").font(.headline)
                        Picker("Current German level", selection: Binding(get: { store.studyLevel }, set: { store.studyLevel = $0 })) {
                            ForEach(StudyLevel.allCases) { level in Text(level.rawValue).tag(level) }
                        }.pickerStyle(.segmented).accessibilityIdentifier("studyLevelPicker")
                        Text("The featured word on Explore will match your level and come from outside your study deck.")
                            .font(.subheadline).foregroundStyle(theme.muted)
                    }.padding(20).background(theme.surface, in: RoundedRectangle(cornerRadius: 22))
                    Label("Your preferences are saved on this device.", systemImage: "iphone")
                        .font(.caption).foregroundStyle(theme.muted)
                }.padding(24).frame(maxWidth: 620).frame(maxWidth: .infinity)
            }.background(theme.paper).navigationTitle("Settings").navigationBarTitleDisplayMode(.inline)
        }
    }
}
