# TermiNetwork
[![Build Status](https://travis-ci.org/billp/TermiNetwork.svg?branch=master)](https://travis-ci.org/billp/TermiNetwork)
[![Pod](https://img.shields.io/cocoapods/v/TermiNetwork.svg?style=flat)](https://cocoapods.org/pods/terminetwork)

TermiNetwork is a networking library written in Swift 4.0 that supports multi-environment configuration, routing and automatic deserialization.

# Features
- [x] Specify the return type between [String, Data, Codable, JSON (SwiftyJSON)]
- [x] Multi-environment configuration
- [x] Routing
- [x] Error handling
- [x] Automatic deserialization

## Installation

TermiNetwork is available through [CocoaPods](http://cocoapods.org). To install
it simply add the following lines to your Podfile and run **pod install** in your terminal:

```ruby
platform :ios, '9.0'
use_frameworks!

target 'YourTarget' do
    pod 'TermiNetwork', '~> 0.3'
end
```

## Usage

### Simple usage

```swift
let params = ["title": "Go shopping."]
let headers = ["x-auth": "abcdef1234"]

TNRequest(method: .post, url: "https://myweb.com/todos", headers: headers, params: params).start(responseType: JSON.self, onSuccess: { json in
    print(json)
}) { (error, data) in
    print(error)
}
```

#### Arguments

*method*: one of the following supported HTTP methods

```
.get, .head, .post, .put, .delete, .connect, .options, .trace or .patch
```

*responseType*: one of the following supported response types
```
JSON.self, Codable.self, UIImage.self, Data.self or String.self
```

*responseType* argument.

*onSuccess*: a callback returning an object with the data type specified by

*onFailure*: a callback returning an error+data on failure. There are two cases of this callback being called: the first is that the http status code is different than 2xx and the second is that there is an error with data conversion, e.g. it fails on deserialization of the *responseType*.

### Advanced usage with configuration and custom queue
The request bellow uses a custom queue *myQueue* with a failure mode of value *.continue* (default), which means that the queue continues its execution even if a request fails and a max concurrent operation count of 2. It also uses a TNRequestConfiguration object that specifies some additional request parameters.

```swift
let myQueue = TNQueue(failureMode: .continue)
myQueue.maxConcurrentOperationCount = 2

let configuration = TNRequestConfiguration(
    cachePolicy: .useProtocolCachePolicy,
    timeoutInterval: 30,
    requestBodyType: .JSON
)

let params = ["title": "Go shopping."]
let headers = ["x-auth": "abcdef1234"]

TNRequest(method: .post,
          url: "https://myweb.com/todos",
          headers: headers,
          params: params,
          configuration: configuration).start(queue: myQueue, responseType: JSON.self, onSuccess: { json in
    print(json)
}) { (error, data) in
    print(error)
}
```
#### Additional arguments

*configuration*: The configuration object to use. The available configuration proerties are:
- *cachePolicy*: The NSURLRequest.CachePolicy used by NSURLRequest internally (see apple docs for available values). Default value: *.useProtocolCachePolicy*
- *timeoutInterval*: The timeout interval used by NSURLRequest internally  (see apple docs for more info). Default value: 60
- *requestBodyType*: It specifies how to send request params, available values:
  - .xWWWFormURLEncoded (default): It sends the params as application/x-www-form-urlencoded mime type.
  - .JSON: It converts the params to JSON format and them as application/json mime type.

*queue*: It specifies the queue in which the request will be  added. If you omit this argument, the request is being added to a shared queue (TNQueue.shared).

## Error Handling

Available error cases (TNError) passed in *onFailure* callback of a TNRequest:
- *.environmentNotSet*: You forgot to set the Router environment.
- *.invalidURL*: The url cannot be parsed, e.g. it contains invalid characters.
- *.responseDataIsEmpty*: the server response body is empty. You can avoid this error by setting *TNRequest.allowEmptyResponseBody* to *true*.
- *.responseInvalidImageData*: failed to convert response Data to UIImage.
- *.cannotDeserialize(Error)*: e.g. your model structure doesn't match with the server's response. It carries the the error thrown by deserializer (DecodingError.dataCorrupted),
- *.cannotConvertToJSON*: cannot convert the response Data to JSON object (SwiftyJSON).
- *.networkError(Error)*: e.g. timeout error. It carries the error from URLSessionDataTask.
- *.notSuccess(Int)*: The http status code is different to *2xx*. It carries the actual status code of the completed request.
- *.cancelled(Error)*: The request is cancelled. It carries the error from URLSessionDataTask.

In any case you can use the **error.description** method to get a readable error message in onFailure callback.

#### Example

```swift
TNRequest(method: .get, url: "https://myweb.com/todos").start(responseType: JSON.self, onSuccess: { json in
            print(json)
        }) { (error, data) in
            switch error {
            case .notSuccess(let statusCode):
                debugPrint("Status code " + String(statusCode))
                break
            case .networkError(let error):
                debugPrint("Network error: " + error.localizedDescription)
                break
            case .cancelled(let error):
                debugPrint("Request cancelled with error: " + error.localizedDescription)
                break
            default:
                debugPrint("Error: " + error.localizedDescription)
            }
        }
```

## UIImageView Extension
You can use the *setRemoteImage* method of UIImageView to download an image from a remote server

Example:
```swift
imageView.setRemoteImage(url: "http://www.website.com/image.jpg", defaultImage: UIImage(named: "DefaultImage"), beforeStart: {
	imageView.activityIndicator.startAnimating()
}, preprocessImage: { image in // This block will run in background
	let newImage = image.resize(100, 100)
	return newImage
}) { image, error in
	imageView.activityIndicator.stopAnimating()
}
```

## Hooks
Hooks are running before and/or after request execution and allow you to run a block of code automatically. Supported hooks are:

```swift

TNCall.beforeAllRequestsBlock = {
    // e.g. show progress loader
}

TNCall.afterAllRequestsBlock = {
    // e.g. hide progress loader
}

TNCall.beforeEachRequestBlock = { call in // call: TNCall
    // e.g. print log
}

TNCall.afterEachRequestBlock = { call, data, urlResponse, error in // call: TNCall, data: Data, urlResponse: URLResponse, error: Error
    // e.g. print log
}
```

If you don't want a request take part to beforeAllRequests/afterAllRequests hooks (e.g. a request that downloads thumbnails and adds it to an UIImageView), set the TNCall's ***skipBeforeAfterAllRequestsHooks*** property to ***true*** like this
```swift
static func getImage(url: String, onSuccess: @escaping TNSuccessCallback<UIImage>, onFailure: @escaping TNFailureCallback) throws -> TNCall {
	let call = TNCall(method: .get, url: url, params: nil)
        call.skipBeforeAfterAllRequestsHooks = true
        try call.start(onSuccess: onSuccess, onFailure: onFailure)

        return call
}
```

## Logging

You can turn on verbose mode to see what's going on in terminal for each request by setting the **TNEnvironment.verbose** to **true**

## TODO
- [x] Write test cases
- [x] Add support for request cancelation
- [x] Error handling
- [ ] Add support for downloading/uploading files

## Contribution

Feel free to contribute to the project by creating a pull request and/or by reporting any issue(s) you find

## Author

Bill Panagiotopoulos, billp.dev@gmail.com

## Contributors

Alex Athanasiadis, alexanderathan@gmail.com

## License

TermiNetwork is available under the MIT license. See the LICENSE file for more info.
