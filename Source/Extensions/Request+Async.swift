// Request+ResponseTypes.swift
//
// Copyright © 2018-2022 Vasilis Panagiotopoulos. All rights reserved.
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

@MainActor
public extension Request {
    /// Executes an asynchronous request and returns the inferred decodable type.
    ///
    /// - Parameters:
    ///    - as: The decodable type that will be deserialized.
    /// - returns: The inferred decodable type.
    /// - throws: A TNError in case of failure.
    @discardableResult
    func async<T: Decodable>(as type: T.Type) async throws -> T {
        try await withCheckedThrowingContinuation { configuration in
            success(responseType: T.self) { response in
                configuration.resume(returning: response)
            }
            .failure { error in
                configuration.resume(throwing: error)
            }
        }
    }

    /// Executes an asynchronous request and returns the inferred decodable type.
    ///
    /// - returns: The inferred decodable type.
    /// - throws: A TNError in case of failure.
    @discardableResult
    func async<T: Decodable>() async throws -> T {
        try await async(as: T.self)
    }

    /// Executes an asynchronous request and returns the data as String.
    ///
    /// - Parameters:
    ///    - as: The String type (String.self).
    /// - returns: The response data as string.
    /// - throws: A TNError in case of failure.
    @discardableResult
    func async(as type: String.Type) async throws -> String {
        try await withCheckedThrowingContinuation { configuration in
            success(responseType: type.self) { response in
                configuration.resume(returning: response)
            }
            .failure { error in
                configuration.resume(throwing: error)
            }
        }
    }

    /// Executes an asynchronous request and returns the data as Data.
    ///
    /// - Parameters:
    ///    - as: The Data type (Data.self).
    /// - returns: The response data as string.
    /// - throws: A TNError in case of failure.
    @discardableResult
    func async(as type: Data.Type) async throws -> Data {
        try await withCheckedThrowingContinuation { configuration in
            success(responseType: type.self) { response in
                configuration.resume(returning: response)
            }
            .failure { error in
                configuration.resume(throwing: error)
            }
        }
    }

    /// Executes an asynchronous request and returns the data as Image.
    ///
    /// - Parameters:
    ///    - as: The Image type (UImage.self/NSImage.self).
    /// - returns: The response data as string.
    /// - throws: A TNError in case of failure.
    @discardableResult
    func async(as type: ImageType.Type) async throws -> ImageType {
        try await withCheckedThrowingContinuation { configuration in
            success(responseType: ImageType.self) { response in
                configuration.resume(returning: response)
            }
            .failure { error in
                configuration.resume(throwing: error)
            }
        }
    }

    /// Executes an asynchronous request and returns the decodable type based on transformer.
    ///
    /// - Parameters:
    ///    - using: The transformer type.
    /// - returns: The response data as string.
    /// - throws: A TNError in case of failure.
    @discardableResult
    func async<From: Decodable, To>(using transformer: Transformer<From, To>.Type) async throws -> To {
        try await withCheckedThrowingContinuation { configuration in
            success(transformer: transformer) { response in
                configuration.resume(returning: response)
            }
            .failure { error in
                configuration.resume(throwing: error)
            }
        }
    }
}
