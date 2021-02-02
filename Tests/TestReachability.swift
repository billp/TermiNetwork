// TestReachability.swift
//
// Copyright © 2018-2021 Vasilis Panagiotopoulos. All rights reserved.
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

class TestReachability: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Environment.set(Env.termiNetworkRemote)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testReachabilityConnectedToWIFI() {
        let expectation = XCTestExpectation(description: "testReachabilityConnectedToWIFI")
        var failed = true

        let reachability = Reachability()
        try? reachability.monitorState { state in
            print(state)
            if case .wifi = state {
                failed = false
            }
            reachability.stopMonitoring()
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 60)

        XCTAssertFalse(failed)
    }

    func testReachabilityFlagsWIFI() {
        let expectation = XCTestExpectation(description: "testReachabilityConnectedToWIFI")
        var failed = true

        let reachability = Reachability()
        try? reachability.monitorState { _ in
            failed = !(reachability.containsFlags([.reachable]) && !reachability.containsFlags([.isWWAN]))
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 60)

        XCTAssertFalse(failed)
    }

    func testReachabilityStopMonitoringFlagsWIFI() {
        let expectation = XCTestExpectation(description: "testReachabilityStopMonitoringFlagsWIFI")
        var failed = true

        let reachability = Reachability()
        try? reachability.monitorState { _ in
            failed = !(reachability.containsFlags([.reachable]) && !reachability.containsFlags([.isWWAN]))
            expectation.fulfill()
        }

        reachability.stopMonitoring()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 60)

        XCTAssertTrue(failed)
    }

    func testReachabilityWithHostConnectedToWIFI() {
        let expectation = XCTestExpectation(description: "testReachabilityWithHostConnectedToWIFI")
        var failed = true

        let reachability = Reachability(hostname: "google.com")
        try? reachability.monitorState { state in
            print(state)
            if case .wifi = state {
                failed = false
            }
            reachability.stopMonitoring()
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 60)

        XCTAssertFalse(failed)
    }

    func testReachabilityWithHostUnavailable() {
        let expectation = XCTestExpectation(description: "testReachabilityWithHostUnavailable")
        var failed = true

        let reachability = Reachability(hostname: "fdsfdsagdsafdsacdasfdsafdsafdsa")
        try? reachability.monitorState { state in
            print(state)
            if case .unavailable = state {
                failed = false
                reachability.stopMonitoring()
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 60)

        XCTAssertFalse(failed)
    }

    func testReachabilityWithHostFlagsWIFI() {
        let expectation = XCTestExpectation(description: "testReachabilityWithHostFlagsWIFI")
        var failed = true

        let reachability = Reachability(hostname: "127.0.0.1")
        try? reachability.monitorState { _ in
            failed = !(reachability.containsFlags([.reachable]) && !reachability.containsFlags([.isWWAN]))
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 60)

        XCTAssertFalse(failed)
    }
}
