//
//  TestTNRequestResponseErrors.swift
//  TermiNetworkTests
//
//  Created by Vasilis Panagiotopoulos on 05/03/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//


import XCTest
import TermiNetwork

class TestTNRequestResponseErrors: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        TNEnvironment.set(Environment.termiNetworkRemote)
        TNRequest.allowEmptyResponseBody = false
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        TNEnvironment.set(Environment.termiNetworkRemote)
    }
    
    func testResponseDataIsEmpty() {
        TNRequest.allowEmptyResponseBody = false

        let expectation = XCTestExpectation(description: "Test Empty Response Body")
        var failed = true
       
        try? TNRouter.start(route: APIRouter.testEmptyBody, onSuccess: { data in
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
        TNRequest.allowEmptyResponseBody = true
        
        let expectation = XCTestExpectation(description: "Test Not Empty Response Body")
        var failed = true
        
        try? TNRouter.start(route: APIRouter.testEmptyBody, onSuccess: { data in
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
        
        try? TNRouter.start(route: APIRouter.testPostParams(value1: false, value2: 1, value3: 2, value4: "", value5: nil), responseType: UIImage.self, onSuccess: { image in
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
        
        try? TNRouter.start(route: APIRouter.testImage(imageName: "sample.jpeg"), responseType: UIImage.self, onSuccess: { image in
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
        
        try? TNRouter.start(route: APIRouter.testInvalidParams(value1: "a", value2: "b"), responseType: TestParam.self, onSuccess: { data in
            failed = true
            expectation.fulfill()
        }, onFailure: { error, data in
            switch error {
            case .cannotDeserialize(_):
                failed = false
            default:
                debugPrint("failed with: " + error.localizedDescription)
                failed = true
            }
            
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 10)
        
        XCTAssert(!failed)
    }
    
    func testResponseCanDeserialize() {
        let expectation = XCTestExpectation(description: "Test Response Can Deserialize")
        var failed = true
        
        try? TNRouter.start(route: APIRouter.testGetParams(value1: false, value2: 3, value3: 1.32, value4: "Test", value5: nil), responseType: TestParam.self, onSuccess: { data in
            failed = false
            expectation.fulfill()
        }, onFailure: { error, data in
            debugPrint("failed with: " + error.localizedDescription)
            failed = true
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 10)
        
        XCTAssert(!failed)
    }
    
    func testNetworkError() {
        TNEnvironment.set(Environment.invalidHost)
        
        let expectation = XCTestExpectation(description: "Test Response Network Error")
        var failed = true
        
        try? TNRouter.start(route: APIRouter.testInvalidParams(value1: "a", value2: "b"), onSuccess: { data in
            failed = true
            expectation.fulfill()
        }, onFailure: { error, data in
            switch error {
            case .networkError(_):
                failed = false
            default:
                debugPrint("failed with: " + error.localizedDescription)
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
        
        try! TNRouter.start(route: APIRouter.testStatusCode(code: 404), onSuccess: { data in
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
        
        let request = TNRequest(route: APIRouter.testStatusCode(code: 404))
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
