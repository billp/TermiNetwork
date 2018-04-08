//
//  TestTNCall.swift
//  TermiNetworkTests
//
//  Created by Vasilis Panagiotopoulos on 05/03/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
import TermiNetwork

class TestTNCall: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        TNEnvironment.set(Environment.termiNetworkLocal)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testHeaders() {
        let expectation = XCTestExpectation(description: "Test headers")
        var failed = true

        try? APIRouter.makeCall(route: APIRouter.testHeaders, responseType: TestHeaders.self, onSuccess: { object in
            failed = !(object.authorization == "XKJajkBXAUIbakbxjkasbxjkas" && object.customHeader == "test!!!!")
            expectation.fulfill()
        }) { error, _ in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
        
        XCTAssert(!failed)
    }
    
    func testGetParams() {
        let expectation = XCTestExpectation(description: "Test get params")
        var failed = true

        try? APIRouter.makeCall(route: APIRouter.testGetParams(value1: true, value2: 3, value3: 5.13453124189, value4: "test", value5: nil), responseType: TestParam.self, onSuccess: { object in
            failed = !(object.param1 == "true" && object.param2 == "3" && object.param3 == "5.13453124189" && object.param4 == "test" && object.param5 == nil)
            failed = false
            expectation.fulfill()
        }) { error, _ in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
        
        XCTAssert(!failed)
    }
}