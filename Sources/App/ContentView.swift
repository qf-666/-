import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var viewModel = ConversionViewModel()
    @State private var isImporterPresented = false

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.08, green: 0.1, blue: 0.16),
                        Color(red: 0.14, green: 0.22, blue: 0.3),
                        Color(red: 0.77, green: 0.4, blue: 0.18)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        heroCard
                        importCard
                        formatCard
                        actionCard

                        if let outputURL = viewModel.outputURL {
                            resultCard(outputURL: outputURL)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("MusicConvert")
            .fileImporter(
                isPresented: $isImporterPresented,
                allowedContentTypes: [.audio, .data],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case let .success(urls):
                    if let url = urls.first {
                        viewModel.importFile(from: url)
                    } else {
                        viewModel.present(error: CocoaError(.fileReadUnknown))
                    }
                case let .failure(error):
                    viewModel.present(error: error)
                }
            }
            .alert(
                "Unable to Continue",
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { newValue in
                        if !newValue {
                            viewModel.errorMessage = nil
                        }
                    }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Import local audio and convert it to the format you need.")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Standard audio is supported. Platform-specific protected formats are rejected.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))

            HStack(spacing: 8) {
                badge("FLAC")
                badge("MP3")
                badge("WAV")
                badge("OGG")
                badge("AAC")
                badge("M4A")
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        )
    }

    private var importCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Import File")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)

            Button {
                isImporterPresented = true
            } label: {
                Label("Pick Audio from Files", systemImage: "square.and.arrow.down")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(red: 0.08, green: 0.1, blue: 0.16))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }

            if let importedFile = viewModel.importedFile {
                VStack(alignment: .leading, spacing: 6) {
                    Text(importedFile.originalName)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Copied into the app sandbox. Size: \(importedFile.byteCountDescription)")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.75))
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        )
    }

    private var formatCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Output Format")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(AudioFormat.allCases) { format in
                    Button {
                        viewModel.selectedFormat = format
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(format.displayName)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                            Text(format.description)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .lineLimit(2)
                        }
                        .foregroundStyle(viewModel.selectedFormat == format ? Color(red: 0.08, green: 0.1, blue: 0.16) : .white)
                        .frame(maxWidth: .infinity, minHeight: 84, alignment: .leading)
                        .padding(14)
                        .background(
                            viewModel.selectedFormat == format
                                ? Color.white
                                : Color.black.opacity(0.18),
                            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        )
    }

    private var actionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Run Conversion")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)

            Button {
                viewModel.convert()
            } label: {
                HStack(spacing: 12) {
                    if viewModel.isConverting {
                        ProgressView()
                            .tint(Color(red: 0.08, green: 0.1, blue: 0.16))
                    } else {
                        Image(systemName: "waveform.path.badge.plus")
                    }

                    Text(viewModel.isConverting ? "Converting..." : "Start Conversion")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundStyle(Color(red: 0.08, green: 0.1, blue: 0.16))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(red: 0.98, green: 0.86, blue: 0.42), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isConverting)

            if let statusMessage = viewModel.statusMessage {
                Text(statusMessage)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        )
    }

    private func resultCard(outputURL: URL) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Conversion Complete")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)

            Text(outputURL.lastPathComponent)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)

            ShareLink(item: outputURL) {
                Label("Export or Share File", systemImage: "square.and.arrow.up")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.08, green: 0.1, blue: 0.16))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        )
    }

    private func badge(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.black.opacity(0.18), in: Capsule())
    }
}

#Preview {
    ContentView()
}
