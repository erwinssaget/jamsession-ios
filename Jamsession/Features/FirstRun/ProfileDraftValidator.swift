import Foundation

nonisolated enum ProfileDraftValidator {
    static let displayNameLimit = 30

    static func validate(
        displayName: String,
        emoji: String,
        colorID: ProfileColorID
    ) -> Result<ProfileDraft, ProfileValidationError> {
        let normalizedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalizedName.isEmpty else {
            return .failure(.blankDisplayName)
        }

        guard normalizedName.count <= displayNameLimit else {
            return .failure(.displayNameTooLong(limit: displayNameLimit))
        }

        guard !emoji.isEmpty else {
            return .failure(.missingEmoji)
        }

        return .success(
            ProfileDraft(
                displayName: normalizedName,
                emoji: emoji,
                colorID: colorID
            )
        )
    }
}
