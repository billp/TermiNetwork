// Image.swift
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
import Combine
import SwiftUI

#if os(macOS)
/// The Image type depending on platform: UIImage for iOS or NSImage for macOS.
public typealias TNImageType = NSImage
#elseif os(iOS) || os(watchOS) || os(tvOS)
/// The Image type depending on platform: UIImage for iOS or NSImage for macOS.
public typealias TNImageType = UIImage
#endif

/// Callback type for image preprocess used in UIImageView|NSImage|WKInterfaceImage and Image (SwiftUI) helpers
/// - parameters:
///     - image: The downloaded image.
/// - returns: The new transformed image.
public typealias ImagePreprocessType = (_ image: TNImageType) -> (TNImageType)
/// Callback type for image downloaded event.
/// - parameters:
///     - image: The downloaded image.
///     - error: A TNError object if it fails to download.
/// - returns: The new transformed image.
public typealias ImageOnFinishCallbackType = (_ image: TNImageType?, _ error: TNError?) -> Void

@available(iOS 13.0, *)
/// :nodoc:
final class ImageLoader: ObservableObject {
    private var request: Request
    private var url: String?
    private var defaultImage: TNImageType?
    private var resize: CGSize?
    private var preprocessImageClosure: ImagePreprocessType?
    private var onFinishImageClosure: ImageOnFinishCallbackType?

    @Published var image = TNImageType()

    init(with url: String,
         configuration: Configuration? = nil,
         defaultImage: TNImageType? = nil,
         resize: CGSize? = nil,
         preprocessImage: ImagePreprocessType? = nil,
         onFinish: ImageOnFinishCallbackType? = nil) {
        self.url = url
        self.request = Request(method: .get,
                                 url: url,
                                 configuration: configuration)
        self.defaultImage = defaultImage
        self.resize = resize
        self.preprocessImageClosure = preprocessImage
        self.onFinishImageClosure = onFinish
    }

    init(with request: Request,
         defaultImage: TNImageType? = nil,
         resize: CGSize? = nil,
         preprocessImage: ImagePreprocessType? = nil,
         onFinish: ImageOnFinishCallbackType? = nil) {
        self.request = request
        self.defaultImage = defaultImage
        self.resize = resize
        self.preprocessImageClosure = preprocessImage
        self.onFinishImageClosure = onFinish
        self.url = try? request.asRequest().url?.absoluteString
    }

    func loadImage() {
        if let url = url,
           let cachedImageData = Cache.shared[url],
           let image = TNImageType(data: cachedImageData) {
            self.image = image
            return
        }

        self.image = defaultImage ?? TNImageType()
        request.success(responseType: TNImageType.self) { [weak self] image in
            guard let self = self else { return }
            self.handlePreprocessImage(image: image) { [weak self] preprocessedImage in
                guard let self = self else { return }
                // Resize image only if preprocess image function is not present
                if preprocessedImage == nil {
                    self.handleResizeImage(image: image)
                }
            }
        }
        .failure {  [weak self] error in
            guard let self = self else { return }
            self.onFinishImageClosure?(nil, error)
        }

    }

    // MARK: Helpers
    private func updateImage(_ image: TNImageType) {
        self.image = image
        if let url = url {
            DispatchQueue.global(qos: .utility).async {
                #if os(macOS)
                    if let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
                        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
                        bitmapRep.size = image.size
                        Cache.shared[url] = bitmapRep.representation(using: .png, properties: [:])
                    }
                #else
                    Cache.shared[url] = image.pngData()
                #endif
            }
        }
    }

    private func handlePreprocessImage(image: TNImageType,
                                       onFinish: ((TNImageType?) -> Void)? = nil) {
        var image = image
        if let preprocessImage = self.preprocessImageClosure {
            DispatchQueue.global(qos: .background).async {
                image = preprocessImage(image)

                DispatchQueue.main.async {
                    self.updateImage(image)
                    self.onFinishImageClosure?(image, nil)
                    onFinish?(image)
                }
            }
        } else {
            onFinish?(nil)
        }
    }
    private func handleResizeImage(image: TNImageType,
                                   onFinish: ((TNImageType) -> Void)? = nil) {
        if let size = self.resize {
            DispatchQueue.global(qos: .userInteractive).async {
                let image = image.tn_resize(size) ?? image
                DispatchQueue.main.async {
                    self.updateImage(image)
                    onFinish?(image)
                }
            }
        } else {
            self.updateImage(image)
            onFinish?(image)
        }
    }
}

/// Image is a SwiftUI component for downloading images.
@available(iOS 13.0, *)
public struct Image: View {
    @ObservedObject var imageLoader: ImageLoader

    /// Main body
    public var body: some View {
        #if os(macOS)
        let image = SwiftUI.Image(nsImage: imageLoader.image)
        #else
        let image = SwiftUI.Image(uiImage: imageLoader.image)
        #endif

        image.resizable()
    }

    /// Download a remote image with the specified url.
    ///
    /// - parameters:
    ///     - url: The url of the image.
    ///     - configuration: A Configuration object that will be used to make the request.
    ///     - defaultImage: A UIImage|NSImage to show before the is downloaded (optional)
    ///     - resizeTo: Resizes the image to the given CGSize
    ///     - preprocessImage: A block of code that preprocesses the after the download.
    ///     This block will run in the background thread
    ///     - onFinish: A block of code to execute after the completion of the request.
    ///            If the request fails, an error will be returned
    public init(url: String,
                configuration: Configuration? = nil,
                defaultImage: TNImageType? = nil,
                resizeTo size: CGSize? = nil,
                preprocessImage: ImagePreprocessType? = nil,
                onFinish: ImageOnFinishCallbackType? = nil) {
        self.imageLoader = ImageLoader(with: url,
                                       configuration: configuration,
                                       defaultImage: defaultImage,
                                       resize: size,
                                       preprocessImage: preprocessImage,
                                       onFinish: onFinish)
        self.imageLoader.loadImage()
    }

    /// Download a remote image with the specified url.
    ///
    /// - parameters:
    ///     - request: A Request instance.
    ///     - configuration: A Configuration object that will be used to make the request.
    ///     - defaultImage: A UIImage|NSImage to show before the is downloaded (optional)
    ///     - resizeTo: Resizes the image to the given CGSize
    ///     - preprocessImage: A block of code that preprocesses the after the download.
    ///     This block will run in the background thread (optional)
    public init(request: Request,
                defaultImage: TNImageType? = nil,
                resizeTo size: CGSize? = nil,
                preprocessImage: ImagePreprocessType? = nil,
                onFinish: ImageOnFinishCallbackType? = nil) {
        self.imageLoader = ImageLoader(with: request,
                                       defaultImage: defaultImage,
                                       resize: size,
                                       preprocessImage: preprocessImage,
                                       onFinish: onFinish)
        self.imageLoader.loadImage()
    }
}
