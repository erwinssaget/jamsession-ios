import SwiftUI

struct ProfileSetupView: View {
    let role: SessionRole
    let accessibilityPrefix: String
    let onContinue: (ProfileDraft) -> Void

    @State private var displayName = ""
    @State private var emoji = "🪩"
    @State private var selectedColor = ProfileColorID.purple
    @FocusState private var isNameFocused: Bool

    private let emojis = ["🪩", "🎸", "🎧", "🥁"]

    private var validationResult: Result<ProfileDraft, ProfileValidationError> {
        ProfileDraftValidator.validate(
            displayName: displayName,
            emoji: emoji,
            colorID: selectedColor
        )
    }

    private var validationMessage: LocalizedStringKey? {
        guard !displayName.isEmpty else {
            return nil
        }

        switch validationResult {
        case .success:
            return nil
        case .failure(.blankDisplayName):
            return "profile.validation.blank"
        case .failure(.displayNameTooLong):
            return "profile.validation.long"
        case .failure(.missingEmoji):
            return "profile.validation.emoji"
        }
    }

    private var canContinue: Bool {
        if case .success = validationResult {
            true
        } else {
            false
        }
    }

    var body: some View {
        Form {
            Section {
                VStack {
                    Text(emoji)
                        .font(.largeTitle)
                        .frame(width: 80, height: 80)
                        .background(selectedColor.color.gradient)
                        .clipShape(.circle)

                    Text(previewName)
                        .font(.headline)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .combine)
            }

            Section("profile.name.section") {
                TextField("profile.name.placeholder", text: $displayName)
                    .textContentType(.nickname)
                    .focused($isNameFocused)
                    .submitLabel(.done)
                    .accessibilityIdentifier("\(accessibilityPrefix).name")

                if let validationMessage {
                    Label(validationMessage, systemImage: "exclamationmark.circle.fill")
                        .font(.footnote)
                        .foregroundStyle(.red)
                } else {
                    Text("profile.name.help")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Section("profile.emoji.section") {
                Picker("profile.emoji.picker", selection: $emoji) {
                    ForEach(emojis, id: \.self) { option in
                        Text(option)
                            .tag(option)
                            .accessibilityLabel(
                                String(
                                    localized: "profile.emoji.option",
                                    defaultValue: "Avatar \(option)"
                                )
                            )
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("profile.color.section") {
                HStack {
                    ForEach(ProfileColorID.allCases) { option in
                        Button {
                            selectedColor = option
                        } label: {
                            Circle()
                                .fill(option.color.gradient)
                                .frame(width: 44, height: 44)
                                .overlay {
                                    if selectedColor == option {
                                        Image(systemName: "checkmark")
                                            .bold()
                                            .foregroundStyle(.white)
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(
                            String(
                                localized: "profile.color.option",
                                defaultValue: "\(option.rawValue) profile color"
                            )
                        )
                        .accessibilityAddTraits(selectedColor == option ? .isSelected : [])
                    }
                }
            }

            Section {
                Button("profile.continue", systemImage: "arrow.right") {
                    isNameFocused = false
                    guard case let .success(profileDraft) = validationResult else {
                        return
                    }
                    onContinue(profileDraft)
                }
                .disabled(!canContinue)
                .accessibilityIdentifier("\(accessibilityPrefix).continue")
            } footer: {
                Text("profile.duplicateNames")
            }
        }
        .navigationTitle(
            role == .host
                ? LocalizedStringKey("profile.host.title")
                : LocalizedStringKey("profile.join.title")
        )
        .navigationBarTitleDisplayMode(.inline)
    }

    private var previewName: String {
        let normalizedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        return normalizedName.isEmpty ? String(localized: "profile.preview") : normalizedName
    }
}

#Preview {
    NavigationStack {
        ProfileSetupView(
            role: .host,
            accessibilityPrefix: "preview.profile",
            onContinue: { _ in }
        )
    }
}
