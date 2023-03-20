// FileUploader.swift
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

struct FileUploader: View {
    @StateObject var viewModel: ViewModel

    var body: some View {
        VStack {
            UIHelpers.button("🌄 Select Photo",
                             action: {
                viewModel.imageUrl = nil
                viewModel.fileChecksum = nil
                viewModel.uploadedFileChecksum = nil
                viewModel.resetUpload()
                viewModel.showCaptureImageView.toggle()
            })
            .disabled(viewModel.uploadStarted)

            if viewModel.imageUrl != nil {
                UIHelpers.fieldLabel("Filename")
                UIHelpers.customTextField("Filename...", text: $viewModel.fileName)
            }
            if let fileChecksum = viewModel.fileChecksum {
                Text("Local file checksum")
                    .font(.footnote)
                    .bold()
                    .padding(.top, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                    .padding(.bottom, 3)
                Text(fileChecksum)
                    .font(.footnote)
            }
            if let uploadedFileChecksum = viewModel.uploadedFileChecksum {
                Text("Uploaded file checksum")
                    .font(.footnote)
                    .bold()
                    .padding(.top, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                    .padding(.bottom, 3)
                Text(uploadedFileChecksum)
                    .font(.footnote)
            }
            if viewModel.showCaptureImageView {
                CaptureImageView(isShown: $viewModel.showCaptureImageView,
                                 imageUrl: $viewModel.imageUrl,
                                 fileName: $viewModel.fileName,
                                 checksum: $viewModel.fileChecksum)
            }
            if viewModel.uploadStarted {
                if viewModel.bytesTotal > 0 {
                    ProgressView(value: viewModel.progress, total: 100)
                        .padding(.top, 5)
                    Text(String(format: "%.1f of %.1f MB uploaded.",
                                Float(viewModel.bytesUploaded)/1024/1024,
                                Float(viewModel.bytesTotal)/1024/1024))
                        .font(.footnote)
                        .padding(.top, 10)
                } else {
                    ProgressView()
                        .padding(.top, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                }
            }
            if viewModel.uploadFinished && viewModel.fileChecksum == viewModel.uploadedFileChecksum {
                Text("Success")
                    .font(.footnote)
                    .bold()
                    .padding(.top, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                    .foregroundColor(.green)
            }
            if let error = viewModel.error {
                Text(error)
                    .padding(.top, 10)
                    .font(.footnote)
                    .foregroundColor(.red)
            }
            Spacer()
            UIHelpers.button(!viewModel.uploadStarted ? "Start Upload" : "Stop Upload",
                             action: {
                viewModel.uploadAction()
            })
            .padding(.bottom, 20)

        }
        .padding([.leading, .trailing, .top], 20)
        .navigationTitle("File Uploader")
        .onDisappear(perform: {
            viewModel.clearAndCancelUpload()
        })
    }
}

extension FileUploader {
    class ViewModel: ObservableObject {
        @Published var fileName: String = ""
        @Published var fileChecksum: String?
        @Published var uploadedFileChecksum: String?
        @Published var progress: Float = 0
        @Published var bytesUploaded: Int = 0
        @Published var bytesTotal: Int = 0
        @Published var uploadStarted: Bool = false
        @Published var uploadFinished: Bool = false
        @Published var error: String?
        @Published var outputFile: String = ""
        @Published var imageUrl: URL?
        @Published var showCaptureImageView: Bool = false

        private var uploadTask: Task<(), Never>?

        func resetUpload() {
            uploadStarted = false
            uploadFinished = false
            bytesTotal = 0
            bytesUploaded = 0
        }

        func clearAndCancelUpload() {
            uploadTask?.cancel()
            resetUpload()
        }

        func documentsDirectory() -> URL {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = paths[0]
            return documentsDirectory
        }

        // MARK: Helpers

        @MainActor
        func uploadFile() async {
            guard let imageUrl = imageUrl else {
                return
            }

            // Enable verbose
            let configuration = Configuration()
            configuration.verbose = true

            // Construct the final path of the uploaded file
            outputFile = documentsDirectory().appendingPathComponent(fileName).path

            // Remove old file if exists
            removeFileIfNeeded(at: outputFile)

            // Reset upload
            error = nil
            uploadedFileChecksum = nil

            resetUpload()

            // Start the request

            do {
                uploadStarted = true
                uploadFinished = false

                let response = try await Client<MiscRepository>()
                    .request(for: .upload(fileUrl: imageUrl))
                    .asyncUpload(
                        using: FileUploadTransformer.self,
                        progressUpdate: { [weak self] bytesProcessed, totalBytes, progress in
                            guard let self = self else { return }
                            self.progress = progress * 100
                            self.bytesUploaded = bytesProcessed
                            self.bytesTotal = totalBytes
                        }
                    )
                self.uploadStarted = false
                self.uploadFinished = true
                self.uploadedFileChecksum = response.checksum
            } catch let error {
                self.error = error.localizedDescription
                self.resetUpload()
            }
        }

        func removeFileIfNeeded(at path: String) {
            try? FileManager.default.removeItem(atPath: path)
        }

        // MARK: UI Helpers
        func updateFilename(_ url: String) {
            self.fileName = String(url.split(separator: "/").last ?? "")
        }

        // MARK: Actions
        @MainActor func uploadAction() {
            guard !uploadStarted else {
                clearAndCancelUpload()
                return
            }

            uploadTask = Task {
                await uploadFile()
            }
        }
    }
}

struct CaptureImageView {
    @Binding var isShown: Bool
    @Binding var imageUrl: URL?
    @Binding var fileName: String
    @Binding var checksum: String?

    func makeCoordinator() -> Coordinator {
        return Coordinator(isShown: $isShown,
                           url: $imageUrl,
                           fileName: $fileName,
                           checksum: $checksum)
    }
}

extension CaptureImageView: UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<CaptureImageView>)
    -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
}

class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @Binding var isCoordinatorShown: Bool
    @Binding var urlInCoordinator: URL?
    @Binding var fileName: String
    @Binding var checksum: String?

    init(isShown: Binding<Bool>,
         url: Binding<URL?>,
         fileName: Binding<String>,
         checksum: Binding<String?>) {
        _isCoordinatorShown = isShown
        _urlInCoordinator = url
        _fileName = fileName
        _checksum = checksum
    }
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let url = info[UIImagePickerController.InfoKey.imageURL] as? URL else {
            return
        }
        urlInCoordinator = url
        isCoordinatorShown = false
        fileName = url.lastPathComponent
        checksum = FileUploaderUtils.sha256(url: url)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isCoordinatorShown = false
    }
}
