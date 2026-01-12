import Foundation

/// Provides access to bundled Retropak schema and locale JSON files
public enum Retropak {
    /// URL to the schema JSON file
    public static var schemaURL: URL? {
        Bundle.module.url(
            forResource: "retropak.schema", withExtension: "json", subdirectory: "schemas/v1")
    }

    /// URL to a locale JSON file
    public static func localeURL(_ locale: String = "en") -> URL? {
        Bundle.module.url(forResource: locale, withExtension: "json", subdirectory: "locales")
    }
}
