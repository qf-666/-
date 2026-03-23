import Foundation

enum AudioConversionError: LocalizedError {
    case protectedVendorFormat(String)
    case missingOutput(Int)
    case ffmpegFailed(Int)

    var errorDescription: String? {
        switch self {
        case let .protectedVendorFormat(extensionName):
            return AppText.errorProtectedPrefix + " \(extensionName)" + AppText.errorProtectedSuffix
        case let .missingOutput(exitCode):
            return AppText.errorMissingOutput(exitCode)
        case let .ffmpegFailed(exitCode):
            return AppText.errorFFmpegFailed(exitCode)
        }
    }
}
