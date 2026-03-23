import Foundation

enum AudioFormat: String, CaseIterable, Identifiable {
    case flac
    case mp3
    case wav
    case ogg
    case aac
    case m4a
    case wma
    case aiff
    case alac

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .alac:
            return "ALAC"
        case .aiff:
            return "AIFF"
        default:
            return rawValue.uppercased()
        }
    }

    var fileExtension: String {
        switch self {
        case .alac:
            return "m4a"
        default:
            return rawValue
        }
    }

    var description: String {
        switch self {
        case .flac:
            return "Lossless compression"
        case .mp3:
            return "Lossy, broad compatibility"
        case .wav:
            return "Uncompressed PCM"
        case .ogg:
            return "Vorbis container"
        case .aac:
            return "Raw AAC stream"
        case .m4a:
            return "AAC in M4A container"
        case .wma:
            return "Windows Media Audio"
        case .aiff:
            return "PCM in AIFF container"
        case .alac:
            return "Apple Lossless in M4A"
        }
    }

    func ffmpegArguments(for quality: AudioQuality) -> [String] {
        switch self {
        case .flac:
            return ["-vn", "-c:a", "flac", "-compression_level", "8"]
        case .mp3:
            if quality == .lossless {
                return ["-vn", "-c:a", "libmp3lame", "-q:a", "0"]
            }
            return ["-vn", "-c:a", "libmp3lame", "-b:a", quality.bitrate]
        case .wav:
            return ["-vn", "-c:a", "pcm_s16le"]
        case .ogg:
            return ["-vn", "-c:a", "libvorbis", "-q:a", quality.oggQualityValue]
        case .aac:
            return ["-vn", "-c:a", "aac", "-b:a", quality.aacBitrate, "-f", "adts"]
        case .m4a:
            return ["-vn", "-c:a", "aac", "-b:a", quality.aacBitrate, "-movflags", "+faststart"]
        case .wma:
            return ["-vn", "-c:a", "wmav2", "-b:a", quality.bitrate]
        case .aiff:
            return ["-vn", "-c:a", "pcm_s16be"]
        case .alac:
            return ["-vn", "-c:a", "alac"]
        }
    }
}
