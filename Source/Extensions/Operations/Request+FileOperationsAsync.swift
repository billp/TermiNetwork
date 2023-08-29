// Request+FileOperationsAsync.swift
//
// Copyright © 2018-2023 Vasilis Panagiotopoulos. All rights reserved.
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

@MainActor public extension Request {
    // MARK: - Upload Operations

    /// Executed when the upload request is succeeded and the response has successfully deserialized.
    ///
    /// - parameters:
    ///    - responseType: The type of the model that will be deserialized and will be passed to the success block.
    ///    - progressUpdate: specifies a progress callback to get upload progress updates.
    /// - returns: The decodable type.
    /// 
    @discardableResult
    func asyncUpload<T: Decodable>(as type: T.Type,
                                   progressUpdate: ProgressCallbackType?) async throws -> T {
        try await withTaskCancellationHandler {
            checkUploadParamsType()
            try checkTaskCancellation()
            return try await withCheckedThrowingContinuation { configuration in
                upload(progressUpdate: progressUpdate)
                    .success(responseType: type) { response in
                        configuration.resume(returning: response)
                    }
                    .failure { error in
                        configuration.resume(throwing: error)
                    }
            }
        } onCancel: { [weak self] in
            self?.cancel()
        }
    }

    /// Executes an asynchronous upload request and returns the decodable type based on transformer.
    ///
    /// - Parameters:
    ///    - using: The transformer type.
    ///    - progressUpdate: specifies a progress callback to get upload progress updates.
    /// - returns: The decoded type based on the transformer.
    /// - throws: A TNError in case of failure.
    @discardableResult
    func asyncUpload<From: Decodable, To>(
        using transformer: Transformer<From, To>.Type,
        progressUpdate: ProgressCallbackType? = nil
    ) async throws -> To {
        try await withTaskCancellationHandler {
            checkUploadParamsType()
            try checkTaskCancellation()
            return try await withCheckedThrowingContinuation { configuration in
                upload(progressUpdate: progressUpdate)
                    .success(transformer: transformer) { response in
                        configuration.resume(returning: response)
                    }
                    .failure { error in
                        configuration.resume(throwing: error)
                    }
            }
        } onCancel: { [weak self] in
            self?.cancel()
        }
    }

    /// Executed when the request is succeeded and the response is String type.
    ///
    /// - parameters:
    ///    - as: A type of String.
    ///    - progressUpdate: specifies a progress callback to get upload progress updates.
    /// - returns: The String response.
    @discardableResult
    func asyncUpload(as type: String.Type,
                     progressUpdate: ProgressCallbackType?) async throws -> String {
        try await withTaskCancellationHandler {
            checkUploadParamsType()
            try checkTaskCancellation()
            return try await withCheckedThrowingContinuation { configuration in
                upload(progressUpdate: progressUpdate)
                    .success(responseType: type) { response in
                        configuration.resume(returning: response)
                    }
                    .failure { error in
                        configuration.resume(throwing: error)
                    }
            }
        } onCancel: { [weak self] in
            self?.cancel()
        }
    }

    // MARK: Upload - Data

    /// Executed when the request is succeeded and the response is Data type.
    ///
    /// - parameters:
    ///    - responseType: A type of Data.
    ///    - progressUpdate: specifies a progress callback to get upload progress updates.
    /// - returns: The Data response.
    @discardableResult
    func asyncUpload(as type: Data.Type,
                     progressUpdate: ProgressCallbackType?) async throws -> Data {
        try await withTaskCancellationHandler {
            checkUploadParamsType()
            try checkTaskCancellation()
            return try await withCheckedThrowingContinuation { configuration in
                upload(progressUpdate: progressUpdate)
                    .success(responseType: type) { response in
                        configuration.resume(returning: response)
                    }
                    .failure { error in
                        configuration.resume(throwing: error)
                    }
            }
        } onCancel: { [weak self] in
            self?.cancel()
        }
    }

    /// Executes an asynchronous download request and returns by throwing and error if it fails.
    /// 
    /// - Parameters:
    ///    - destinationPath: The destination file path to save the file.
    ///    - progressUpdate: specifies a progress callback to get upload progress updates.
    /// - returns: The response data as string.
    /// - throws: A TNError in case of failure.
    func asyncDownload(
        destinationPath: String,
        progressUpdate: ProgressCallbackType? = nil
    ) async throws {
        try await withTaskCancellationHandler {
            checkUploadParamsType()
            try checkTaskCancellation()
            return try await withCheckedThrowingContinuation { configuration in
                download(destinationPath: destinationPath,
                         progressUpdate: progressUpdate)
                .success {
                    configuration.resume()
                }
                .failure { error in
                    configuration.resume(throwing: error)
                }
            }
        } onCancel: { [weak self] in
            self?.cancel()
        }
    }
}
