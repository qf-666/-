# MusicConvert

Unsigned iOS batch audio converter built with `SwiftUI`. The repository is configured to generate an unsigned `.ipa` through GitHub Actions.

## Features

- Import multiple local audio files or an entire folder from the Files app
- Queue files for batch conversion with per-item status, logs, and summary stats
- Convert to `.flac`, `.mp3`, `.wav`, `.ogg`, `.aac`, `.m4a`, `.wma`, `.aiff`, and `ALAC`
- Pause or stop the queue between files
- Export each converted file with the native share sheet
- Build an unsigned `.ipa` artifact in GitHub Actions

## Compliance Boundary

This project only handles standard, unprotected local audio files.

It explicitly refuses platform-specific protected formats and does not implement decryption, shell removal, or protection bypass for:

- `kgm`
- `kgma`
- `vpr`
- `ncm`
- `qmc*`

## Local Development

1. Install Xcode and Homebrew on macOS.
2. Install XcodeGen with `brew install xcodegen`.
3. Generate the project with `xcodegen generate`.
4. Open `MusicConvert.xcodeproj`.

## Build Pipeline

The workflow:

1. Installs XcodeGen
2. Generates the Xcode project
3. Builds the iOS app in Release mode
4. Packages an unsigned `.ipa`
5. Uploads the artifact

## Dependencies

- [kewlbear/FFmpeg-iOS](https://github.com/kewlbear/FFmpeg-iOS)
- [kewlbear/FFmpeg-iOS-Support](https://github.com/kewlbear/FFmpeg-iOS-Support)
