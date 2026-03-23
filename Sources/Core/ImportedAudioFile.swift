import Foundation

struct ImportedAudioFile {
    static let supportedExtensions: Set<String> = [
        "aac",
        "aif",
        "aiff",
        "alac",
        "caf",
        "flac",
        "m4a",
        "mp3",
        "ogg",
        "opus",
        "wav",
        "wma"
    ]

    let originalName: String
    let localURL: URL
    let byteCount: Int64
    let sourceReference: String

    var fileExtension: String {
        localURL.pathExtension.lowercased()
    }

    var baseName: String {
        localURL.deletingPathExtension().lastPathComponent
    }

    var byteCountDescription: String {
        ByteCountFormatter.string(fromByteCount: byteCount, countStyle: .file)
    }

    static func copyingFromPicker(_ sourceURL: URL) throws -> ImportedAudioFile {
        let accessGranted = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if accessGranted {
                sourceURL.stopAccessingSecurityScopedResource()
            }
        }

        return try copyResolvedFile(sourceURL)
    }

    static func copyingManyFromPicker(_ sourceURLs: [URL]) throws -> [ImportedAudioFile] {
        var importedFiles: [ImportedAudioFile] = []

        for sourceURL in sourceURLs {
            if let importedFile = try? copyingFromPicker(sourceURL) {
                importedFiles.append(importedFile)
            }
        }

        return importedFiles
    }

    static func copyingAudioFilesFromDirectory(_ directoryURL: URL) throws -> [ImportedAudioFile] {
        let accessGranted = directoryURL.startAccessingSecurityScopedResource()
        defer {
            if accessGranted {
                directoryURL.stopAccessingSecurityScopedResource()
            }
        }

        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(
            at: directoryURL,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        var importedFiles: [ImportedAudioFile] = []

        for case let fileURL as URL in enumerator {
            let values = try fileURL.resourceValues(forKeys: [.isRegularFileKey])
            guard values.isRegularFile == true else {
                continue
            }

            let fileExtension = fileURL.pathExtension.lowercased()
            guard supportedExtensions.contains(fileExtension) else {
                continue
            }

            if let importedFile = try? copyResolvedFile(fileURL) {
                importedFiles.append(importedFile)
            }
        }

        return importedFiles
    }

    private static func copyResolvedFile(_ sourceURL: URL) throws -> ImportedAudioFile {
        let protectedExtension = ProtectedAudioFormat.detect(in: sourceURL)
        if let protectedExtension {
            throw AudioConversionError.protectedVendorFormat(protectedExtension)
        }

        let fileManager = FileManager.default
        let workingDirectory = try fileManager.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent("ImportedAudio", isDirectory: true)

        try fileManager.createDirectory(
            at: workingDirectory,
            withIntermediateDirectories: true,
            attributes: nil
        )

        let destinationURL = workingDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(sourceURL.pathExtension)

        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        }

        try fileManager.copyItem(at: sourceURL, to: destinationURL)

        let values = try destinationURL.resourceValues(forKeys: [.fileSizeKey])

        return ImportedAudioFile(
            originalName: sourceURL.lastPathComponent,
            localURL: destinationURL,
            byteCount: Int64(values.fileSize ?? 0),
            sourceReference: sourceURL.standardizedFileURL.path.lowercased()
        )
    }
}
