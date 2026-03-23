import Foundation

struct ActivityLogEntry: Identifiable {
    let id = UUID()
    let timestamp: Date
    let message: String

    var formattedLine: String {
        "\(Self.timeFormatter.string(from: timestamp))  \(message)"
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
}
