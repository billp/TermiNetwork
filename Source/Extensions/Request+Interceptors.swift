// Request+Interceptors.swift
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

typealias InterceptorContinueCallbackType = (Data?, TNError?, (() -> Void)?, (() -> Void)?) -> Void

extension Request {
    /// Handles the interceptors if they are passed in configuration object.
    /// - parameters:
    ///     - data: The response data.
    ///     - error: The TNError in case of failure.
    func processNextInterceptorIfNeeded(data: Data?,
                                        error: TNError?,
                                        onSuccess: (() -> Void)? = nil,
                                        onFailure: (() -> Void)? = nil,
                                        continueCallback: @escaping InterceptorContinueCallbackType) {
        if let nextInterceptor = interceptors?.first {
            nextInterceptor.requestFinished(responseData: data,
                                            error: error,
                                            request: self) { action in
                switch action {
                case .continue:
                    interceptors?.removeFirst()
                    if let data = data {
                        /// Call success completion handler directly
                        self.successCompletionHandler?(data, urlResponse)
                    } else {
                        continueCallback(data, error, onSuccess, onFailure)
                    }
                case .retry(let delay):
                    retryRequest(withDelay: delay ?? 0,
                                 continueCallback: continueCallback)
                }
            }
        } else {
            continueCallback(data, error, onSuccess, onFailure)
        }
    }

    func initializeInterceptorsIfNeeded() {
        guard let interceptors = configuration.interceptors,
              self.interceptors == nil,
              !configuration.skipInterceptors else {
            return
        }
        self.interceptors = interceptors.map { $0.init() }
    }

    // MARK: Helpers

    func retryRequest(withDelay delay: TimeInterval,
                      continueCallback: @escaping InterceptorContinueCallbackType) {
        guard let newRequest = self.copy() as? Request else {
            return
        }
        retryCount += 1

        // Skip interceptors for cloned request, to prevent infinite loop.
        newRequest.configuration.skipInterceptors = true
        newRequest.configuration.verbose = false

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            newRequest.start(responseType: Data.self, onSuccess: { data in
                self.processNextInterceptorIfNeeded(data: data,
                                                    error: nil,
                                                    continueCallback: continueCallback)
            }, onFailure: { error, data in
                self.processNextInterceptorIfNeeded(data: data,
                                                    error: error,
                                                    continueCallback: continueCallback)
            })
        }
    }
}
