// FileDownloader.swift
//
// Copyright © 2018-2023 Vassilis Panagiotopoulos. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in the
// Software without restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
// and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies
// or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FIESS FOR A PARTICULAR
// PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
// FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation
import SwiftUI
import TermiNetwork
import Combine

struct FileDownloader: View {
    @StateObject var viewModel: ViewModel = .init()

    var body: some View {
        VStack {
            UIHelpers.fieldLabel("File URL")
            UIHelpers.customTextField("File URL...", text: $viewModel.fileURL) { urlString in
                viewModel.updateFilename(urlString)
            }
            UIHelpers.fieldLabel("Filename")
            UIHelpers.customTextField("Filename...", text: $viewModel.fileName)
            if viewModel.downloadStarted {
                if viewModel.bytesTotal > 0 {
                    ProgressView(value: viewModel.progress, total: 100)
                        .padding(.top, 5)
                    Text(String(format: "%.1f of %.1f MB downloaded. (%.2f%%)",
                                Float(viewModel.bytesDownloaded)/1024/1024,
                                Float(viewModel.bytesTotal)/1024/1024,
                                viewModel.progress))
                    .font(.footnote)
                    .padding(.top, 10)
                } else {
                    ProgressView()
                        .padding(.top, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                }

                if !viewModel.downloadRate.isZero {
                    Text(String(format: "Download rate: %.1fMB/s", viewModel.downloadRate))
                        .font(.footnote)
                        .padding(.top, 20)
                }
            }
            if viewModel.downloadFinished {
                UIHelpers.fieldLabel("File saved at")
                UIHelpers.customTextField("File URL...", text: $viewModel.outputFile)
            }
            if let error = viewModel.error {
                Text(error)
                    .padding(.top, 10)
                    .font(.footnote)
                    .foregroundColor(.red)
            }
            Spacer()
            UIHelpers.button(!viewModel.downloadStarted ? "Start Download" : "Stop Download") {
                viewModel.downloadAction()
            }
            .padding(.bottom, 20)
        }
        .onReceive(viewModel.currentTimePublisher,
                   perform: { _ in
            viewModel.downloadRate = Float(viewModel.bytesDownloadedInOneSecond) / Float(1024 * 1024)
            viewModel.bytesDownloadedInOneSecond = 0
        })
        .padding([.leading, .trailing, .top], 20)
        .navigationTitle("File Downloader")
        .onDisappear {
            viewModel.clearAndCancelDownload()
        }
    }
}

extension FileDownloader {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var fileURL: String = "https://releases.ubuntu.com/20.04.1/ubuntu-20.04.1-desktop-amd64.iso"
        @Published var fileName: String = "ubuntu-20.04.1-desktop-amd64.iso"
        @Published var progress: Float = 0
        @Published var downloadRate: Float = 0
        @Published var bytesDownloaded: Int = 0
        @Published var bytesTotal: Int = 0
        @Published var downloadStarted: Bool = false
        @Published var downloadFinished: Bool = false
        @Published var error: String?
        @Published var outputFile: String = ""

        private var configuration: Configuration
        private var downloadTask: Task<(), Never>?
        var currentTimePublisher: Timer.TimerPublisher
        private var cancellables = Set<AnyCancellable>()
        var bytesDownloadedInOneSecond: Int = 0

        init() {
            // Enable verbose
            let configuration = Configuration()
            configuration.verbose = true
            self.configuration = configuration
            self.currentTimePublisher = Self.createTimerPublisher()
        }

        // MARK: UI Helpers
        func updateFilename(_ url: String) {
            fileName = String(url.split(separator: "/").last ?? "")
        }

        // MARK: Actions
        func downloadAction() {
            guard !downloadStarted else {
                clearAndCancelDownload()
                return
            }

            downloadTask = Task {
                await downloadFile()
            }
        }

        // MARK: Helpers

        func downloadFile() async {

            // Construct the final path of the downloaded file
            outputFile = documentsDirectory().appendingPathComponent(fileName).path

            // Remove old file if exists
            removeFileIfNeeded(at: outputFile)

            // Reset download
            error = nil
            resetDownload()

            downloadStarted = true
            downloadFinished = false

            self.currentTimePublisher = Self.createTimerPublisher()
            self.currentTimePublisher
                .connect()
                .store(in: &cancellables)
            do {
                try await Request(method: .get,
                                  url: fileURL,
                                  configuration: configuration)
                .asyncDownload(
                    destinationPath: outputFile,
                    progressUpdate: { [unowned self] (bytesDownloaded, bytesTotal, progress) in
                        let currentDownloadedBytes = bytesDownloaded - self.bytesDownloaded
                        self.progress = progress * 100
                        self.bytesDownloaded = bytesDownloaded
                        self.bytesDownloadedInOneSecond += currentDownloadedBytes
                        self.bytesTotal = bytesTotal
                })
            } catch let error {
                self.error = error.localizedDescription
                resetDownload()
            }
        }

        func resetDownload() {
            downloadStarted = false
            downloadFinished = false
            bytesTotal = 0
            bytesDownloaded = 0
            downloadRate = 0
            bytesDownloadedInOneSecond = 0
            cancellables.removeAll()
        }

        func clearAndCancelDownload() {
            downloadTask?.cancel()
            resetDownload()
        }

        func documentsDirectory() -> URL {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = paths[0]
            return documentsDirectory
        }

        func removeFileIfNeeded(at path: String) {
            try? FileManager.default.removeItem(atPath: path)
        }

        private static func createTimerPublisher() -> Timer.TimerPublisher {
            Timer.TimerPublisher(interval: 1.0,
                                 runLoop: .main,
                                 mode: .default)
        }
    }
}
