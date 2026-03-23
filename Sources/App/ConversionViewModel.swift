import Combine
import Foundation

@MainActor
final class ConversionViewModel: ObservableObject {
    @Published var queueItems: [ConversionQueueItem] = []
    @Published var selectedFormat: AudioFormat = .flac
    @Published var selectedQuality: AudioQuality = .bitrate320
    @Published var errorMessage: String?
    @Published var statusMessage = "Ready"
    @Published var isConverting = false
    @Published var isPaused = false
    @Published var currentFileName = "None"
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
                errorMessage = "No supported local audio files were imported."
                appendLog("Import skipped: no supported files were selected.")
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
                errorMessage = "No supported audio files were found in that folder."
                return
            }
            appendImportedFiles(importedFiles)
        } catch {
            present(error: error)
        }
    }

    func clearQueue() {
        guard !isConverting else {
            errorMessage = "Clear the queue after the active batch finishes."
            return
        }

        queueItems.removeAll()
        currentFileName = "None"
        statusMessage = "Queue cleared."
        appendLog("Cleared the conversion queue.")
    }

    func startConversion() {
        guard !isConverting else { return }
        guard waitingCount > 0 else {
            errorMessage = "Add at least one waiting file before starting."
            return
        }

        isConverting = true
        isPaused = false
        stopRequested = false
        statusMessage = waitingCount == 1
            ? "Starting a single conversion."
            : "Starting a batch of \(waitingCount) files."
        appendLog(statusMessage)

        batchTask = Task { [weak self] in
            await self?.runBatchConversion()
        }
    }

    func togglePause() {
        guard isConverting else { return }
        isPaused.toggle()

        if isPaused {
            statusMessage = "Paused. The current file will finish first."
            appendLog("Pause requested.")
        } else {
            statusMessage = "Resuming the queue."
            appendLog("Queue resumed.")
        }
    }

    func stopConversion() {
        guard isConverting else { return }
        stopRequested = true
        isPaused = false
        statusMessage = "Stop requested. The current file will finish first."
        appendLog("Stop requested for the active batch.")
    }

    func present(error: Error) {
        errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        appendLog("Error: \(errorMessage ?? "Unknown error")")
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
            statusMessage = "All selected files were already in the queue."
            appendLog(statusMessage)
        } else {
            statusMessage = insertedCount == 1
                ? "Added 1 file to the queue."
                : "Added \(insertedCount) files to the queue."
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
                $0.detail = "Running FFmpeg"
            }

            currentFileName = item.file.originalName
            statusMessage = "Converting \(item.file.originalName)"
            appendLog("Starting \(item.file.originalName)")

            do {
                let outputURL = try await service.convert(
                    input: item.file,
                    to: selectedFormat,
                    quality: selectedQuality
                )

                updateItem(itemID) {
                    $0.status = .success
                    $0.detail = "Saved in app storage"
                    $0.outputURL = outputURL
                }
                appendLog("Success: \(item.file.originalName) -> \(outputURL.lastPathComponent)")
            } catch {
                updateItem(itemID) {
                    $0.status = .failed
                    $0.detail = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                }
                appendLog("Failed: \(item.file.originalName)")
            }
        }

        isConverting = false
        isPaused = false
        currentFileName = "None"

        if stopRequested {
            statusMessage = remainingCount == 0
                ? "Stop completed. No files remain."
                : "Stopped with \(waitingCount) files still waiting."
            appendLog(statusMessage)
        } else {
            statusMessage = successCount == totalCount
                ? "Batch complete. All files succeeded."
                : "Batch complete. \(successCount) succeeded, \(failedCount) failed."
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
