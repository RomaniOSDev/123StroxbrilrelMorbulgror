import Foundation

/// Central place for outbound URLs (privacy, terms). Replace example.com with your live pages.
enum AppExternalLink: String, CaseIterable {
    case privacyPolicy = "https://stroxbrilrelmorbulgror123.site/privacy/69"
    case termsOfUse = "https://stroxbrilrelmorbulgror123.site/terms/69"

    var url: URL? {
        URL(string: rawValue)
    }

    var title: String {
        switch self {
        case .privacyPolicy: return "Privacy Policy"
        case .termsOfUse: return "Terms of Use"
        }
    }
}
