//
//  TestTNRequestErrors.swift
//  TermiNetworkTests
//
//  Created by Vasilis Panagiotopoulos on 05/03/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//


import XCTest
import TermiNetwork

class TestTNRequestErrors: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        TNEnvironment.set(Environment.termiNetworkRemote)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEnvironmentNotSet() {
        TNEnvironment.current = nil
        
        TNRequest(method: .get,
                  url: "http://www.google.com",
                  headers: nil,
                  params: nil).start(responseType: UIImage.self, onSuccess: { data in
            XCTAssert(false)
        }) { error, data in
            if case TNError.environmentNotSet = error {
                XCTAssert(true)
            } else {
                XCTAssert(false)
            }
        }
    }
    
    func testInvalidURL() {
        do {
            try _ = TNRequest(method: .get, url: "http://εεε.google.κωμ", headers: nil, params: nil).asRequest()
            XCTAssert(false)
        } catch TNError.invalidURL {
            XCTAssert(true)
        } catch {
            XCTAssert(false)
        }
    }
    
    func testValidURL() {
        do {
            try _ = TNRequest(method: .get, url: "http://www.google.com", headers: nil, params: nil).asRequest()
            XCTAssert(true)
        } catch {
            XCTAssert(false)
        }
    }
}
