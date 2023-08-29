// Request+FileOperations.swift
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

public extension Request {
    // MARK: Upload - Data

    /// Executed when the request is succeeded and the response is Data type.
    ///
    /// - parameters:
    ///    - progressUpdate: specifies a progress callback to get upload progress updates.
    /// - returns: The Request object.
    @discardableResult
    func upload(progressUpdate: ProgressCallbackType? = nil) -> Request {
        checkUploadParamsType()

        self.requestType = .upload
        self.progressUpdate = progressUpdate

        return self
    }

    // MARK: Download

    /// Executed when the download request is succeeded.
    ///
    /// - parameters:
    ///    - destinationPath: The destination file path to save the file.
    ///    - progressUpdate: specifies a progress callback to get upload progress updates.
    ///    - completionHandler: The completion handler with the Data object.
    /// - returns: The Request object.
    @discardableResult
    func download(destinationPath: String,
                  progressUpdate: ProgressCallbackType?) -> Request {
        checkUploadParamsType()

        self.requestType = .download(destinationPath)
        self.progressUpdate = progressUpdate

        executeCurrentOperationIfNeeded()

        return self
    }

    /// Used internally to verify upload multipart/form-data params.
    ///
    /// - throws: TNError.uploadOperationInvalidParams.
    internal func checkUploadParamsType() {
        guard let params else { return }
        if !params.values.allSatisfy({ $0 is MultipartFormDataPartType }) {
            fatalError("""
"Upload param values should have a type of \(MultipartFormDataPartType.self).
Refer to documentation for more details.
""")
        }
    }
}
