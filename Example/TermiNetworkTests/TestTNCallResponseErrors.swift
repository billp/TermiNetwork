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
        TNCall.allowEmptyResponseBody = false
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testResponseDataIsEmpty() {
        TNCall.allowEmptyResponseBody = false

        let expectation = XCTestExpectation(description: "Test Empty Response Body")
        var failed = true
       
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
        var failed = true
        
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
        let expectation = XCTestExpectation(description: "Test Empty Response Body")
        var failed = true
        
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
        let expectation = XCTestExpectation(description: "Test Empty Response Body")
        var failed = true
        
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
        let expectation = XCTestExpectation(description: "Test Response Cannot Deserialize")
        var failed = true
        
        try? APIRouter.makeCall(route: APIRouter.testInvalidParams(value1: "a", value2: "b"), responseType: TestParam.self, onSuccess: { data in
            expectation.fulfill()
            failed = true
            
        }, onFailure: { error, data in
            switch error {
            case .cannotDeserialize(_):
                failed = false
            default:
                failed = true
            }
            
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 10)
        
        XCTAssert(!failed)
    }
    
    func testResponseCanDeserialize() {
        let expectation = XCTestExpectation(description: "Test Respons Can Deserialize")
        var failed = true
        
        try? APIRouter.makeCall(route: APIRouter.testGetParams(value1: false, value2: 3, value3: 1.32, value4: "Test", value5: nil), responseType: TestParam.self, onSuccess: { data in
            expectation.fulfill()
            failed = false
            
        }, onFailure: { error, data in
            expectation.fulfill()
            failed = true
        })
        
        wait(for: [expectation], timeout: 10)
        
        XCTAssert(!failed)
    }
    
    func testNetworkError() {
        TNEnvironment.set(Environment.invalidHost)
        
        let expectation = XCTestExpectation(description: "Test Response Cannot Deserialize")
        var failed = true
        
        try? APIRouter.makeCall(route: APIRouter.testInvalidParams(value1: "a", value2: "b"), onSuccess: { data in
            expectation.fulfill()
            failed = true
            
        }, onFailure: { error, data in
            switch error {
            case .networkError(_):
                failed = false
            default:
                failed = true
            }
            
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 10)
        
        XCTAssert(!failed)
    }
    
    func testNotSuccess() {
        let expectation = XCTestExpectation(description: "Test Not Success")
        var failed = true
        
        try! APIRouter.makeCall(route: APIRouter.testStatusCode(code: 404), onSuccess: { data in
            expectation.fulfill()
            failed = true
            
        }, onFailure: { error, data in
            switch error {
            case .notSuccess(let code):
                failed = code != 404
            default:
                failed = true
            }
            
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 10)
        
        XCTAssert(!failed)
    }
    
    func testCancelled() {
        let expectation = XCTestExpectation(description: "Test Not Success")
        var failed = true
        
        let request = TNCall(route: APIRouter.testStatusCode(code: 404))
        try! request.start(onSuccess: { data in
            expectation.fulfill()
        }) { error, data in
            switch error {
            case .cancelled(_):
                failed = false
            default:
                failed = true
            }
            expectation.fulfill()
        }
        
        request.cancel()
        
        wait(for: [expectation], timeout: 10)

        XCTAssert(!failed)

    }
}