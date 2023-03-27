// UIImageView+Extensions.swift
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

#if os(macOS)
import AppKit
typealias ImageViewType = NSImageView
#elseif os(iOS) || os(tvOS)
import UIKit
typealias ImageViewType = UIImageView
#elseif os(watchOS)
import UIKit
import WatchKit
typealias ImageViewType = WKInterfaceImage
#endif

extension ImageViewType {
    private static var activeRequestsDictionary: [String: Request] = [:]
    private static var imageViewQueue: Queue = Queue()

    fileprivate static func downloadImage(request: Request,
                                          onSuccess: @escaping SuccessCallback<ImageType>,
                                          onFailure: @escaping FailureCallback) throws -> Request {
        request.queue(imageViewQueue)
            .success(responseType: ImageType.self, responseHandler: onSuccess)
            .failure(responseType: Data.self) { (data, error) in
                onFailure(error, data)
            }

        return request
    }

    ///
    /// Download a remote image with the specified url.
    ///
    /// - parameters:
    ///     - url: The url of the image.
    ///     - configuration: A Configuration object that will be used to make the request.
    ///     - defaultImage: A UIImage to show before the is downloaded (optional)
    ///     - resize: Resizes the image to the given CGSize
    ///     - preprocessImage: A block of code that preprocesses the after the download.
    ///     This block will run in the background thread (optional)
    ///     - onFinish: A block of code to execute after the completion of the download image request.
    ///            If the request fails, an error will be returned (optional)
    public func tn_setRemoteImage(url: String,
                                  configuration: Configuration? = nil,
                                  defaultImage: ImageType? = nil,
                                  resize: CGSize? = nil,
                                  preprocessImage: ImagePreprocessType? = nil,
                                  onFinish: ImageOnFinishCallbackType? = nil) {

        do {
            try makeRequest(with: Request.init(method: .get,
                                                 url: url,
                                                 configuration: configuration),
                            defaultImage: defaultImage,
                            resize: resize,
                            preprocessImage: preprocessImage,
                            onFinish: onFinish)
        } catch let error {
            onFinish?(nil, error as? TNError)
        }
    }

    ///
    /// Download a remote image with the specified url.
    ///
    /// - parameters:
    ///     - request: A Request instance.
    ///     - defaultImage: A UIImage to show before the is downloaded (optional)
    ///     - resize: Resizes the image to the given CGSize
    ///     - preprocessImage: A block of code that preprocesses the after the download.
    ///     This block will run in the background thread (optional)
    ///     - onFinish: A block of code to execute after the completion of the download image request.
    ///            If the request fails, an error will be returned (optional)
    public func tn_setRemoteImage(request: Request,
                                  defaultImage: ImageType? = nil,
                                  resize: CGSize? = nil,
                                  preprocessImage: ImagePreprocessType? = nil,
                                  onFinish: ImageOnFinishCallbackType? = nil) {
        do {
            try makeRequest(with: request,
                            defaultImage: defaultImage,
                            resize: resize,
                            preprocessImage: preprocessImage,
                            onFinish: onFinish)
        } catch let error {
            onFinish?(nil, error as? TNError)
        }
    }

    // MARK: Helpers
    private func makeRequest(with request: Request,
                             defaultImage: ImageType? = nil,
                             resize: CGSize? = nil,
                             preprocessImage: ImagePreprocessType? = nil,
                             onFinish: ImageOnFinishCallbackType? = nil) throws {
        cancelActiveCallInImageView()
        #if os(watchOS)
        self.setImage(defaultImage)
        #else
        self.image = defaultImage
        #endif

        setActiveCallInImageView(try ImageViewType.downloadImage(request: request,
                                                                   onSuccess: { [weak self] image in
            guard let self = self else { return }
            var image = image

            DispatchQueue.global(qos: .background).async {
                image = preprocessImage?(image) ?? image

                if let resize = resize {
                    image = image.tn_resize(resize) ?? image
                }

                DispatchQueue.main.async {
                    #if os(watchOS)
                    self.setImage(image)
                    #else
                    self.image = image
                    #endif
                    onFinish?(image, nil)
                }
            }
        }, onFailure: { [weak self] error, _ in
            guard let self = self else { return }

            #if os(watchOS)
            self.setImage(nil)
            #else
            self.image = nil
            #endif
            onFinish?(nil, error)
        }))
    }

    private func getAddress() -> String {
        return String(describing: Unmanaged.passUnretained(self).toOpaque())
    }

    private func cancelActiveCallInImageView() {
        ImageViewType.activeRequestsDictionary[getAddress()]?.cancel()
    }

    private func setActiveCallInImageView(_ call: Request) {
        ImageViewType.activeRequestsDictionary[getAddress()] = call
    }
}
