// Types.swift
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

/// Progress callback type
/// - parameters:
///     - bytesProcessed: The total size of bytes sent/downloaded to/from server.
///     - totalBytes: The total size of upload/download data.
///     - progress: Download/Upload progress
public typealias ProgressCallbackType = (_ bytesProcessed: Int,
                                         _ totalBytes: Int,
                                         _ progress: Float) -> Void

/// Custom type for success data task.
/// - parameters:
///     - object: The object to be returned as T type.
public typealias SuccessCallback<T> = (_ object: T) -> Void
/// Custom type for success data task without type.
public typealias SuccessCallbackWithoutType = () -> Void
/// Custom type for download success data task.
public typealias DownloadSuccessCallback = () -> Void
/// Custom type for failure data task.

/// Failure callback (Obsolete).
/// - parameters:
///     - error: The the error that caused the request to fail.
///     - data: The response data if any.
public typealias FailureCallback = (_ error: TNError, _ data: Data?) -> Void
/// Custom type for failure data task without type.
/// - parameters:
///     - error: The the error that caused the request to fail.
public typealias FailureCallbackWithoutType = (TNError) -> Void
/// Custom type for failure data task with custom type.
/// - parameters:
///     - object: The object to be returned as T type.
///     - error: The the error that caused the request to fail.
public typealias FailureCallbackWithType<T> = (_ object: T?, _ error: TNError) -> Void
