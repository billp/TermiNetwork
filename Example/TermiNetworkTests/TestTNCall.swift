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
        var failed = false

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
        var failed = false

        try? APIRouter.makeCall(route: APIRouter.testGetParams(value1: "value1", value2: "value2"), responseType: TestParam.self, onSuccess: { object in
            failed = !(object.param1 == "value1" && object.param2 == "value2")
            expectation.fulfill()
        }) { error, _ in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
        
        XCTAssert(!failed)
    }
}
