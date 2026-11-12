import SwiftUI

struct SettingsView: View {
    @Environment(\.openURL) private var openURL
    @Environment(AppStore.self) private var store
    @Environment(\.appTheme) private var theme
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 10) {
                        Eyebrow(text: "Appearance")
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                            ForEach(AppTheme.allCases) { option in
                                Button {
                                    store.theme = option
                                    UISelectionFeedbackGenerator().selectionChanged()
                                } label: {
                                    VStack(spacing: 4) {
                                        ZStack(alignment: .topTrailing) {
                                            RoundedRectangle(cornerRadius: 12).fill(option.paper)
                                            VStack(alignment: .leading, spacing: 6) {
                                                Text("Aa").font(.system(.headline, design: .serif)).foregroundStyle(option.ink)
                                                Capsule().fill(option.accent).frame(width: 25, height: 4)
                                            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                                            if store.theme == option {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.caption).foregroundStyle(option.accent)
                                                    .padding(6)
                                            }
                                        }.frame(height: 48)
                                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(store.theme == option ? theme.accent : theme.line, lineWidth: store.theme == option ? 2 : 1))
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
                    VStack(alignment: .leading, spacing: 10) {
                        Eyebrow(text: "Pronunciation")
                        HStack(spacing: 8) {
                            Picker("German voice", selection: Binding(get: { store.speechVoiceID }, set: { store.speechVoiceID = $0 })) {
                                Text("System default").tag("")
                                ForEach(store.speechVoices, id: \.identifier) { voice in
                                    Text(voice.name).tag(voice.identifier)
                                }
                            }.accessibilityIdentifier("speechVoicePicker")
                            Spacer(minLength: 0)
                            Button {
                                store.speak("Hallo! Schön, dass du Deutsch lernst.")
                            } label: {
                                Image(systemName: "speaker.wave.2")
                                    .frame(width: 44, height: 44)
                            }
                            .accessibilityLabel("Preview voice")
                            .accessibilityIdentifier("previewSpeechVoice")
                        }
                        Text("For lessons and practice. Add voices in iPhone Accessibility settings.")
                            .font(.caption).foregroundStyle(theme.muted)
                    }.padding(14).background(theme.surface, in: RoundedRectangle(cornerRadius: 18))
                    VStack(alignment: .leading, spacing: 10) {
                        Eyebrow(text: "Your German level")
                        Picker("Current German level", selection: Binding(get: { store.studyLevel }, set: { store.studyLevel = $0 })) {
                            ForEach(StudyLevel.allCases) { level in Text(level.rawValue).tag(level) }
                        }.pickerStyle(.segmented).accessibilityIdentifier("studyLevelPicker")
                        Text("Explore suggestions match your level.")
                            .font(.caption).foregroundStyle(theme.muted)
                    }.padding(14).background(theme.surface, in: RoundedRectangle(cornerRadius: 18))
                    VStack(alignment: .leading, spacing: 10) {
                        Eyebrow(text: "Review reminder")
                        Toggle("Daily reminder", isOn: Binding(
                            get: { store.reminderEnabled },
                            set: { enabled in Task { await store.updateReminder(enabled: enabled) } }
                        )).accessibilityIdentifier("dailyReminderToggle")
                        Text("A daily nudge to review your words.")
                            .font(.caption).foregroundStyle(theme.muted)
                        if store.reminderEnabled {
                            DatePicker("Remind me at", selection: Binding(
                                get: { Calendar.current.date(bySettingHour: store.reminderMinutes / 60, minute: store.reminderMinutes % 60, second: 0, of: Date()) ?? Date() },
                                set: { date in
                                    let parts = Calendar.current.dateComponents([.hour, .minute], from: date)
                                    Task { await store.updateReminder(enabled: true, minutes: (parts.hour ?? 19) * 60 + (parts.minute ?? 0)) }
                                }
                            ), displayedComponents: .hourAndMinute)
                            .accessibilityIdentifier("reminderTimePicker")
                        }
                        if store.notificationsDenied {
                            Text("Notifications are off for Wortschatz. Allow them in iPhone Settings, then enable your reminder here.")
                                .font(.caption).foregroundStyle(theme.muted)
                            Button("Open notification settings") {
                                if let url = URL(string: UIApplication.openNotificationSettingsURLString) { openURL(url) }
                            }
                        }
                        if let error = store.reminderError {
                            Text(error).font(.caption).foregroundStyle(theme.muted)
                        }
                    }
                    .disabled(store.updatingReminder)
                    .padding(14).background(theme.surface, in: RoundedRectangle(cornerRadius: 18))
                    Label("Your preferences are saved on this device.", systemImage: "iphone")
                        .font(.caption).foregroundStyle(theme.muted)
                }.padding(16).frame(maxWidth: 620).frame(maxWidth: .infinity)
            }.background(theme.paper).navigationTitle("Settings").navigationBarTitleDisplayMode(.inline)
                .onAppear { store.refreshSpeechVoices() }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    store.refreshSpeechVoices()
                }
                .onDisappear { store.stopAudio() }
        }
    }
}
