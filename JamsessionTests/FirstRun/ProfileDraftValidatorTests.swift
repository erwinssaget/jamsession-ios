import Testing
@testable import Jamsession

struct ProfileDraftValidatorTests {
    @Test
    func validProfileNormalizesWhitespaceAndPreservesIdentityChoices() throws {
        let draft = try ProfileDraftValidator.validate(
            displayName: "  Maya \n",
            emoji: "🎸",
            colorID: .orange
        ).get()

        #expect(draft.displayName == "Maya")
        #expect(draft.emoji == "🎸")
        #expect(draft.colorID == .orange)
    }

    @Test
    func blankDisplayNameIsRejected() {
        let result = ProfileDraftValidator.validate(
            displayName: " \n ",
            emoji: "🪩",
            colorID: .purple
        )

        #expect(result == .failure(.blankDisplayName))
    }

    @Test
    func displayNameAtLimitIsAccepted() throws {
        let name = String(repeating: "A", count: ProfileDraftValidator.displayNameLimit)

        let draft = try ProfileDraftValidator.validate(
            displayName: name,
            emoji: "🎧",
            colorID: .green
        ).get()

        #expect(draft.displayName == name)
    }

    @Test
    func displayNameBeyondLimitIsRejected() {
        let name = String(repeating: "A", count: ProfileDraftValidator.displayNameLimit + 1)

        let result = ProfileDraftValidator.validate(
            displayName: name,
            emoji: "🎧",
            colorID: .green
        )

        #expect(
            result == .failure(
                .displayNameTooLong(limit: ProfileDraftValidator.displayNameLimit)
            )
        )
    }

    @Test
    func missingEmojiIsRejected() {
        let result = ProfileDraftValidator.validate(
            displayName: "Maya",
            emoji: "",
            colorID: .blue
        )

        #expect(result == .failure(.missingEmoji))
    }
}
