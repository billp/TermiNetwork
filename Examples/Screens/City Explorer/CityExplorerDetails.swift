// CityExplorerDetails.swift
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
import SwiftUI
import TermiNetwork

struct CityExplorerDetails: View {

    @StateObject var viewModel: ViewModel

    init(viewModel: ViewModel) {
        Environment.current.configuration?.mockDataEnabled = viewModel.usesMockData
        self._viewModel = .init(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .multilineTextAlignment(.center)
                    .accentColor(.red)
                    .font(.caption)
                    .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30))
            } else if !viewModel.cityFetched {
                ProgressView()
            } else {
                CityDetailsEntry(city: viewModel.city,
                                 imageHeight: 300)
            }
        }
        .navigationTitle(viewModel.city.name)
        .onAppear(perform: viewModel.onAppear)
        .onDisappear(perform: viewModel.onDisappear)
    }
}

extension CityExplorerDetails {
    class ViewModel: ObservableObject {
        var fetchCityDetailsTask: Task<(), Never>?
        @Published var city: City
        var cityFetched: Bool = false
        var errorMessage: String?
        var usesMockData: Bool

        init(city: City, usesMockData: Bool) {
            self.city = city
            self.usesMockData = usesMockData
        }

        func onAppear() {
            guard fetchCityDetailsTask == nil else {
                return
            }
            fetchCityDetailsTask = Task {
                await loadCity()
            }
        }

        func onDisappear() {
            fetchCityDetailsTask?.cancel()
        }

        @MainActor func loadCity() async {
            let request = Router<CityRoute>().request(for: .city(id: city.cityID))

            do {
                city = try await request.asyncUpload(using: CityTransformer.self)
                self.cityFetched = true
            } catch let error as TNError {
                switch error {
                case .cancelled:
                    break
                default:
                    errorMessage = error.localizedDescription
                }
            } catch { }
        }
    }
}

struct CityDetailsEntry: View {
    var city: City
    var imageHeight: CGFloat

    var body: some View {
        ScrollView {
            VStack {
                Color(.sRGB, red: 0.922, green: 0.922, blue: 0.922, opacity: 1.0)
                    .overlay(thumbView)
                    .cornerRadius(10)
                    .frame(height: imageHeight)
                Text(city.description ?? "")
                    .font(.body)
            }
            .padding([.leading, .trailing, .bottom, .top], 20)
        }
    }

    var thumbView: some View {
        TermiNetwork.Image(request: Router<CityRoute>().request(for: .image(city: city)))
            .aspectRatio(contentMode: .fill)
    }
}
