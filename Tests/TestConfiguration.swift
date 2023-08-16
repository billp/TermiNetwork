// TestConfiguration.swift
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

import XCTest
import TermiNetwork

// swiftlint:disable compiler_protocol_init

class TestConfiguration: XCTestCase {

    static var bundle: Bundle = {
        return Bundle(for: TestPinning.self)
    }()

    static var certPath: String {
        return bundle.path(forResource: "forums.swift.org",
                           ofType: "cer",
                           inDirectory: nil,
                           forLocalization: nil) ?? ""
    }

    static var envConfiguration: Configuration = {
        let conf = Configuration()
        conf.verbose = true
        conf.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        conf.timeoutInterval = 111
        conf.requestBodyType = .JSON
        conf.certificatePaths = [certPath]
        conf.headers = ["test": "123", "test2": "abcdefg"]
        conf.keyDecodingStrategy = .convertFromSnakeCase
        conf.interceptors = [GlobalInterceptor.self]
        conf.requestMiddleware = []

        return conf
    }()

    static var repositoryConfiguration: Configuration = {
        let conf = Configuration()
        conf.verbose = false
        conf.cachePolicy = .returnCacheDataDontLoad
        conf.timeoutInterval = 231
        conf.requestBodyType = .xWWWFormURLEncoded
        conf.certificatePaths = ["test"]
        conf.headers = ["test": "test", "afb": "fff"]
        conf.keyDecodingStrategy = .useDefaultKeys
        conf.interceptors = []
        conf.requestMiddleware = [CryptoMiddleware.self]

        return conf
    }()

    enum Env: EnvironmentProtocol {
        case test

        func configure() -> Environment {
            switch self {
            case .test:
                return Environment(scheme: .http,
                                     host: "google.com",
                                     configuration: TestConfiguration.envConfiguration)
            }
        }
    }

    lazy var client: Client<TestRepository> = .init()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Environment.set(Env.test)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testEnvConfiguration() {
        let request = client.request(for: .testHeaders)
        let reqConf = request.configuration

        XCTAssert(reqConf.verbose == TestConfiguration.envConfiguration.verbose)
        XCTAssert(reqConf.cachePolicy == TestConfiguration.envConfiguration.cachePolicy)
        XCTAssert(reqConf.timeoutInterval == TestConfiguration.envConfiguration.timeoutInterval)
        XCTAssert(reqConf.requestBodyType == TestConfiguration.envConfiguration.requestBodyType)
        XCTAssert(reqConf.certificatePaths == TestConfiguration.envConfiguration.certificatePaths)
        XCTAssert(reqConf.verbose == TestConfiguration.envConfiguration.verbose)
        XCTAssert(reqConf.headers == TestConfiguration.envConfiguration.headers)
        if case .convertFromSnakeCase = reqConf.keyDecodingStrategy {
            XCTAssert(true)
        } else {
            XCTAssert(false)
        }
        XCTAssert(Set(arrayLiteral: reqConf.interceptors.map { String(describing: $0) }) ==
                    Set(arrayLiteral: TestConfiguration
                            .envConfiguration
                            .interceptors.map { String(describing: $0) }))
        XCTAssert(Set(arrayLiteral: reqConf.requestMiddleware.map { String(describing: $0) }) ==
                    Set(arrayLiteral: TestConfiguration
                            .envConfiguration
                            .requestMiddleware.map { String(describing: $0) }))
    }

    func testEnvConfigurationWithEnvironmentObject() {
        Environment.set(environmentObject: Environment(url: "http://www.google.com/abc/def",
                                                           configuration: TestConfiguration.envConfiguration))

        let request = client.request(for: .testHeaders)
        let reqConf = request.configuration

        XCTAssert(reqConf.verbose == TestConfiguration.envConfiguration.verbose)
        XCTAssert(reqConf.cachePolicy == TestConfiguration.envConfiguration.cachePolicy)
        XCTAssert(reqConf.timeoutInterval == TestConfiguration.envConfiguration.timeoutInterval)
        XCTAssert(reqConf.requestBodyType == TestConfiguration.envConfiguration.requestBodyType)
        XCTAssert(reqConf.certificatePaths == TestConfiguration.envConfiguration.certificatePaths)
        XCTAssert(reqConf.verbose == TestConfiguration.envConfiguration.verbose)
        XCTAssert(reqConf.headers == TestConfiguration.envConfiguration.headers)
        if case .convertFromSnakeCase = reqConf.keyDecodingStrategy {
            XCTAssert(true)
        } else {
            XCTAssert(false)
        }
        XCTAssert(Set(arrayLiteral: reqConf.interceptors.map { String(describing: $0) }) ==
                    Set(arrayLiteral: TestConfiguration
                            .envConfiguration
                            .interceptors.map { String(describing: $0) }))
        XCTAssert(Set(arrayLiteral: reqConf.requestMiddleware.map { String(describing: $0) }) ==
                    Set(arrayLiteral: TestConfiguration
                            .envConfiguration
                            .requestMiddleware.map { String(describing: $0) }))
    }

    func testEndpointConfiguration() {
        let request = client.request(for:
            .testConfigurationParameterized(conf: TestConfiguration.repositoryConfiguration))
        let reqConf = request.configuration
        let endpointConf = TestConfiguration.repositoryConfiguration

        var allHeaders = TestConfiguration.envConfiguration.headers ?? [:]
        let endpointHeaders = endpointConf.headers ?? [:]

        allHeaders.merge(endpointHeaders, uniquingKeysWith: { _, new in new})

        XCTAssert(reqConf.verbose == endpointConf.verbose)
        XCTAssert(reqConf.cachePolicy == endpointConf.cachePolicy)
        XCTAssert(reqConf.timeoutInterval == endpointConf.timeoutInterval)
        XCTAssert(reqConf.requestBodyType == endpointConf.requestBodyType)
        XCTAssert(reqConf.certificatePaths == endpointConf.certificatePaths)
        XCTAssert(reqConf.verbose == endpointConf.verbose)
        XCTAssert(reqConf.headers == allHeaders)
        if case .useDefaultKeys = reqConf.keyDecodingStrategy {
            XCTAssert(true)
        } else {
            XCTAssert(false)
        }
        XCTAssert(Set(arrayLiteral: reqConf.interceptors.map { String(describing: $0) }) ==
                    Set(arrayLiteral: endpointConf.interceptors.map { String(describing: $0) }))
        XCTAssert(Set(arrayLiteral: reqConf.requestMiddleware.map { String(describing: $0) }) ==
                    Set(arrayLiteral: endpointConf.requestMiddleware.map { String(describing: $0) }))
    }
}

// swiftlint:enable compiler_protocol_init
