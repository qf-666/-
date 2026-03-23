import Foundation

enum AudioQuality: String, CaseIterable, Identifiable {
    case bitrate64 = "64k"
    case bitrate128 = "128k"
    case bitrate192 = "192k"
    case bitrate256 = "256k"
    case bitrate320 = "320k"
    case lossless = "Lossless"

    var id: String { rawValue }

    var displayName: String { rawValue }

    var bitrate: String {
        switch self {
        case .bitrate64:
            return "64k"
        case .bitrate128:
            return "128k"
        case .bitrate192:
            return "192k"
        case .bitrate256:
            return "256k"
        case .bitrate320, .lossless:
            return "320k"
        }
    }

    var aacBitrate: String {
        switch self {
        case .bitrate64:
            return "96k"
        case .bitrate128:
            return "128k"
        case .bitrate192:
            return "192k"
        case .bitrate256:
            return "256k"
        case .bitrate320, .lossless:
            return "320k"
        }
    }

    var oggQualityValue: String {
        switch self {
        case .bitrate64:
            return "2"
        case .bitrate128:
            return "4"
        case .bitrate192:
            return "6"
        case .bitrate256:
            return "8"
        case .bitrate320, .lossless:
            return "10"
        }
    }
}
