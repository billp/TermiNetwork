// MultipartFormDataPartType.swift
//
// Copyright © 2018-2021 Vasilis Panagiotopoulos. All rights reserved.
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

/// Enum to specify multipart/form-data parameters that can be used in upload tasks.
public enum MultipartFormDataPartType {
    /// Simple key-value case.
    /// - Parameters
    ///   - value: The value of the multipart/form-data parameter.
    case value(value: String)

    /// Data case with filename and content-type.
    /// - Parameters
    ///   - data: The data  to upload of the multipart/form-data parameter.
    ///   - filename: The filename value of the multipart/form-data parameter.
    ///   - contentType: The Content-Type of the multipart/form-data parameter.
    case data(data: Data, filename: String?, contentType: String?)

    /// File URL case.
    /// - Parameters
    ///   - url: The file URL that contains the data that will be uploaded.
    case url(_ url: URL)
}
