// Request+ResponseTypes.swift
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
    // MARK: Empty

    func makeResponseFailureHandler(responseHandler: @escaping (TNError) -> Void)
                            -> (TNError, Data?, URLResponse?) -> Void {
        return { error, data, urlResponse  in
            self.handleDataTaskCompleted(with: data,
                                         error: error,
                                         onFailureCallback: { responseHandler(error) })
        }
    }

    func makeResponseSuccessHandler(responseHandler: @escaping () -> Void)
                            -> (Data?, URLResponse?) -> Void {
        return { data, urlResponse  in
            self.handleDataTaskCompleted(with: data,
                                         urlResponse: urlResponse,
                                         onSuccessCallback: { responseHandler() })
        }
    }

    // MARK: Decodable

    func makeDecodableResponseSuccessHandler<T: Decodable>(decodableType: T.Type,
                                                           responseHandler: @escaping (T) -> Void)
                            -> ((Data, URLResponse?) -> Void)? {
        return { data, urlResponse in
            let object: T!

            do {
                object = try data.deserializeJSONData(withKeyDecodingStrategy:
                                                        self.configuration.keyDecodingStrategy) as T
            } catch let error {
                let tnError = TNError.cannotDeserialize(String(describing: T.self), error)
                self.handleDataTaskCompleted(with: data,
                                             urlResponse: urlResponse,
                                             error: tnError,
                                             onFailureCallback: {
                                                self.failureCompletionHandler?(tnError, data, urlResponse)
                                             })
                return
            }

            self.handleDataTaskCompleted(with: data,
                                         urlResponse: self.urlResponse,
                                         onSuccessCallback: { responseHandler(object) })
        }
    }

    func makeDecodableResponseFailureHandler<T: Decodable>(decodableType: T.Type,
                                                           responseHandler: @escaping (T?, TNError) -> Void)
                            -> (TNError, Data?, URLResponse?) -> Void {
        return { error, data, urlResponse  in
            // Check to see if there is already a deserialization error from success
            if case .cannotDeserialize = error {
                responseHandler(nil, error)
                return
            }

            var object: T?

            if let data = data {
                do {
                    object = try data.deserializeJSONData(withKeyDecodingStrategy:
                                                            self.configuration.keyDecodingStrategy) as T
                } catch let error {
                    let tnError = TNError.cannotDeserialize(String(describing: T.self), error)
                    self.handleDataTaskCompleted(with: data,
                                                 error: tnError,
                                                 onFailureCallback: { responseHandler(nil, tnError) })
                    return
                }
            }

            self.handleDataTaskCompleted(with: data,
                                         error: error,
                                         onFailureCallback: { responseHandler(object, error) })
        }
    }

    // MARK: - Transformers

    func makeTransformedResponseSuccessHandler<FromType: Decodable,
                                               ToType>(transformer: Transformer<FromType, ToType>.Type,
                                                       responseHandler: @escaping (ToType) -> Void)
                            -> (Data, URLResponse?) -> Void {
        return { data, urlResponse  in
            let object: FromType!

            do {
                object = try data.deserializeJSONData(withKeyDecodingStrategy:
                                                        self.configuration.keyDecodingStrategy) as FromType
            } catch let error {
                let tnError = TNError.cannotDeserialize(String(describing: FromType.self), error)
                self.handleDataTaskCompleted(with: data,
                                             urlResponse: urlResponse,
                                             error: tnError,
                                             onFailureCallback: {
                                                self.failureCompletionHandler?(tnError, data, urlResponse)
                                             })
                return
            }
            // Transformation
            do {
                let object = try object.transform(with: transformer.init())

                self.handleDataTaskCompleted(with: data,
                                             urlResponse: urlResponse,
                                             onSuccessCallback: { responseHandler(object) })

            } catch let error {
                guard let tnError = error as? TNError else {
                    return
                }
                self.handleDataTaskCompleted(with: data,
                                             error: tnError,
                                             onFailureCallback: {
                                                self.failureCompletionHandler?(tnError, data, urlResponse)
                                             })
            }
        }
    }

    func makeTransformedResponseFailureHandler<FromType: Decodable,
                                               ToType>(transformer: Transformer<FromType, ToType>.Type,
                                                       responseHandler: @escaping (ToType?, TNError) -> Void)
                            -> (TNError, Data?, URLResponse?) -> Void {
        return { error, data, urlResponse  in
            guard let data = data else {
                responseHandler(nil, .emptyResponse)
                return
            }

            // Check to see if there is already a deserialization error from success
            if case .cannotDeserialize = error {
                responseHandler(nil, error)
                return
            }

            let object: FromType!

            do {
                object = try data.deserializeJSONData(withKeyDecodingStrategy:
                                                        self.configuration.keyDecodingStrategy) as FromType
            } catch let error {
                let tnError = TNError.cannotDeserialize(String(describing: FromType.self), error)
                self.handleDataTaskCompleted(with: data,
                                             urlResponse: urlResponse,
                                             error: tnError,
                                             onFailureCallback: { responseHandler(nil, tnError) })
                return
            }
            // Transformation
            do {
                let object = try object.transform(with: transformer.init())

                self.handleDataTaskCompleted(with: data,
                                             urlResponse: urlResponse,
                                             onSuccessCallback: { responseHandler(object, error) })

            } catch let error {
                guard let tnError = error as? TNError else {
                    return
                }
                self.handleDataTaskCompleted(with: data,
                                             error: tnError,
                                             onFailureCallback: {
                                                self.failureCompletionHandler?(tnError, data, urlResponse)
                                             })
            }
        }
    }

    // MARK: Image

    func makeImageResponseSuccessHandler(responseHandler: @escaping (ImageType) -> Void)
                            -> ((Data, URLResponse?) -> Void)? {
        return { data, urlResponse  in
            let image = ImageType(data: data)

            if image == nil {
                let tnError = TNError.responseInvalidImageData
                self.handleDataTaskCompleted(with: data,
                                             urlResponse: urlResponse,
                                             error: tnError,
                                             onFailureCallback: {
                                                self.failureCompletionHandler?(tnError, data, urlResponse)
                                             })

            } else {
                self.handleDataTaskCompleted(with: data,
                                             urlResponse: urlResponse,
                                             onSuccessCallback: { responseHandler(image ?? ImageType()) })
            }
        }
    }

    // MARK: String

    func makeStringResponseSuccessHandler(responseHandler: @escaping (String) -> Void)
                            -> ((Data, URLResponse?) -> Void)? {
        return { data, urlResponse  in
            if let string = String(data: data, encoding: .utf8) {

                self.handleDataTaskCompleted(with: data,
                                             urlResponse: urlResponse,
                                             onSuccessCallback: { responseHandler(string) })
            } else {
                let tnError: TNError = .cannotConvertToString
                self.handleDataTaskCompleted(with: data,
                                             urlResponse: urlResponse,
                                             error: tnError,
                                             onFailureCallback: {
                                                self.failureCompletionHandler?(tnError, data, urlResponse)
                                             })
            }
        }
    }

    func makeStringResponseFailureHandler(responseHandler: @escaping (String?, TNError) -> Void)
                            -> (TNError, Data?, URLResponse?) -> Void {
        return { error, data, urlResponse  in
            // Check to see if there is already a deserialization error from success
            if case .cannotDeserialize = error {
                responseHandler(nil, error)
                return
            }

            if let data = data,
               let string = String(data: data, encoding: .utf8) {

                self.handleDataTaskCompleted(with: data,
                                             urlResponse: urlResponse,
                                             onSuccessCallback: { responseHandler(string, error) })
            } else {
                self.handleDataTaskCompleted(with: data,
                                             urlResponse: urlResponse,
                                             error: error,
                                             onFailureCallback: { responseHandler(nil, error) })
            }
        }
    }

    // MARK: Data

    func makeDataResponseSuccessHandler(responseHandler: @escaping (Data) -> Void)
                            -> ((Data, URLResponse?) -> Void)? {
        return { data, urlResponse in
            self.handleDataTaskCompleted(with: data,
                                         urlResponse: urlResponse,
                                         onSuccessCallback: { responseHandler(data) })
        }
    }

    func makeDataResponseFailureHandler(responseHandler: @escaping (Data?, TNError) -> Void)
                            -> (TNError, Data?, URLResponse?) -> Void {
        return { error, data, urlResponse  in
            // Check to see if there is already a deserialization error from success
            if case .cannotDeserialize = error {
                responseHandler(nil, error)
                return
            }

            if let data = data {
                self.handleDataTaskCompleted(with: data,
                                             urlResponse: urlResponse,
                                             onSuccessCallback: { responseHandler(data, error) })
            } else {
                self.handleDataTaskCompleted(with: data,
                                             urlResponse: urlResponse,
                                             error: error,
                                             onFailureCallback: {
                                                responseHandler(nil, error)
                                             })
            }
        }
    }
}
