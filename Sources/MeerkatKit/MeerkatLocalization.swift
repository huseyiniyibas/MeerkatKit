import Foundation

enum MeerkatLocalizedKey {
    case feedbackButton
    case subjectFeedback
    case subjectBugReport
    case subjectFeatureRequest
    case bodyPrefixFeedback
    case bodyPrefixBugReport
    case bodyPrefixFeatureRequest
    case promptTypeBelow
    case labelApp
    case labelVersion
    case labelScreen
    case labelDevice
    case labelOS
    case labelAppStoreID
    case templatePickerTitle
    case templatePickerCancel
}

enum MeerkatLocalizer {
    static func text(_ key: MeerkatLocalizedKey, locale: FeedbackLocale) -> String {
        text(key, languageCode: locale.languageCode)
    }

    static func text(_ key: MeerkatLocalizedKey, languageCode: String) -> String {
        let lang = languageCode.lowercased()
        let base = String(lang.split(separator: "-")[0]).lowercased()
        let table = dictionary[lang] ?? dictionary[base] ?? dictionary["en"]!
        return table[key] ?? dictionary["en"]![key]!
    }

    private static let dictionary: [String: [MeerkatLocalizedKey: String]] = [
        "en": [
            .feedbackButton: "Feedback",
            .subjectFeedback: "Feedback",
            .subjectBugReport: "Bug Report",
            .subjectFeatureRequest: "Feature Request",
            .bodyPrefixFeedback: "Your feedback:\n\n",
            .bodyPrefixBugReport: "Describe the bug:\n\n",
            .bodyPrefixFeatureRequest: "Describe your idea:\n\n",
            .promptTypeBelow: "Please type your feedback below:",
            .labelApp: "App",
            .labelVersion: "Version",
            .labelScreen: "Screen",
            .labelDevice: "Device",
            .labelOS: "OS",
            .labelAppStoreID: "App Store ID",
            .templatePickerTitle: "What kind of feedback?",
            .templatePickerCancel: "Cancel"
        ],
        "tr": [
            .feedbackButton: "Geri Bildirim",
            .subjectFeedback: "Geri Bildirim",
            .subjectBugReport: "Hata Bildirimi",
            .subjectFeatureRequest: "Özellik İsteği",
            .bodyPrefixFeedback: "Geri bildiriminiz:\n\n",
            .bodyPrefixBugReport: "Hatayı açıklayın:\n\n",
            .bodyPrefixFeatureRequest: "Fikrinizi açıklayın:\n\n",
            .promptTypeBelow: "Lütfen geri bildiriminizi aşağıya yazın:",
            .labelApp: "Uygulama",
            .labelVersion: "Sürüm",
            .labelScreen: "Ekran",
            .labelDevice: "Cihaz",
            .labelOS: "İşletim Sistemi",
            .labelAppStoreID: "App Store ID",
            .templatePickerTitle: "Ne tür geri bildirim?",
            .templatePickerCancel: "İptal"
        ],
        "es": [
            .feedbackButton: "Comentarios",
            .subjectFeedback: "Comentarios",
            .subjectBugReport: "Informe de error",
            .subjectFeatureRequest: "Solicitud de función",
            .bodyPrefixFeedback: "Tus comentarios:\n\n",
            .bodyPrefixBugReport: "Describe el error:\n\n",
            .bodyPrefixFeatureRequest: "Describe tu idea:\n\n",
            .promptTypeBelow: "Escribe tus comentarios abajo:",
            .labelApp: "App",
            .labelVersion: "Versión",
            .labelScreen: "Pantalla",
            .labelDevice: "Dispositivo",
            .labelOS: "Sistema",
            .labelAppStoreID: "ID de App Store"
        ],
        "fr": [
            .feedbackButton: "Retour",
            .subjectFeedback: "Retour",
            .subjectBugReport: "Rapport de bug",
            .subjectFeatureRequest: "Demande de fonctionnalité",
            .bodyPrefixFeedback: "Votre retour :\n\n",
            .bodyPrefixBugReport: "Décrivez le bug :\n\n",
            .bodyPrefixFeatureRequest: "Décrivez votre idée :\n\n",
            .promptTypeBelow: "Saisissez votre retour ci-dessous :",
            .labelApp: "App",
            .labelVersion: "Version",
            .labelScreen: "Écran",
            .labelDevice: "Appareil",
            .labelOS: "Système",
            .labelAppStoreID: "ID App Store"
        ],
        "de": [
            .feedbackButton: "Rückmeldung",
            .subjectFeedback: "Rückmeldung",
            .subjectBugReport: "Fehlerbericht",
            .subjectFeatureRequest: "Feature-Anfrage",
            .bodyPrefixFeedback: "Dein Feedback:\n\n",
            .bodyPrefixBugReport: "Beschreibe den Fehler:\n\n",
            .bodyPrefixFeatureRequest: "Beschreibe deine Idee:\n\n",
            .promptTypeBelow: "Bitte gib dein Feedback unten ein:",
            .labelApp: "App",
            .labelVersion: "Version",
            .labelScreen: "Bildschirm",
            .labelDevice: "Gerät",
            .labelOS: "Betriebssystem",
            .labelAppStoreID: "App Store-ID"
        ],
        "ja": [
            .feedbackButton: "フィードバック",
            .subjectFeedback: "フィードバック",
            .subjectBugReport: "不具合報告",
            .subjectFeatureRequest: "機能リクエスト",
            .bodyPrefixFeedback: "ご意見・ご要望をご記入ください:\n\n",
            .bodyPrefixBugReport: "不具合の内容をご記入ください:\n\n",
            .bodyPrefixFeatureRequest: "アイデアをご記入ください:\n\n",
            .promptTypeBelow: "以下にご記入ください:",
            .labelApp: "アプリ",
            .labelVersion: "バージョン",
            .labelScreen: "画面",
            .labelDevice: "デバイス",
            .labelOS: "OS",
            .labelAppStoreID: "App Store ID"
        ],
        "it": [
            .feedbackButton: "Feedback",
            .subjectFeedback: "Feedback",
            .subjectBugReport: "Segnalazione bug",
            .subjectFeatureRequest: "Richiesta funzionalità",
            .bodyPrefixFeedback: "Il tuo feedback:\n\n",
            .bodyPrefixBugReport: "Descrivi il bug:\n\n",
            .bodyPrefixFeatureRequest: "Descrivi la tua idea:\n\n",
            .promptTypeBelow: "Scrivi il tuo feedback qui sotto:",
            .labelApp: "App",
            .labelVersion: "Versione",
            .labelScreen: "Schermata",
            .labelDevice: "Dispositivo",
            .labelOS: "Sistema operativo",
            .labelAppStoreID: "ID App Store"
        ],
        "pt": [
            .feedbackButton: "Feedback",
            .subjectFeedback: "Feedback",
            .subjectBugReport: "Relato de bug",
            .subjectFeatureRequest: "Solicitação de recurso",
            .bodyPrefixFeedback: "Seu feedback:\n\n",
            .bodyPrefixBugReport: "Descreva o bug:\n\n",
            .bodyPrefixFeatureRequest: "Descreva sua ideia:\n\n",
            .promptTypeBelow: "Escreva seu feedback abaixo:",
            .labelApp: "App",
            .labelVersion: "Versão",
            .labelScreen: "Tela",
            .labelDevice: "Dispositivo",
            .labelOS: "Sistema",
            .labelAppStoreID: "ID da App Store"
        ],
        "ru": [
            .feedbackButton: "Обратная связь",
            .subjectFeedback: "Обратная связь",
            .subjectBugReport: "Сообщение об ошибке",
            .subjectFeatureRequest: "Запрос функции",
            .bodyPrefixFeedback: "Ваш отзыв:\n\n",
            .bodyPrefixBugReport: "Опишите ошибку:\n\n",
            .bodyPrefixFeatureRequest: "Опишите вашу идею:\n\n",
            .promptTypeBelow: "Введите ваш отзыв ниже:",
            .labelApp: "Приложение",
            .labelVersion: "Версия",
            .labelScreen: "Экран",
            .labelDevice: "Устройство",
            .labelOS: "ОС",
            .labelAppStoreID: "ID App Store"
        ],
        "ko": [
            .feedbackButton: "피드백",
            .subjectFeedback: "피드백",
            .subjectBugReport: "버그 제보",
            .subjectFeatureRequest: "기능 요청",
            .bodyPrefixFeedback: "피드백을 남겨주세요:\n\n",
            .bodyPrefixBugReport: "버그를 설명해 주세요:\n\n",
            .bodyPrefixFeatureRequest: "아이디어를 설명해 주세요:\n\n",
            .promptTypeBelow: "아래에 피드백을 입력해 주세요:",
            .labelApp: "앱",
            .labelVersion: "버전",
            .labelScreen: "화면",
            .labelDevice: "기기",
            .labelOS: "OS",
            .labelAppStoreID: "App Store ID"
        ],
        "zh-hans": [
            .feedbackButton: "反馈",
            .subjectFeedback: "反馈",
            .subjectBugReport: "错误反馈",
            .subjectFeatureRequest: "功能建议",
            .bodyPrefixFeedback: "请输入您的反馈：\n\n",
            .bodyPrefixBugReport: "请描述问题：\n\n",
            .bodyPrefixFeatureRequest: "请描述您的想法：\n\n",
            .promptTypeBelow: "请在下方输入您的反馈：",
            .labelApp: "应用",
            .labelVersion: "版本",
            .labelScreen: "页面",
            .labelDevice: "设备",
            .labelOS: "系统",
            .labelAppStoreID: "App Store ID"
        ],
        "zh-hant": [
            .feedbackButton: "回饋",
            .subjectFeedback: "回饋",
            .subjectBugReport: "錯誤回報",
            .subjectFeatureRequest: "功能建議",
            .bodyPrefixFeedback: "請輸入您的回饋：\n\n",
            .bodyPrefixBugReport: "請描述問題：\n\n",
            .bodyPrefixFeatureRequest: "請描述您的想法：\n\n",
            .promptTypeBelow: "請在下方輸入您的回饋：",
            .labelApp: "App",
            .labelVersion: "版本",
            .labelScreen: "頁面",
            .labelDevice: "裝置",
            .labelOS: "系統",
            .labelAppStoreID: "App Store ID"
        ],
        "nl": [
            .feedbackButton: "Feedback",
            .subjectFeedback: "Feedback",
            .subjectBugReport: "Bugrapport",
            .subjectFeatureRequest: "Functieverzoek",
            .bodyPrefixFeedback: "Jouw feedback:\n\n",
            .bodyPrefixBugReport: "Beschrijf de bug:\n\n",
            .bodyPrefixFeatureRequest: "Beschrijf je idee:\n\n",
            .promptTypeBelow: "Typ je feedback hieronder:",
            .labelApp: "App",
            .labelVersion: "Versie",
            .labelScreen: "Scherm",
            .labelDevice: "Apparaat",
            .labelOS: "Besturingssysteem",
            .labelAppStoreID: "App Store-ID"
        ],
        "ar": [
            .feedbackButton: "ملاحظات",
            .subjectFeedback: "ملاحظات",
            .subjectBugReport: "بلاغ خطأ",
            .subjectFeatureRequest: "طلب ميزة",
            .bodyPrefixFeedback: "اكتب ملاحظاتك:\n\n",
            .bodyPrefixBugReport: "اشرح المشكلة:\n\n",
            .bodyPrefixFeatureRequest: "اشرح فكرتك:\n\n",
            .promptTypeBelow: "اكتب ملاحظاتك أدناه:",
            .labelApp: "التطبيق",
            .labelVersion: "الإصدار",
            .labelScreen: "الشاشة",
            .labelDevice: "الجهاز",
            .labelOS: "نظام التشغيل",
            .labelAppStoreID: "معرّف App Store"
        ]
    ]
}

extension FeedbackLocale {
    var languageCode: String {
        switch self {
        case .english: return "en"
        case .turkish: return "tr"
        case .current:
            let preferred = Locale.preferredLanguages.first?.lowercased() ?? "en"
            if preferred.hasPrefix("zh-hant") { return "zh-hant" }
            if preferred.hasPrefix("zh-hans") { return "zh-hans" }
            if preferred.hasPrefix("pt-br") { return "pt" }
            return preferred
        }
    }
}
