// Request+FileOperations.swift
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

extension Request {
    // MARK: Upload - Decodable

    /// Executed when the upload request is succeeded and the response has successfully deserialized.
    ///
    /// - parameters:
    ///    - responseType: The type of the model that will be deserialized and will be passed to the success block.
    ///    - progressUpdate: specifies a progress callback to get upload progress updates.
    ///    - responseHandler: The completion handler with the deserialized object
    /// - returns: The Request object.
    @discardableResult
    public func upload<T: Decodable>(responseType: T.Type,
                                     progressUpdate: ProgressCallbackType?,
                                     responseHandler: @escaping SuccessCallback<T>) -> Request {
        self.successCompletionHandler = self.makeDecodableResponseSuccessHandler(decodableType: T.self,
                                                                                 responseHandler: responseHandler)
        executeUploadRequestIfNeeded(withProgressCallback: progressUpdate)
        return self
    }

    // MARK: Upload - Transformers

    /// Executed when the request is succeeded and the response has successfully transformed.
    ///
    /// - parameters:
    ///    - transformer: The transformer type that handles the transformation.
    ///    - progressUpdate: specifies a progress callback to get upload progress updates.
    ///    - responseHandler: The completion handler with the deserialized object as ToType.
    /// - returns: The Request object.
    @discardableResult
    public func upload<FromType: Decodable, ToType>(transformer: Transformer<FromType, ToType>.Type,
                                                    progressUpdate: ProgressCallbackType?,
                                                    responseHandler: @escaping SuccessCallback<ToType>)
                                            -> Request {
        self.successCompletionHandler = self.makeTransformedResponseSuccessHandler(transformer: transformer,
                                                                                   responseHandler: responseHandler)
        executeUploadRequestIfNeeded(withProgressCallback: progressUpdate)
        return self
    }

    // MARK: Upload - String

    /// Executed when the request is succeeded and the response is String type.
    ///
    /// - parameters:
    ///    - responseType: A type of String.
    ///    - progressUpdate: specifies a progress callback to get upload progress updates.
    ///    - responseHandler: The completion handler with the String object.
    /// - returns: The Request object.
    @discardableResult
    public func upload(responseType: String.Type,
                       progressUpdate: ProgressCallbackType?,
                       responseHandler: @escaping (String) -> Void) -> Request {
        self.successCompletionHandler = self.makeStringResponseSuccessHandler(responseHandler: responseHandler)
        executeUploadRequestIfNeeded(withProgressCallback: progressUpdate)
        return self
    }

    // MARK: Upload - Data

    /// Executed when the request is succeeded and the response is Data type.
    ///
    /// - parameters:
    ///    - responseType: A type of Data.
    ///    - progressUpdate: specifies a progress callback to get upload progress updates.
    ///    - responseHandler: The completion handler with the Data object.
    /// - returns: The Request object.
    @discardableResult
    public func upload(responseType: Data.Type,
                       progressUpdate: ProgressCallbackType?,
                       responseHandler: @escaping SuccessCallback<Data>) -> Request {
        self.successCompletionHandler = self.makeDataResponseSuccessHandler(responseHandler: responseHandler)
        executeUploadRequestIfNeeded(withProgressCallback: progressUpdate)
        return self
    }

    // MARK: Download

    /// Executed when the download request is succeeded.
    ///
    /// - parameters:
    ///    - filePath: The destination file path to save the file.
    ///    - progressUpdate: specifies a progress callback to get upload progress updates.
    ///    - completionHandler: The completion handler with the Data object.
    /// - returns: The Request object.
    @discardableResult
    public func download(filePath: String,
                         progressUpdate: ProgressCallbackType?,
                         completionHandler: @escaping SuccessCallbackWithoutType) -> Request {
        self.successCompletionHandler = self.makeResponseSuccessHandler(responseHandler: completionHandler)
        executeDownloadRequestIfNeeded(withFilePath: filePath,
                                       progressUpdate: progressUpdate)
        return self
    }
}
