// CertificatePinningView.swift
//
// Copyright © 2018-2023 Vassilis Panagiotopoulos. All rights reserved.
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

struct CertificatePinningView: View {
    @State var isCertificateValid: Bool = true
    @State var responseString: String = "Press Start Request..."

    init() {
        UITextView.appearance().backgroundColor = .clear
    }

    var body: some View {
        VStack {
            TextEditor(text: $responseString)
                .padding(4)
                .background(Color(.sRGB, red: 0.922, green: 0.922, blue: 0.922, opacity: 1.0))
                .cornerRadius(5)
                .font(.footnote)
                .clipped()

            Toggle("Valid Certificate", isOn: $isCertificateValid)
                .font(.footnote)
                .padding(.top, 10)
                .padding(.bottom, 50)
            Spacer()
            UIHelpers.button("Start Request", action: startRequest)
                .padding(.bottom, 20)
        }
        .padding([.leading, .trailing, .top], 20)
        .navigationTitle("Certificate Pinning")
    }

    func startRequest() {
        let certificateName = isCertificateValid ? "terminetwork.billp.dev" : "forums.swift.org"

        let configuration = Configuration()
        guard let certUrlPath = Bundle.main.path(forResource: certificateName, ofType: "cer") else {
            return
        }
        configuration.certificatePaths = [certUrlPath]

        responseString = "fetching..."

        Client<CitiesRepository>()
            .request(for: .pinning(configuration: configuration))
            .success(responseType: Data.self) { response in
                responseString = response.toJSONString() ?? ""
            }
            .failure { error in
                responseString = error.localizedDescription ?? ""
            }
    }
}
