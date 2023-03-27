// GlobalInterceptor.swift
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
import TermiNetwork

final class UnauthorizedInterceptor: InterceptorProtocol {
    let retryDelay: TimeInterval = 0.1
    let retryLimit = 5

    static var currentStatusCode = 401
    static let authorizationValue = "abcdef123"

    func requestFinished(responseData data: Data?,
                         error: TNError?,
                         request: Request,
                         proceed: @escaping (InterceptionAction) -> Void) {
        switch error {
        case .notSuccess(let statusCode, _):
            if statusCode == 401, request.retryCount < retryLimit {
                // Login to get a new token.
                UnauthorizedInterceptor.currentStatusCode = 200

                // Update global header in configuration which is inherited by all requests.
                Environment.current.configuration?.headers?["Authorization"] =
                    UnauthorizedInterceptor.authorizationValue

                // Update current request's header.
                request.headers?["Authorization"] = UnauthorizedInterceptor.authorizationValue
                request.params?["status_code"] = UnauthorizedInterceptor.currentStatusCode
                // Retry the original request.
                proceed(.retry(delay: retryDelay))
            }
        default:
            proceed(.continue)
        }
    }
}
