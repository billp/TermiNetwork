// CityRoute.swift
//
// Copyright © 2018-2022 Vassilis Panagiotopoulos. All rights reserved.
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
import TermiNetwork

enum CityRoute: RouteProtocol {
    case cities
    case city(id: Int)
    case thumb(city: City)
    case image(city: City)
    case pinning(configuration: Configuration)

    func configure() -> RouteConfiguration {
        switch self {
        case .cities:
            return RouteConfiguration(method: .get,
                                      path: .path(["cities"]),
                                      mockFilePath:
                                            .path(["Cities", "cities.json"]))
        case .city(let id):
            return RouteConfiguration(method: .get,
                                      path: .path(["city", String(id)]),
                                      mockFilePath:
                                            .path(["Cities", "Details", String(format: "%i.json", id)]))
        case .thumb(let city):
            return RouteConfiguration(method: .get,
                                      path: .path([city.thumb ?? ""]),
                                      mockFilePath:
                                            .path(["Cities", "Thumbs", String(format: "%i.jpg", city.cityID)]))
        case .image(let city):
            return RouteConfiguration(method: .get,
                                      path: .path([city.image ?? ""]),
                                      mockFilePath:
                                            .path(["Cities", "Images", String(format: "%i.jpg", city.cityID)]))
        case .pinning(let configuration):
            return RouteConfiguration(
                method: .get,
                path: .path(["cities"]),
                configuration: configuration
            )
        }
    }
}
