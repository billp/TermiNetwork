// Request+DataOperations.swift
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

#if os(iOS)
import UIKit
#endif

extension Request {
    // MARK: Empty

    /// Executed when the request is failed.
    ///
    /// - parameters:
    ///    - responseHandler: The completion handler with the error.
    /// - returns: The Request object.
    @discardableResult
    public func failure(responseHandler: @escaping FailureCallbackWithoutType) -> Request {
        self.failureCompletionHandler = self.makeResponseFailureHandler(responseHandler: responseHandler)
        executeDataRequestIfNeeded()
        return self
    }

    // MARK: Decodable

    /// Executed when the request is succeeded and the response has successfully deserialized.
    ///
    /// - parameters:
    ///    - responseType: The type of the model that will be deserialized and will be passed to the success block.
    ///    - responseHandler: The completion handler with the deserialized object
    /// - returns: The Request object.
    @discardableResult
    public func success<T: Decodable>(responseType: T.Type,
                                      responseHandler: @escaping SuccessCallback<T>) -> Request {
        self.successCompletionHandler = self.makeDecodableResponseSuccessHandler(decodableType: T.self,
                                                                                 responseHandler: responseHandler)
        executeDataRequestIfNeeded()
        return self
    }

    /// Executed when the request is failed. The response is being deserialized if possible, nil otherwise.
    ///
    /// - parameters:
    ///    - responseType: The type of the model that will be deserialized and will be passed to the success block.
    ///    - responseHandler: The completion handler that provides the deserialized object and the error.
    /// - returns: The Request object.
    @discardableResult
    public func failure<T: Decodable>(responseType: T.Type,
                                      responseHandler: @escaping FailureCallbackWithType<T>) -> Request {
        self.failureCompletionHandler = self.makeDecodableResponseFailureHandler(decodableType: T.self,
                                                                                 responseHandler: responseHandler)
        executeDataRequestIfNeeded()
        return self
    }

    // MARK: Transformer

    /// Executed when the request is succeeded and the response has successfully transformed.
    ///
    /// - parameters:
    ///    - transformer: The transformer type that handles the transformation.
    ///    - responseHandler: The completion handler with the deserialized object as ToType.
    /// - returns: The Request object.
    @discardableResult
    public func success<FromType: Decodable, ToType>(transformer: Transformer<FromType, ToType>.Type,
                                                     responseHandler: @escaping SuccessCallback<ToType>)
                                            -> Request {
        self.successCompletionHandler = self.makeTransformedResponseSuccessHandler(transformer: transformer,
                                                                                   responseHandler: responseHandler)
        executeDataRequestIfNeeded()
        return self
    }

    /// Executed when the request is failed. The response is being transformed to ToType if
    /// possible, nil otherwise.
    ///
    /// - parameters:
    ///    - transformer: The transformer type that handles the transformation.
    ///    - responseHandler: The completion handler with the deserialized object as ToType.
    /// - returns: The Request object.
    @discardableResult
    public func failure<FromType: Decodable, ToType>(transformer: Transformer<FromType, ToType>.Type,
                                                     responseHandler: @escaping FailureCallbackWithType<ToType>)
                                            -> Request {
        self.failureCompletionHandler = self.makeTransformedResponseFailureHandler(transformer: transformer,
                                                                                   responseHandler: responseHandler)
        executeDataRequestIfNeeded()
        return self
    }

    // MARK: Image

    /// Executed when the request is succeeded and the response is a valid Image.
    ///
    /// - parameters:
    ///    - responseType: One of UIImage or NSImage or types.
    ///    - responseHandler: The completion handler with the Image object.
    /// - returns: The Request object.
    @discardableResult
    public func success(responseType: ImageType.Type,
                        responseHandler: @escaping SuccessCallback<ImageType>) -> Request {
        self.successCompletionHandler = self.makeImageResponseSuccessHandler(responseHandler: responseHandler)
        executeDataRequestIfNeeded()
        return self
    }

    // MARK: String

    /// Executed when the request is succeeded and the response is a valid String.
    ///
    /// - parameters:
    ///    - responseType: A type of String.
    ///    - responseHandler: The completion handler with the String object.
    /// - returns: The Request object.
    @discardableResult
    public func success(responseType: String.Type,
                        responseHandler: @escaping SuccessCallback<String>) -> Request {
        self.successCompletionHandler = self.makeStringResponseSuccessHandler(responseHandler: responseHandler)
        executeDataRequestIfNeeded()
        return self
    }

    /// Executed when the request is failed. The response is being converted to String value if possible.
    ///
    /// - parameters:
    ///    - responseType: A type of String.
    ///    - responseHandler: The completion handler with the String object if possible, nil otherwise.
    /// - returns: The Request object.
    @discardableResult
    public func failure(responseType: String.Type,
                        responseHandler: @escaping FailureCallbackWithType<String>) -> Request {
        self.failureCompletionHandler = self.makeStringResponseFailureHandler(responseHandler: responseHandler)
        executeDataRequestIfNeeded()
        return self
    }

    // MARK: Data

    /// Executed when the request is succeeded and the response is Data type.
    ///
    /// - parameters:
    ///    - responseType: A type of Data.
    ///    - responseHandler: The completion handler with the Data object.
    /// - returns: The Request object.
    @discardableResult
    public func success(responseType: Data.Type,
                        responseHandler: @escaping SuccessCallback<Data>) -> Request {
        self.successCompletionHandler = self.makeDataResponseSuccessHandler(responseHandler: responseHandler)
        executeDataRequestIfNeeded()
        return self
    }

    /// Executed when the request is failed. The response is being converted to Data value if possible.
    ///
    /// - parameters:
    ///    - responseType: A type of String.
    ///    - responseHandler: The completion handler with the Data object if possible, nil otherwise.
    /// - returns: The Request object.
    @discardableResult
    public func failure(responseType: Data.Type,
                        responseHandler: @escaping FailureCallbackWithType<Data>) -> Request {
        self.failureCompletionHandler = self.makeDataResponseFailureHandler(responseHandler: responseHandler)
        executeDataRequestIfNeeded()
        return self
    }
}
