import Foundation

enum FeedbackLogAttachment {
    static func readCrashLog(at path: String?) -> String? {
        guard let path, !path.isEmpty else { return nil }
        let url = URL(fileURLWithPath: path)
        guard let data = try? Data(contentsOf: url),
              let text = String(data: data, encoding: .utf8),
              !text.isEmpty else {
            return nil
        }
        return text
    }

    static func makeAttachment(
        logProvider: (() -> String?)?,
        crashLogPath: String?
    ) -> FeedbackAttachment? {
        let provided = logProvider?()
        let text = (provided?.isEmpty == false ? provided : nil) ?? readCrashLog(at: crashLogPath)
        guard let text, !text.isEmpty else { return nil }
        return FeedbackAttachment(
            filename: "logs.txt",
            mimeType: "text/plain",
            data: Data(text.utf8)
        )
    }
}
