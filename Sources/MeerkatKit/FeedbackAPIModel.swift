import Foundation

struct FeedbackAPIModel: Codable, Equatable {
    struct UserInput: Codable, Equatable {
        let message: String
        let rating: Int?
        let email: String?
        let customFields: [String: String]?
    }

    struct UserIdentity: Codable, Equatable {
        let userId: String?
        let email: String?
    }

    struct Attachment: Codable, Equatable {
        let filename: String
        let mimeType: String
        let dataBase64: String
    }

    let placement: String
    let template: String
    let subject: String
    let body: String
    let metadata: [String: String]
    let userInput: UserInput?
    let userIdentity: UserIdentity?
    let attachments: [Attachment]

    static func make(
        from payload: FeedbackPayload,
        identity: FeedbackUserIdentity?,
        extraFields: [FeedbackExtraField] = []
    ) -> FeedbackAPIModel {
        let resolvedIdentity = resolvedAPIIdentity(
            identity: identity,
            extraFields: extraFields
        )

        let userInput = payload.userInput.map {
            UserInput(
                message: $0.message,
                rating: $0.rating,
                email: $0.email,
                customFields: $0.customFields.isEmpty ? nil : $0.customFields
            )
        }

        let attachments = payload.attachments.map {
            Attachment(
                filename: $0.filename,
                mimeType: $0.mimeType,
                dataBase64: $0.data.base64EncodedString()
            )
        }

        return FeedbackAPIModel(
            placement: payload.placement,
            template: payload.template.apiIdentifier,
            subject: payload.subject,
            body: payload.body,
            metadata: payload.metadata,
            userInput: userInput,
            userIdentity: resolvedIdentity,
            attachments: attachments
        )
    }

    func encoded() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(self)
    }

    private static func resolvedAPIIdentity(
        identity: FeedbackUserIdentity?,
        extraFields: [FeedbackExtraField]
    ) -> UserIdentity? {
        if let identity, !identity.isAnonymous {
            return UserIdentity(userId: identity.userId, email: identity.email)
        }
        let extras = Dictionary(
            extraFields.map { ($0.key.lowercased(), $0.value) },
            uniquingKeysWith: { _, latest in latest }
        )
        let userId = extras["userid"]
        let email = extras["email"]
        guard userId != nil || email != nil else { return nil }
        return UserIdentity(userId: userId, email: email)
    }
}
