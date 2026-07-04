import Foundation

struct FeedbackAPIModel: Codable, Equatable {
    struct UserInput: Codable, Equatable {
        let message: String
        let rating: Int?
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

    static func make(from payload: FeedbackPayload, identity: FeedbackUserIdentity?) -> FeedbackAPIModel {
        let resolvedIdentity: UserIdentity?
        if let identity, !identity.isAnonymous {
            resolvedIdentity = UserIdentity(userId: identity.userId, email: identity.email)
        } else {
            resolvedIdentity = nil
        }

        let userInput = payload.userInput.map {
            UserInput(message: $0.message, rating: $0.rating)
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
            template: payload.template.rawValue,
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
}
