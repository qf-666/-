import Foundation

enum AppText {
    static let appTitle = "\u{97F3}\u{4E50}\u{8F6C}\u{6362}"
    static let alertTitle = "\u{65E0}\u{6CD5}\u{7EE7}\u{7EED}"
    static let alertButton = "\u{77E5}\u{9053}\u{4E86}"

    static let panelQueue = "\u{961F}\u{5217}"
    static let panelLog = "\u{65E5}\u{5FD7}"
    static let panelStats = "\u{7EDF}\u{8BA1}"

    static let heroTitle = "\u{672C}\u{5730}\u{97F3}\u{9891}\u{6279}\u{91CF}\u{8F6C}\u{6362}"
    static let heroSubtitle = "\u{652F}\u{6301}\u{5BFC}\u{5165}\u{591A}\u{4E2A}\u{6587}\u{4EF6}\u{6216}\u{6574}\u{4E2A}\u{6587}\u{4EF6}\u{5939}\u{FF0C}\u{6309}\u{961F}\u{5217}\u{8FDB}\u{884C}\u{6279}\u{91CF}\u{8F6C}\u{7801}\u{3001}\u{67E5}\u{770B}\u{65E5}\u{5FD7}\u{4E0E}\u{7EDF}\u{8BA1}\u{FF0C}\u{5E76}\u{5355}\u{72EC}\u{5BFC}\u{51FA}\u{8F6C}\u{6362}\u{7ED3}\u{679C}\u{3002}"

    static let statTotal = "\u{603B}\u{6570}"
    static let statWaiting = "\u{7B49}\u{5F85}"
    static let statSuccess = "\u{6210}\u{529F}"
    static let statFailed = "\u{5931}\u{8D25}"

    static let sectionImport = "\u{5BFC}\u{5165}"
    static let sectionSettings = "\u{8BBE}\u{7F6E}"
    static let sectionControls = "\u{63A7}\u{5236}"
    static let sectionProgress = "\u{8FDB}\u{5EA6}"

    static let buttonImportFolder = "\u{5BFC}\u{5165}\u{6587}\u{4EF6}\u{5939}"
    static let buttonSelectFiles = "\u{9009}\u{62E9}\u{591A}\u{4E2A}\u{6587}\u{4EF6}"
    static let buttonClearQueue = "\u{6E05}\u{7A7A}\u{961F}\u{5217}"
    static let buttonPause = "\u{6682}\u{505C}"
    static let buttonResume = "\u{7EE7}\u{7EED}"
    static let buttonStop = "\u{505C}\u{6B62}"
    static let buttonExportFile = "\u{5BFC}\u{51FA}\u{8F6C}\u{6362}\u{540E}\u{6587}\u{4EF6}"
    static let buttonStartSingle = "\u{5F00}\u{59CB}\u{8F6C}\u{6362}"
    static let buttonStartBatchPrefix = "\u{5F00}\u{59CB}\u{6279}\u{91CF}\u{8F6C}\u{6362}"

    static let labelOutputFormat = "\u{8F93}\u{51FA}\u{683C}\u{5F0F}"
    static let labelQuality = "\u{97F3}\u{8D28}"
    static let labelDestination = "\u{5B58}\u{50A8}\u{4F4D}\u{7F6E}"
    static let labelDestinationDetail = "\u{8F6C}\u{6362}\u{5B8C}\u{7684}\u{6587}\u{4EF6}\u{4F1A}\u{4FDD}\u{5B58}\u{5728}\u{5E94}\u{7528}\u{5185}\u{90E8}\u{5B58}\u{50A8}\u{4E2D}\u{FF0C}\u{53EF}\u{5728}\u{961F}\u{5217}\u{91CC}\u{5355}\u{72EC}\u{5BFC}\u{51FA}\u{3002}"
    static let labelOverall = "\u{603B}\u{8FDB}\u{5EA6}"
    static let labelCurrentFile = "\u{5F53}\u{524D}\u{6587}\u{4EF6}"

    static let emptyQueueTitle = "\u{6682}\u{65E0}\u{6587}\u{4EF6}"
    static let emptyQueueMessage = "\u{5148}\u{5BFC}\u{5165}\u{4E00}\u{4E2A}\u{6587}\u{4EF6}\u{5939}\u{6216}\u{591A}\u{4E2A}\u{97F3}\u{9891}\u{6587}\u{4EF6}\u{FF0C}\u{518D}\u{5F00}\u{59CB}\u{6279}\u{91CF}\u{8F6C}\u{6362}\u{3002}"
    static let emptyLogTitle = "\u{6682}\u{65E0}\u{64CD}\u{4F5C}\u{8BB0}\u{5F55}"
    static let emptyLogMessage = "\u{5BFC}\u{5165}\u{6216}\u{5F00}\u{59CB}\u{8F6C}\u{6362}\u{540E}\u{FF0C}\u{65E5}\u{5FD7}\u{4F1A}\u{663E}\u{793A}\u{5728}\u{8FD9}\u{91CC}\u{3002}"

    static let statsQueuedFiles = "\u{961F}\u{5217}\u{6587}\u{4EF6}"
    static let statsWaiting = "\u{7B49}\u{5F85}\u{4E2D}"
    static let statsConverted = "\u{5DF2}\u{6210}\u{529F}"
    static let statsFailed = "\u{5931}\u{8D25}"
    static let statsRemaining = "\u{5269}\u{4F59}"
    static let statsSuccessRate = "\u{6210}\u{529F}\u{7387}"

    static let queueSummaryEmpty = "\u{961F}\u{5217}\u{8FD8}\u{6CA1}\u{6709}\u{6587}\u{4EF6}\u{3002}"
    static let queueSummarySingle = "\u{5DF2}\u{6DFB}\u{52A0}\u{0031}\u{4E2A}\u{6587}\u{4EF6}\u{3002}"
    static func queueSummary(total: Int, waiting: Int) -> String {
        "\u{5DF2}\u{6DFB}\u{52A0}\(total)\u{4E2A}\u{6587}\u{4EF6}\u{FF0C}\u{5176}\u{4E2D}\(waiting)\u{4E2A}\u{7B49}\u{5F85}\u{8F6C}\u{6362}\u{3002}"
    }

    static let currentNone = "\u{65E0}"

    static let statusReady = "\u{5C31}\u{7EEA}"
    static let statusQueueCleared = "\u{961F}\u{5217}\u{5DF2}\u{6E05}\u{7A7A}\u{3002}"
    static let statusSingleStart = "\u{5F00}\u{59CB}\u{8F6C}\u{6362}\u{5355}\u{4E2A}\u{6587}\u{4EF6}\u{3002}"
    static func statusBatchStart(_ count: Int) -> String {
        "\u{5F00}\u{59CB}\u{6279}\u{91CF}\u{8F6C}\u{6362}\(count)\u{4E2A}\u{6587}\u{4EF6}\u{3002}"
    }
    static let statusPaused = "\u{5DF2}\u{6682}\u{505C}\u{FF0C}\u{5F53}\u{524D}\u{6587}\u{4EF6}\u{4ECD}\u{4F1A}\u{5148}\u{8F6C}\u{5B8C}\u{3002}"
    static let statusResuming = "\u{6B63}\u{5728}\u{7EE7}\u{7EED}\u{961F}\u{5217}\u{3002}"
    static let statusStopRequested = "\u{5DF2}\u{8BF7}\u{6C42}\u{505C}\u{6B62}\u{FF0C}\u{5F53}\u{524D}\u{6587}\u{4EF6}\u{4ECD}\u{4F1A}\u{5148}\u{8F6C}\u{5B8C}\u{3002}"
    static let statusStopComplete = "\u{5DF2}\u{505C}\u{6B62}\u{FF0C}\u{6CA1}\u{6709}\u{5269}\u{4F59}\u{6587}\u{4EF6}\u{3002}"
    static func statusStopped(waiting: Int) -> String {
        "\u{5DF2}\u{505C}\u{6B62}\u{FF0C}\u{8FD8}\u{6709}\(waiting)\u{4E2A}\u{6587}\u{4EF6}\u{672A}\u{8F6C}\u{6362}\u{3002}"
    }
    static let statusAllSucceeded = "\u{6279}\u{91CF}\u{8F6C}\u{6362}\u{5B8C}\u{6210}\u{FF0C}\u{5168}\u{90E8}\u{6210}\u{529F}\u{3002}"
    static func statusBatchFinished(success: Int, failed: Int) -> String {
        "\u{6279}\u{91CF}\u{8F6C}\u{6362}\u{5B8C}\u{6210}\u{FF0C}\u{6210}\u{529F}\(success)\u{4E2A}\u{FF0C}\u{5931}\u{8D25}\(failed)\u{4E2A}\u{3002}"
    }

    static let importUnsupported = "\u{672A}\u{5BFC}\u{5165}\u{5230}\u{53EF}\u{652F}\u{6301}\u{7684}\u{672C}\u{5730}\u{97F3}\u{9891}\u{6587}\u{4EF6}\u{3002}"
    static let importFolderEmpty = "\u{6240}\u{9009}\u{6587}\u{4EF6}\u{5939}\u{4E2D}\u{6CA1}\u{6709}\u{53EF}\u{652F}\u{6301}\u{7684}\u{97F3}\u{9891}\u{6587}\u{4EF6}\u{3002}"
    static let clearQueueBlocked = "\u{8BF7}\u{5728}\u{672C}\u{8F6E}\u{8F6C}\u{6362}\u{5B8C}\u{6210}\u{540E}\u{518D}\u{6E05}\u{7A7A}\u{961F}\u{5217}\u{3002}"
    static let startNeedsFiles = "\u{8BF7}\u{5148}\u{6DFB}\u{52A0}\u{81F3}\u{5C11}\u{4E00}\u{4E2A}\u{7B49}\u{5F85}\u{8F6C}\u{6362}\u{7684}\u{6587}\u{4EF6}\u{3002}"
    static let importSkipped = "\u{5BFC}\u{5165}\u{5DF2}\u{8DF3}\u{8FC7}\u{FF1A}\u{672A}\u{9009}\u{4E2D}\u{53EF}\u{652F}\u{6301}\u{7684}\u{6587}\u{4EF6}\u{3002}"
    static let queueDuplicate = "\u{6240}\u{9009}\u{6587}\u{4EF6}\u{90FD}\u{5DF2}\u{5728}\u{961F}\u{5217}\u{4E2D}\u{3002}"
    static let queueAddedSingle = "\u{5DF2}\u{6DFB}\u{52A0}\u{0031}\u{4E2A}\u{6587}\u{4EF6}\u{5230}\u{961F}\u{5217}\u{3002}"
    static func queueAdded(_ count: Int) -> String {
        "\u{5DF2}\u{6DFB}\u{52A0}\(count)\u{4E2A}\u{6587}\u{4EF6}\u{5230}\u{961F}\u{5217}\u{3002}"
    }

    static let logQueueCleared = "\u{5DF2}\u{6E05}\u{7A7A}\u{8F6C}\u{6362}\u{961F}\u{5217}\u{3002}"
    static let logPauseRequested = "\u{5DF2}\u{8BF7}\u{6C42}\u{6682}\u{505C}\u{3002}"
    static let logQueueResumed = "\u{5DF2}\u{7EE7}\u{7EED}\u{961F}\u{5217}\u{3002}"
    static let logStopRequested = "\u{5DF2}\u{8BF7}\u{6C42}\u{505C}\u{6B62}\u{672C}\u{8F6E}\u{8F6C}\u{6362}\u{3002}"
    static let logRunningFFmpeg = "\u{6B63}\u{5728}\u{8C03}\u{7528}\u{0046}\u{0046}\u{006D}\u{0070}\u{0065}\u{0067}"
    static func logStarting(_ name: String) -> String {
        "\u{5F00}\u{59CB}\u{8F6C}\u{6362}\u{FF1A}\(name)"
    }
    static func logSuccess(_ name: String, output: String) -> String {
        "\u{8F6C}\u{6362}\u{6210}\u{529F}\u{FF1A}\(name) -> \(output)"
    }
    static func logFailed(_ name: String) -> String {
        "\u{8F6C}\u{6362}\u{5931}\u{8D25}\u{FF1A}\(name)"
    }
    static func logError(_ message: String) -> String {
        "\u{9519}\u{8BEF}\u{FF1A}\(message)"
    }

    static func converting(_ name: String) -> String {
        "\u{6B63}\u{5728}\u{8F6C}\u{6362}\(name)"
    }

    static let queueDetailSaved = "\u{5DF2}\u{4FDD}\u{5B58}\u{5230}\u{5E94}\u{7528}\u{5185}\u{5B58}"
    static let errorProtectedPrefix = "\u{68C0}\u{6D4B}\u{5230}\u{53D7}\u{4FDD}\u{62A4}\u{6216}\u{5E73}\u{53F0}\u{79C1}\u{6709}\u{683C}\u{5F0F}\u{FF1A}"
    static let errorProtectedSuffix = "\u{3002}\u{5E94}\u{7528}\u{4E0D}\u{4F1A}\u{89E3}\u{5BC6}\u{6216}\u{8F6C}\u{6362}\u{8FD9}\u{7C7B}\u{6587}\u{4EF6}\u{3002}"
    static func errorMissingOutput(_ code: Int) -> String {
        "\u{0046}\u{0046}\u{006D}\u{0070}\u{0065}\u{0067}\u{5DF2}\u{7ED3}\u{675F}\u{FF0C}\u{4F46}\u{6CA1}\u{6709}\u{751F}\u{6210}\u{8F93}\u{51FA}\u{6587}\u{4EF6}\u{3002}\u{9000}\u{51FA}\u{7801}\u{FF1A}\(code)\u{3002}"
    }
    static func errorFFmpegFailed(_ code: Int) -> String {
        "\u{0046}\u{0046}\u{006D}\u{0070}\u{0065}\u{0067}\u{8F6C}\u{6362}\u{5931}\u{8D25}\u{3002}\u{9000}\u{51FA}\u{7801}\u{FF1A}\(code)\u{3002}"
    }

    static let statusWaiting = "\u{7B49}\u{5F85}"
    static let statusConverting = "\u{8F6C}\u{6362}\u{4E2D}"
    static let statusSuccess = "\u{6210}\u{529F}"
    static let statusFailedText = "\u{5931}\u{8D25}"
    static let statusSkipped = "\u{5DF2}\u{8DF3}\u{8FC7}"
}
