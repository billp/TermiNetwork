// Request+Mock.swift
//
// Copyright © 2018-2022 Vassilis Panagiotopoulos. All rights reserved.
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
    internal func shouldMockResponse() -> Bool {
        return self.configuration.mockDataEnabled ?? false
    }

    @discardableResult
    internal func createMockedResponse(request: URLRequest,
                                       completionHandler: ((Data, URLResponse?) -> Void)?,
                                       onFailure: FailureCallbackWithType<Data>? = nil) -> URLSessionDataTask {
        let fakeSession = URLSession(configuration: URLSession.shared.configuration)
                            .dataTask(with: request)

        guard let filePath = mockFilePath?.convertedPath else {
            onFailure?(nil, .invalidMockData(path))
            return fakeSession
        }

        let subdirectory = filePath
            .components(separatedBy: "/")
            .dropLast()
            .joined(separator: "/")

        if  let filenameWithExt = filePath.components(separatedBy: "/").last,
            let filename = filenameWithExt.components(separatedBy: ".").first,
            let url = configuration.mockDataBundle?.url(forResource: filename,
                                                        withExtension: filenameWithExt
                                                            .components(separatedBy: ".").last,
                                                        subdirectory: subdirectory,
                                                        localization: nil),
            let data = try? Data(contentsOf: url) {
            randomizeResponse {
                completionHandler?(data, nil)
            }
        } else {
            randomizeResponse {
                onFailure?(nil, .invalidMockData(filePath))
            }
        }

        return fakeSession
    }

    internal func createDefaultMockResponse() {
        createMockedResponse(request: urlRequest!,
                             completionHandler: successCompletionHandler,
                             onFailure: { [weak self] data, error in
            guard let self = self else { return }
            self.failureCompletionHandler?(error, data, self.urlResponse)
        })
    }

    fileprivate func delay(_ delay: TimeInterval,
                           block: @escaping (() -> Void)) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: block)
    }

    fileprivate func randomizer(between min: TimeInterval,
                                and max: TimeInterval) -> TimeInterval {
        var numberGenerator = SystemRandomNumberGenerator()

        guard max > min else {
            return 0.0
        }

        return Double.random(in: min..<max, using: &numberGenerator)
    }

    fileprivate func randomizeResponse(block: @escaping (() -> Void)) {
        guard let min = configuration.mockDelay?.min,
            let max = configuration.mockDelay?.max else {
                block()
                return
        }

        let mockDelay = randomizer(between: min, and: max)
        self.mockDelay = mockDelay

        delay(mockDelay, block: block)
    }
}
