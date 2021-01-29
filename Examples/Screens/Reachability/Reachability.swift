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
import SwiftUI
import TermiNetwork

struct Reachability: View {
    var reachability: TermiNetwork.Reachability? = TermiNetwork.Reachability(hostname: "google.com")
    
    @State var state: String = ""

    var body: some View {
        VStack {
            HStack {
                Text("Network state:")
                Text(state)
            }
        }
        .padding([.leading, .trailing, .top], 20)
        .navigationTitle("Reachability")
        .onAppear(perform: startMonitoringState)
        .onDisappear(perform: stopMonitoringState)
    }

    func startMonitoringState() {
        try? reachability?.monitorState { state in
            self.state = String(describing: state)
        }
    }

    func stopMonitoringState() {
        reachability?.stopMonitoring()
    }
}
