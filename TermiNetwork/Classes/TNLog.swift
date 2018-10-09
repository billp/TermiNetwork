//
//  TNLog.swift
//  TermiNetwork
//
//  Created by Vasilis Panagiotopoulos on 22/02/2018.
//  Copyright © 2018 Vasilis Panagiotopoulos. All rights reserved.
//

import Foundation

internal class TNLog {
     static func logRequest(request: TNRequest) {
        guard TNEnvironment.verbose else { return }
        
        let url = request.cachedRequest?.url?.absoluteString ?? "n/a"
        let headers = request.cachedRequest?.allHTTPHeaderFields
        
        print("--------------------------------")
        print("🌎 URL: " + url)
        print("🎛️ Method: " + request.method.rawValue.uppercased())
        print("🔮 CURL Command: " + request.cachedRequest.curlString)
        if let headers = headers, headers.keys.count > 0 {
            print("📃 Request Headers: " + headers.description)
        }
        if let params = request.params as [String: AnyObject]?, params.keys.count > 0 {
            if request.method != .get {
                if request.requestBodyType == .JSON {
                    print("🗃️ Request Body: " + (params.toJSONString() ?? "[unknown]"))
                } else {
                    print("🗃️ Request Body: " + params.description)
                }
            }
        }

        if let customError = request.customError {
            print("❌ Error: " + customError.description)
        } else if let response = request.urlResponse as? HTTPURLResponse {
            print("✅ Status: " + String(response.statusCode))
        }
        
        if let data = request.data {
            if let responseJSON = data.toJSONString() {
                print("📦 Response: " + responseJSON)
            } else if let stringResponse = String(data: data, encoding: .utf8) {
                print("📦 Response: " + (stringResponse.isEmpty ? "[empty-response]" : stringResponse))
            } else {
                print("📦 Response: [not-printable]")
            }
        }
    }
}
