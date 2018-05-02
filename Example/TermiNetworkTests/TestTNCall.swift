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
        TNEnvironment.set(Environment.termiNetworkRemote)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()

        TNCall.requestBodyType = .xWWWFormURLEncoded
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
    
    func testPostParams() {
        let expectation = XCTestExpectation(description: "Test post params")
        var failed = true
        
        try? APIRouter.makeCall(route: APIRouter.testPostParams(value1: true, value2: 3, value3: 5.13453124189, value4: "test", value5: nil), responseType: TestParam.self, onSuccess: { object in
            failed = !(object.param1 == "true" && object.param2 == "3" && object.param3 == "5.13453124189" && object.param4 == "test" && object.param5 == nil)
            expectation.fulfill()
        }) { error, _ in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
        
        XCTAssert(!failed)
    }
    
    func testJSONRequestPostParams() {
        let expectation = XCTestExpectation(description: "Test JSON post params")
        var failed = true
        
        TNCall.requestBodyType = .JSON
        
        try? APIRouter.makeCall(route: APIRouter.testPostParams(value1: true, value2: 3, value3: 5.13453124189, value4: "test", value5: nil), responseType: TestJSONParams.self, onSuccess: { object in
            failed = !(object.param1 == true && object.param2 == 3 && object.param3 == 5.13453124189 && object.param4 == "test" && object.param5 == nil)
            expectation.fulfill()
        }) { error, _ in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
        
        XCTAssert(!failed)
    }
    
    func testBeforeAllRequests() {
        let expectation = XCTestExpectation(description: "Test beforeEachRequestCallback")
        self.sampleRequest()

        TNCall.afterAllRequestsBlock = {
            TNCall.beforeAllRequestsBlock = {
                expectation.fulfill()
            }
            
            self.sampleRequest()
            self.sampleRequest()
            self.sampleRequest()
        }
        
        

        wait(for: [expectation], timeout: 10)

        XCTAssert(true)
    }
    
    func testBeforeAllRequestsSkipHooks() {
        let expectation = XCTestExpectation(description: "Test beforeEachRequestCallback skip hooks")
        var failed = false
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.sampleRequest()

            TNCall.afterAllRequestsBlock = {
                TNCall.beforeAllRequestsBlock = {
                    failed = true
                }
                
                self.sampleRequest(skipBeforeAfterAllRequestsHooks: true, successCallback: {
                    expectation.fulfill()
                })
            }
        }
        
        
        wait(for: [expectation], timeout: 10)
        
        XCTAssert(!failed)
    }
    
    func testAfterAllRequestsSkipHooks() {
        let expectation = XCTestExpectation(description: "Test beforeEachRequestCallback skip hooks")
        var failed = false
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.sampleRequest()
            
            TNCall.afterAllRequestsBlock = {
                TNCall.afterAllRequestsBlock = {
                    failed = true
                }
                
                self.sampleRequest(skipBeforeAfterAllRequestsHooks: true, successCallback: {
                    expectation.fulfill()
                })
            }
        }
        
        
        wait(for: [expectation], timeout: 10)
        
        XCTAssert(!failed)
    }
    
    func testAfterAllRequests() {
        let expectation = XCTestExpectation(description: "Test beforeEachRequestCallback")
        
        TNCall.afterAllRequestsBlock = {
            expectation.fulfill()
        }
        
        sampleRequest()
        sampleRequest()
        sampleRequest()
        
        wait(for: [expectation], timeout: 10)
        
        XCTAssert(true)
    }
    
    func testBeforeEachRequest() {
        let expectation = XCTestExpectation(description: "Test beforeEachRequestCallback")
        var failed = true
        
        TNCall.beforeEachRequestBlock = { _ in
            expectation.fulfill()
            failed = false
        }
        
        sampleRequest()
        
        wait(for: [expectation], timeout: 10)
        XCTAssert(!failed)
    }
    
    func testAfterEachRequest() {
        let expectation = XCTestExpectation(description: "Test afterEachRequestCallback")
        var failed = true
        
        TNCall.afterEachRequestBlock = { call, data, URLResponse, error in
            failed = false
            expectation.fulfill()
        }
        
        sampleRequest()
        
        wait(for: [expectation], timeout: 10)
        XCTAssert(!failed)
    }
    
    
    func sampleRequest(skipBeforeAfterAllRequestsHooks: Bool = false, successCallback: (()->())? = nil) {
        
        TNCall.requestBodyType = .JSON
        
        try? APIRouter.makeCall(route: APIRouter.testPostParams(value1: true, value2: 3, value3: 5.13453124189, value4: "test", value5: nil), skipBeforeAfterAllRequestsHooks: skipBeforeAfterAllRequestsHooks, responseType: TestJSONParams.self, onSuccess: { object in
            successCallback?()
        }) { error, _ in
        }
    }
}
