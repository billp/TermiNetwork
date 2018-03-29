//
//  TestTNCallErrors.swift
//  TermiNetworkTests
//
//  Created by Vasilis Panagiotopoulos on 05/03/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//


import XCTest
import TermiNetwork

class TestTNCallResponseErrors: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        TNEnvironment.set(Environment.termiNetworkLocal)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testResponseDataIsEmpty() {
        TNCall.allowEmptyResponseBody = false

        let expectation = XCTestExpectation(description: "Test Empty Response Body")
        var failed = false
       
        try? APIRouter.makeCall(route: APIRouter.testEmptyBody, onSuccess: { data in
            expectation.fulfill()
            failed = true
        }, onFailure: { error, data in
            expectation.fulfill()
            switch error {
            case .responseDataIsEmpty:
                failed = false
            default:
                failed = true
            }
        })
        
        wait(for: [expectation], timeout: 10)
        
        XCTAssert(!failed)
    }
    
    func testResponseDataIsNotEmpty() {
        TNCall.allowEmptyResponseBody = true
        
        let expectation = XCTestExpectation(description: "Test Not Empty Response Body")
        var failed = false
        
        try? APIRouter.makeCall(route: APIRouter.testEmptyBody, onSuccess: { data in
            expectation.fulfill()
            failed = false
        }, onFailure: { error, data in
            expectation.fulfill()
            failed = true
        })
        
        wait(for: [expectation], timeout: 10)
        
        XCTAssert(!failed)
    }
    
    func testResponseInvalidImageData() {
        TNCall.allowEmptyResponseBody = true
        
        let expectation = XCTestExpectation(description: "Test Empty Response Body")
        var failed = false
        
        try? APIRouter.makeCall(route: APIRouter.testPostParams, responseType: UIImage.self, onSuccess: { image in
            expectation.fulfill()
            failed = true
        }, onFailure: { error, data in
            expectation.fulfill()
            switch error {
            case .responseInvalidImageData:
                failed = false
            default:
                failed = true
            }
        })
        
        wait(for: [expectation], timeout: 10)
        
        XCTAssert(!failed)
    }
    
    func testResponseValidImageData() {
        TNCall.allowEmptyResponseBody = true
        
        let expectation = XCTestExpectation(description: "Test Empty Response Body")
        var failed = false
        
        try? APIRouter.makeCall(route: APIRouter.testImage(imageName: "sample.jpeg"), responseType: UIImage.self, onSuccess: { image in
            expectation.fulfill()
            failed = false
        }, onFailure: { error, data in
            expectation.fulfill()
            failed = true
        })
        
        wait(for: [expectation], timeout: 10)
        
        XCTAssert(!failed)
    }
    
    func testResponseCannotDeserialize() {
        
    }
    
    func testResponseCanDeserialize() {
        
    }
    
    func testNetworkError() {
        
    }
    
    func testNotSuccess() {
        
    }
    
    func testCancelled() {
        
    }
}
