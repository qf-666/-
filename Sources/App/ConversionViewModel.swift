import Combine
import Foundation

@MainActor
final class ConversionViewModel: ObservableObject {
    @Published var queueItems: [ConversionQueueItem] = []
    @Published var selectedFormat: AudioFormat = .flac
    @Published var selectedQuality: AudioQuality = .bitrate320
    @Published var errorMessage: String?
    @Published var statusMessage = AppText.statusReady
    @Published var isConverting = false
    @Published var isPaused = false
    @Published var currentFileName = AppText.currentNone
    @Published var activityLog: [ActivityLogEntry] = []

    private let service = AudioConversionService()
    private var batchTask: Task<Void, Never>?
    private var stopRequested = false

    var totalCount: Int { queueItems.count }
    var waitingCount: Int { queueItems.filter { $0.status == .waiting }.count }
    var successCount: Int { queueItems.filter { $0.status == .success }.count }
    var failedCount: Int { queueItems.filter { $0.status == .failed }.count }
    var completedCount: Int { queueItems.filter { $0.status.isFinished }.count }
    var remainingCount: Int { totalCount - completedCount }
    var overallProgress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }

    func importFiles(from urls: [URL]) {
        do {
            let importedFiles = try ImportedAudioFile.copyingManyFromPicker(urls)
            guard !importedFiles.isEmpty else {
                errorMessage = AppText.importUnsupported
                appendLog(AppText.importSkipped)
                return
            }
            appendImportedFiles(importedFiles)
        } catch {
            present(error: error)
        }
    }

    func importFolder(from url: URL) {
        do {
            let importedFiles = try ImportedAudioFile.copyingAudioFilesFromDirectory(url)
            guard !importedFiles.isEmpty else {
                errorMessage = AppText.importFolderEmpty
                return
            }
            appendImportedFiles(importedFiles)
        } catch {
            present(error: error)
        }
    }

    func clearQueue() {
        guard !isConverting else {
            errorMessage = AppText.clearQueueBlocked
            return
        }

        queueItems.removeAll()
        currentFileName = AppText.currentNone
        statusMessage = AppText.statusQueueCleared
        appendLog(AppText.logQueueCleared)
    }

    func startConversion() {
        guard !isConverting else { return }
        guard waitingCount > 0 else {
            errorMessage = AppText.startNeedsFiles
            return
        }

        isConverting = true
        isPaused = false
        stopRequested = false
        statusMessage = waitingCount == 1
            ? AppText.statusSingleStart
            : AppText.statusBatchStart(waitingCount)
        appendLog(statusMessage)

        batchTask = Task { [weak self] in
            await self?.runBatchConversion()
        }
    }

    func togglePause() {
        guard isConverting else { return }
        isPaused.toggle()

        if isPaused {
            statusMessage = AppText.statusPaused
            appendLog(AppText.logPauseRequested)
        } else {
            statusMessage = AppText.statusResuming
            appendLog(AppText.logQueueResumed)
        }
    }

    func stopConversion() {
        guard isConverting else { return }
        stopRequested = true
        isPaused = false
        statusMessage = AppText.statusStopRequested
        appendLog(AppText.logStopRequested)
    }

    func present(error: Error) {
        errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        appendLog(AppText.logError(errorMessage ?? "Unknown error"))
    }

    private func appendImportedFiles(_ importedFiles: [ImportedAudioFile]) {
        var existingReferences = Set(queueItems.map(\.file.sourceReference))
        var insertedCount = 0

        for file in importedFiles where !existingReferences.contains(file.sourceReference) {
            queueItems.append(ConversionQueueItem(file: file))
            existingReferences.insert(file.sourceReference)
            insertedCount += 1
        }

        if insertedCount == 0 {
            statusMessage = AppText.queueDuplicate
            appendLog(statusMessage)
        } else {
            statusMessage = insertedCount == 1
                ? AppText.queueAddedSingle
                : AppText.queueAdded(insertedCount)
            appendLog(statusMessage)
        }
    }

    private func runBatchConversion() async {
        let queueSnapshot = queueItems.filter { $0.status == .waiting }.map(\.id)

        for itemID in queueSnapshot {
            if stopRequested {
                break
            }

            while isPaused && !stopRequested {
                try? await Task.sleep(nanoseconds: 250_000_000)
            }

            guard !stopRequested else { break }
            guard let item = queueItems.first(where: { $0.id == itemID }) else { continue }

            updateItem(itemID) {
                $0.status = .converting
                $0.detail = AppText.logRunningFFmpeg
            }

            currentFileName = item.file.originalName
            statusMessage = AppText.converting(item.file.originalName)
            appendLog(AppText.logStarting(item.file.originalName))

            do {
                let outputURL = try await service.convert(
                    input: item.file,
                    to: selectedFormat,
                    quality: selectedQuality
                )

                updateItem(itemID) {
                    $0.status = .success
                    $0.detail = AppText.queueDetailSaved
                    $0.outputURL = outputURL
                }
                appendLog(AppText.logSuccess(item.file.originalName, output: outputURL.lastPathComponent))
            } catch {
                updateItem(itemID) {
                    $0.status = .failed
                    $0.detail = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                }
                appendLog(AppText.logFailed(item.file.originalName))
            }
        }

        isConverting = false
        isPaused = false
        currentFileName = AppText.currentNone

        if stopRequested {
            statusMessage = remainingCount == 0
                ? AppText.statusStopComplete
                : AppText.statusStopped(waiting: waitingCount)
            appendLog(statusMessage)
        } else {
            statusMessage = successCount == totalCount
                ? AppText.statusAllSucceeded
                : AppText.statusBatchFinished(success: successCount, failed: failedCount)
            appendLog(statusMessage)
        }
    }

    private func updateItem(_ itemID: UUID, mutate: (inout ConversionQueueItem) -> Void) {
        guard let index = queueItems.firstIndex(where: { $0.id == itemID }) else { return }
        mutate(&queueItems[index])
    }

    private func appendLog(_ message: String) {
        activityLog.insert(ActivityLogEntry(timestamp: Date(), message: message), at: 0)
    }
}
