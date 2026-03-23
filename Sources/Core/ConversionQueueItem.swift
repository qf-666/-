import Foundation

struct ConversionQueueItem: Identifiable {
    enum Status: Equatable {
        case waiting
        case converting
        case success
        case failed
        case skipped

        var title: String {
            switch self {
            case .waiting:
                return AppText.statusWaiting
            case .converting:
                return AppText.statusConverting
            case .success:
                return AppText.statusSuccess
            case .failed:
                return AppText.statusFailedText
            case .skipped:
                return AppText.statusSkipped
            }
        }

        var isFinished: Bool {
            switch self {
            case .success, .failed, .skipped:
                return true
            case .waiting, .converting:
                return false
            }
        }
    }

    let id: UUID
    let file: ImportedAudioFile
    var status: Status
    var detail: String?
    var outputURL: URL?

    init(file: ImportedAudioFile) {
        self.id = UUID()
        self.file = file
        self.status = .waiting
    }
}
