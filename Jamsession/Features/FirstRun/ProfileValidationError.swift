nonisolated enum ProfileValidationError: Error, Equatable, Sendable {
    case blankDisplayName
    case displayNameTooLong(limit: Int)
    case missingEmoji
}
