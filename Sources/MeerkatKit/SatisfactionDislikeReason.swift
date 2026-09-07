import Foundation

/// Optional reason collected after a satisfaction-survey dislike.
public enum SatisfactionDislikeReason: String, Sendable, Equatable, CaseIterable {
    case wrongResult
    case tooSlow
    case crash
    case other

    var analyticsValue: String {
        rawValue
    }

    func localizedTitle(locale: FeedbackLocale) -> String {
        let key: MeerkatLocalizedKey
        switch self {
        case .wrongResult:
            key = .surveyReasonWrongResult
        case .tooSlow:
            key = .surveyReasonTooSlow
        case .crash:
            key = .surveyReasonCrash
        case .other:
            key = .surveyReasonOther
        }
        return MeerkatLocalizer.text(key, locale: locale)
    }
}