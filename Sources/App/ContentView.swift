import SwiftUI
import UniformTypeIdentifiers

private enum DashboardPanel: String, CaseIterable, Identifiable {
    case queue
    case log
    case stats

    var id: String { rawValue }

    var title: String {
        switch self {
        case .queue:
            return AppText.panelQueue
        case .log:
            return AppText.panelLog
        case .stats:
            return AppText.panelStats
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ConversionViewModel()
    @State private var isAudioImporterPresented = false
    @State private var isFolderImporterPresented = false
    @State private var selectedPanel: DashboardPanel = .queue

    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ZStack {
                    backgroundView

                    ScrollView {
                        VStack(spacing: 18) {
                            heroCard
                            summaryStrip

                            if geometry.size.width > 900 {
                                HStack(alignment: .top, spacing: 18) {
                                    controlColumn
                                        .frame(maxWidth: 320)
                                    detailColumn
                                }
                            } else {
                                VStack(spacing: 18) {
                                    controlColumn
                                    detailColumn
                                }
                            }
                        }
                        .padding(20)
                    }
                }
                .navigationTitle(AppText.appTitle)
            }
        }
        .fileImporter(
            isPresented: $isAudioImporterPresented,
            allowedContentTypes: [.audio],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case let .success(urls):
                guard !urls.isEmpty else {
                    viewModel.present(error: CocoaError(.fileReadUnknown))
                    return
                }
                viewModel.importFiles(from: urls)
            case let .failure(error):
                viewModel.present(error: error)
            }
        }
        .fileImporter(
            isPresented: $isFolderImporterPresented,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case let .success(urls):
                guard let folderURL = urls.first else {
                    viewModel.present(error: CocoaError(.fileReadUnknown))
                    return
                }
                viewModel.importFolder(from: folderURL)
            case let .failure(error):
                viewModel.present(error: error)
            }
        }
        .alert(
            AppText.alertTitle,
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { shouldShow in
                    if !shouldShow {
                        viewModel.errorMessage = nil
                    }
                }
            )
        ) {
            Button(AppText.alertButton, role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var backgroundView: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.07, blue: 0.11),
                    Color(red: 0.08, green: 0.16, blue: 0.24),
                    Color(red: 0.66, green: 0.33, blue: 0.16)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(.white.opacity(0.08))
                .frame(width: 260, height: 260)
                .blur(radius: 6)
                .offset(x: 170, y: -250)

            Circle()
                .fill(Color(red: 0.98, green: 0.86, blue: 0.42).opacity(0.18))
                .frame(width: 320, height: 320)
                .blur(radius: 14)
                .offset(x: -180, y: 260)
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(AppText.heroTitle)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(AppText.heroSubtitle)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.82))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(AudioFormat.allCases) { format in
                        Text(format.displayName)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.black.opacity(0.2), in: Capsule())
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(cardBackground)
    }

    private var summaryStrip: some View {
        HStack(spacing: 12) {
            statChip(title: AppText.statTotal, value: "\(viewModel.totalCount)")
            statChip(title: AppText.statWaiting, value: "\(viewModel.waitingCount)")
            statChip(title: AppText.statSuccess, value: "\(viewModel.successCount)")
            statChip(title: AppText.statFailed, value: "\(viewModel.failedCount)")
        }
    }

    private var controlColumn: some View {
        VStack(spacing: 18) {
            importCard
            settingsCard
            controlsCard
        }
    }

    private var detailColumn: some View {
        VStack(spacing: 18) {
            progressCard
            panelCard
        }
    }

    private var importCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle(AppText.sectionImport)

            actionButton(
                title: AppText.buttonImportFolder,
                systemImage: "folder.badge.plus"
            ) {
                isFolderImporterPresented = true
            }

            actionButton(
                title: AppText.buttonSelectFiles,
                systemImage: "doc.badge.plus"
            ) {
                isAudioImporterPresented = true
            }

            secondaryButton(
                title: AppText.buttonClearQueue,
                systemImage: "trash"
            ) {
                viewModel.clearQueue()
            }
            .disabled(viewModel.isConverting)

            Text(queueSummaryText)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.78))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(cardBackground)
    }

    private var settingsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle(AppText.sectionSettings)

            VStack(alignment: .leading, spacing: 6) {
                Text(AppText.labelOutputFormat)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.82))

                Picker(AppText.labelOutputFormat, selection: $viewModel.selectedFormat) {
                    ForEach(AudioFormat.allCases) { format in
                        Text(format.displayName).tag(format)
                    }
                }
                .pickerStyle(.menu)
                .tint(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(AppText.labelQuality)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.82))

                Picker(AppText.labelQuality, selection: $viewModel.selectedQuality) {
                    ForEach(AudioQuality.allCases) { quality in
                        Text(quality.localizedDisplayName).tag(quality)
                    }
                }
                .pickerStyle(.menu)
                .tint(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(AppText.labelDestination)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.82))
                Text(AppText.labelDestinationDetail)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.72))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(cardBackground)
    }

    private var controlsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle(AppText.sectionControls)

            actionButton(
                title: startButtonTitle,
                systemImage: "bolt.fill",
                fill: Color(red: 0.98, green: 0.86, blue: 0.42),
                foreground: Color(red: 0.08, green: 0.1, blue: 0.16)
            ) {
                viewModel.startConversion()
            }
            .disabled(viewModel.isConverting || viewModel.waitingCount == 0)

            HStack(spacing: 10) {
                secondaryButton(
                    title: viewModel.isPaused ? AppText.buttonResume : AppText.buttonPause,
                    systemImage: viewModel.isPaused ? "play.fill" : "pause.fill"
                ) {
                    viewModel.togglePause()
                }
                .disabled(!viewModel.isConverting)

                secondaryButton(
                    title: AppText.buttonStop,
                    systemImage: "stop.fill"
                ) {
                    viewModel.stopConversion()
                }
                .disabled(!viewModel.isConverting)
            }

            HStack(spacing: 10) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 10, height: 10)
                Text(viewModel.statusMessage)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.82))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(cardBackground)
    }

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle(AppText.sectionProgress)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(AppText.labelOverall)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.82))
                    Spacer()
                    Text("\(Int(viewModel.overallProgress * 100))%")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }

                ProgressView(value: viewModel.overallProgress)
                    .tint(Color(red: 0.98, green: 0.86, blue: 0.42))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(AppText.labelCurrentFile)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.82))

                HStack(spacing: 10) {
                    if viewModel.isConverting {
                        ProgressView()
                            .tint(.white)
                    }

                    Text(viewModel.currentFileName)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(cardBackground)
    }

    private var panelCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker(AppText.panelQueue, selection: $selectedPanel) {
                ForEach(DashboardPanel.allCases) { panel in
                    Text(panel.title).tag(panel)
                }
            }
            .pickerStyle(.segmented)

            switch selectedPanel {
            case .queue:
                queuePanel
            case .log:
                logPanel
            case .stats:
                statsPanel
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(cardBackground)
    }

    private var queuePanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            if viewModel.queueItems.isEmpty {
                emptyState(
                    title: AppText.emptyQueueTitle,
                    message: AppText.emptyQueueMessage
                )
            } else {
                ForEach(viewModel.queueItems) { item in
                    queueRow(item)
                }
            }
        }
    }

    private var logPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            if viewModel.activityLog.isEmpty {
                emptyState(
                    title: AppText.emptyLogTitle,
                    message: AppText.emptyLogMessage
                )
            } else {
                ForEach(viewModel.activityLog) { entry in
                    Text(entry.formattedLine)
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.82))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
        }
    }

    private var statsPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            statRow(title: AppText.statsQueuedFiles, value: "\(viewModel.totalCount)")
            statRow(title: AppText.statsWaiting, value: "\(viewModel.waitingCount)")
            statRow(title: AppText.statsConverted, value: "\(viewModel.successCount)")
            statRow(title: AppText.statsFailed, value: "\(viewModel.failedCount)")
            statRow(title: AppText.statsRemaining, value: "\(viewModel.remainingCount)")
            statRow(
                title: AppText.statsSuccessRate,
                value: viewModel.totalCount == 0
                    ? "0%"
                    : String(format: "%.1f%%", (Double(viewModel.successCount) / Double(viewModel.totalCount)) * 100)
            )
        }
    }

    private func queueRow(_ item: ConversionQueueItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.file.originalName)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text("\(item.file.fileExtension.uppercased())  |  \(item.file.byteCountDescription)")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                }

                Spacer()

                Text(item.status.title)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(statusForeground(for: item.status))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(statusBackground(for: item.status), in: Capsule())
            }

            if let detail = item.detail {
                Text(detail)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.76))
            }

            if let outputURL = item.outputURL {
                ShareLink(item: outputURL) {
                    Label(AppText.buttonExportFile, systemImage: "square.and.arrow.up")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(red: 0.08, green: 0.1, blue: 0.16))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func statChip(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white.opacity(0.11), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func statRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.78))
            Spacer()
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func emptyState(title: String, message: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(message)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(Color.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
    }

    private func actionButton(
        title: String,
        systemImage: String,
        fill: Color = .white,
        foreground: Color = Color(red: 0.08, green: 0.1, blue: 0.16),
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(foreground)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(fill, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func secondaryButton(
        title: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(.white.opacity(0.11))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(.white.opacity(0.16), lineWidth: 1)
            )
    }

    private var queueSummaryText: String {
        if viewModel.totalCount == 0 {
            return AppText.queueSummaryEmpty
        }

        if viewModel.totalCount == 1 {
            return AppText.queueSummarySingle
        }

        return AppText.queueSummary(total: viewModel.totalCount, waiting: viewModel.waitingCount)
    }

    private var startButtonTitle: String {
        if viewModel.totalCount <= 1 {
            return AppText.buttonStartSingle
        }

        return "\(AppText.buttonStartBatchPrefix) (\(viewModel.waitingCount))"
    }

    private var statusColor: Color {
        if viewModel.isPaused {
            return .yellow
        }

        return viewModel.isConverting ? .orange : .green
    }

    private func statusBackground(for status: ConversionQueueItem.Status) -> Color {
        switch status {
        case .waiting:
            return .white.opacity(0.16)
        case .converting:
            return .yellow.opacity(0.2)
        case .success:
            return .green.opacity(0.24)
        case .failed:
            return .red.opacity(0.24)
        case .skipped:
            return .orange.opacity(0.24)
        }
    }

    private func statusForeground(for status: ConversionQueueItem.Status) -> Color {
        switch status {
        case .waiting:
            return .white
        case .converting:
            return .yellow
        case .success:
            return .green
        case .failed:
            return .red
        case .skipped:
            return .orange
        }
    }
}

#Preview {
    ContentView()
}
