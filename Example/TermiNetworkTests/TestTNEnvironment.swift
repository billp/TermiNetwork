//
//  TermiNetworkTests.swift
//  TermiNetworkTests
//
//  Created by Vasilis Panagiotopoulos on 27/02/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
import TermiNetwork

enum Environment: TNEnvironmentProtocol {
    case httpHost
    case httpHostWithPort
    case httpHostWithPortAndSuffix
    case httpsHostWithPortAndSuffix

    func configure() -> TNEnvironment {
        switch self {
        case .httpHost:
            return TNEnvironment(scheme: .http, host: "localhost")
        case .httpHostWithPort:
            return TNEnvironment(scheme: .http, host: "localhost", suffix: nil, port: 8080)
        case .httpHostWithPortAndSuffix:
            return TNEnvironment(scheme: .http, host: "localhost", suffix: path("v1", "json"), port: 8080)
        case .httpsHostWithPortAndSuffix:
            return TNEnvironment(scheme: .https, host: "google.com", suffix: path("v1", "json"), port: 8080)

        }
    }
}

class TestTNEnvironment: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEnvironments() {
        TNEnvironment.set(Environment.httpHost)
        XCTAssert(TNEnvironment.current.description == "http://localhost")
        
        TNEnvironment.set(Environment.httpHostWithPort)
        debugPrint(TNEnvironment.current)
        XCTAssert(TNEnvironment.current.description == "http://localhost:8080")

        TNEnvironment.set(Environment.httpHostWithPortAndSuffix)
        XCTAssert(TNEnvironment.current.description == "http://localhost:8080/v1/json")

        TNEnvironment.set(Environment.httpsHostWithPortAndSuffix)
        XCTAssert(TNEnvironment.current.description == "https://google.com:8080/v1/json")
    }
}
