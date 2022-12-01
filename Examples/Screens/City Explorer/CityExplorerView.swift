// CityExplorerView.swift
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

import SwiftUI
import TermiNetwork
import Combine

struct CityExplorerView: View {
    
    @StateObject var viewModel: ViewModel

    var body: some View {
        VStack {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .multilineTextAlignment(.center)
                    .accentColor(.red)
                    .font(.caption)
                    .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30))
            } else if viewModel.cities.count == 0 {
                ProgressView()
            } else {
                List(viewModel.cities, id: \.id) { city in
                    CityRow(city: city, 
                            usesMockData: viewModel.usesMockData,
                            thumbWidth: 100,
                            thumbHeight: 100)
                }
            }
        }
        .navigationTitle("City Explorer")
        .onDisappear { 
            viewModel.onDissapear() 
        }
    }
}

struct CityRow: View {
    var city: City
    var usesMockData: Bool
    var thumbWidth: CGFloat
    var thumbHeight: CGFloat
    
    @State private var imageLoaded: Bool = false

    var body: some View {
        NavigationLink(destination: CityExplorerDetails(viewModel: .init(city: city, usesMockData: usesMockData))) {
            Color(.sRGB, red: 0.922, green: 0.922, blue: 0.922, opacity: 1.0)
                .frame(width: thumbWidth, height: thumbHeight)
                .overlay(thumbView)
                .cornerRadius(10)
            Text(city.name).font(.headline)
        }
    }

    @ViewBuilder
    var thumbView: some View {
        let request = Router<CityRoute>().request(for: .thumb(city: city))
        
        ZStack {
            if !imageLoaded {
                ProgressView()
            }
            
            TermiNetwork.Image(request: request, 
                               resizeTo: CGSize(width: thumbWidth,
                                                height: thumbHeight),
                               onFinish: { _, _ in
                imageLoaded = true
            })
            .aspectRatio(contentMode: .fill)
        }
    }
}

extension CityExplorerView {
    @MainActor class ViewModel: ObservableObject {        
        private var activeRequest: Request?
        
        @Published var cities: [City] = []
        @Published var errorMessage: String?
        
        var usesMockData: Bool
        
        init(usesMockData: Bool) {
            self.usesMockData = usesMockData
            Environment.current.configuration?.mockDataEnabled = usesMockData

            Task {
                await loadCities()
            }
        }
        
        func onDissapear() {
            activeRequest?.cancel()
        }
        
        func loadCities() async {
            activeRequest = Router<CityRoute>().request(for: .cities)
            
            do {
                cities = try await activeRequest?.async(using: CitiesTransformer.self) ?? []
            } catch let error {
                switch error as? TNError {
                case .cancelled:
                    break
                default:
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
