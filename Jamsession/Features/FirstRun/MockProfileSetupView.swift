import SwiftUI

struct MockProfileSetupView: View {
    let role: MockEntryRole
    var onContinue: ((ProfileDraft) -> Void)?

    @State private var displayName = ""
    @State private var emoji = "🪩"
    @State private var selectedColor = ProfileColorID.purple
    @State private var isShowingExplainer = false
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
            return "mockEntry.profile.validation.blank"
        case .failure(.displayNameTooLong):
            return "mockEntry.profile.validation.long"
        case .failure(.missingEmoji):
            return "mockEntry.profile.validation.emoji"
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

                    Text(
                        displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? String(localized: "mockEntry.profile.preview")
                            : displayName.trimmingCharacters(in: .whitespacesAndNewlines)
                    )
                        .font(.headline)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .combine)
            }

            Section("mockEntry.profile.name.section") {
                TextField("mockEntry.profile.name.placeholder", text: $displayName)
                    .textContentType(.nickname)
                    .focused($isNameFocused)
                    .submitLabel(.done)
                    .accessibilityIdentifier("mock.flow.profile.name")

                if let validationMessage {
                    Label(validationMessage, systemImage: "exclamationmark.circle.fill")
                        .font(.footnote)
                        .foregroundStyle(.red)
                } else {
                    Text("mockEntry.profile.name.help")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Section("mockEntry.profile.emoji.section") {
                Picker("mockEntry.profile.emoji.picker", selection: $emoji) {
                    ForEach(emojis, id: \.self) { option in
                        Text(option)
                            .tag(option)
                            .accessibilityLabel(
                                String(
                                    localized: "mockEntry.profile.emoji.option",
                                    defaultValue: "Avatar \(option)"
                                )
                            )
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("mockEntry.profile.color.section") {
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
                                localized: "mockEntry.profile.color.option",
                                defaultValue: "\(option.rawValue) profile color"
                            )
                        )
                        .accessibilityAddTraits(selectedColor == option ? .isSelected : [])
                    }
                }
            }

            Section {
                Button("mockEntry.continue", systemImage: "arrow.right") {
                    isNameFocused = false
                    guard case let .success(profileDraft) = validationResult else {
                        return
                    }

                    if let onContinue {
                        onContinue(profileDraft)
                    } else {
                        isShowingExplainer = true
                    }
                }
                .disabled(!canContinue)
                .accessibilityIdentifier("mock.flow.profile.continue")
            } footer: {
                Text("mockEntry.profile.duplicateNames")
            }
        }
        .navigationTitle(
            role == .host
                ? LocalizedStringKey("mockEntry.profile.host.title")
                : LocalizedStringKey("mockEntry.profile.join.title")
        )
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingExplainer) {
            MockPermissionExplainerView(
                role: role,
                displayName: validationResult.profileDraft?.displayName ?? ""
            )
        }
    }
}

private extension Result where Success == ProfileDraft, Failure == ProfileValidationError {
    var profileDraft: ProfileDraft? {
        guard case let .success(profileDraft) = self else {
            return nil
        }
        return profileDraft
    }
}

#Preview {
    NavigationStack {
        MockProfileSetupView(role: .host)
    }
}
