// Reachability.swift
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

import Foundation

#if !os(watchOS)

import SystemConfiguration

/// Reachability State Type
public enum ReachabilityState {
    /// WIFI state.
    case wifi
    /// Cellular state.
    case cellular
    /// Unavailable state.
    case unavailable
}

/// Type for reachability monitoring updates
/// - Parameters:
///     - status: The new network state.
public typealias ReachabilityUpdateClosureType = (_ status: ReachabilityState) -> Void

/// Adds Reachability supportt
open class Reachability {
    // MARK: Static properties

    static let reachabilityQueue = DispatchQueue.init(label: "Reachability")

    // MARK: Properties

    private var reachability: SCNetworkReachability?
    private var monitoringStarted: Bool = false
    private var reachabilityFlags: SCNetworkReachabilityFlags?
    private var monitorUpdatesCallback: ReachabilityUpdateClosureType?
    private var hostname: String?

    // MARK: Initializers

    /// Reachability initializer.
    /// - Parameters:
    ///     - hostname: The name of the desired host.
    public init(hostname: String? = nil) {
        self.hostname = hostname
    }

    // MARK: Internal methods

    /// Starts monitoring network state updates.
    /// - Parameters:
    ///     - hostname: The name of the desired host.
    ///     - closure: Type for reachability monitoring updates
    func monitorState(hostname: String, _ closure: ReachabilityUpdateClosureType?) throws {
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, hostname) else {
            throw TNError.reachabilityError
        }
        self.reachability = reachability
        self.monitorUpdatesCallback = closure
        try startMonitoring()
    }

    func updateFlags(_ flags: SCNetworkReachabilityFlags?) {
        if let reachabilityFlags = flags,
                reachabilityFlags != self.reachabilityFlags,
                monitoringStarted {
            self.reachabilityFlags = flags
            var state: ReachabilityState = .unavailable

            #if os(macOS)
                if reachabilityFlags.contains(.reachable) {
                    state = .wifi
                }
            #else
                if reachabilityFlags.contains(.isWWAN) {
                    state = .cellular
                } else if reachabilityFlags.contains(.reachable) && !reachabilityFlags.contains(.isWWAN) {
                    state = .wifi
                }
            #endif
            monitorUpdatesCallback?(state)
        }
    }

    /// Starts monitoring network state updates.
    func startMonitoring() throws {
        guard let reachability = reachability, !monitoringStarted else {
            return
        }
        var context = SCNetworkReachabilityContext(version: 0,
                                                   info: nil,
                                                   retain: nil,
                                                   release: nil,
                                                   copyDescription: nil)

        context.info = Unmanaged<Reachability>
                        .passRetained(self)
                        .toOpaque()

        let callback: SCNetworkReachabilityCallBack = { (reachability, flags, info) in
            guard let info = info else { return }

            Unmanaged<Reachability>.fromOpaque(info)
                                    .takeUnretainedValue()
                                    .updateFlags(flags)
        }

        guard SCNetworkReachabilitySetCallback(reachability, callback, &context),
              SCNetworkReachabilitySetDispatchQueue(reachability, Reachability.reachabilityQueue)
              else {
            stopMonitoring()
            throw TNError.reachabilityError
        }

        Reachability.reachabilityQueue.async {
            var flags = SCNetworkReachabilityFlags()
            let success = withUnsafeMutablePointer(to: &flags) {
                SCNetworkReachabilityGetFlags(reachability, UnsafeMutablePointer($0))
            }

            self.updateFlags(success ? flags : nil)
        }

        monitoringStarted = true
    }

    // MARK: Public methods

    /// Starts monitoring network state updates.
    /// - Parameters:
    ///     - closure: Type for reachability monitoring updates
    public func monitorState(_ closure: ReachabilityUpdateClosureType?) throws {
        // If hostname is given, call the correct one
        if let hostname = hostname {
            try monitorState(hostname: hostname, closure)
            return
        }

        // no hostname given, so initialize with sockaddr_in
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)

        guard let reachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            throw TNError.reachabilityError
        }

        self.reachability = reachability
        self.monitorUpdatesCallback = closure
        try startMonitoring()
    }

    /// Stops monitoring network state updates.
    open func stopMonitoring() {
        defer {
            monitoringStarted = false
        }
        guard let reachability = reachability else {
            return
        }

        SCNetworkReachabilitySetCallback(reachability, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(reachability, nil)
        self.reachability = nil
    }

    /// Starts monitoring network state updates.
    /// - Parameters:
    ///     - flags: Returns a boolean indicating if the given flags are contained
    ///     to the previous received flags.
    open func containsFlags(_ flags: [SCNetworkReachabilityFlags]) -> Bool {
        guard let lastFlags = self.reachabilityFlags else {
            return false
        }

        return flags.allSatisfy { flag in
            lastFlags.contains(flag)
        }
    }
}

#endif
