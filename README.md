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

```java
TNRequest(method: .get, url: "https://jsonplaceholder.typicode.com/todos/1", params: nil).start(responseType: JSON.self, onSuccess: { json in
    print(json)
}) { (error, data) in
    print(error)
}
```

### Arguments

**method**: one of the following supported HTTP methods

```
.get, .head, .post, .put, .delete, .connect, .options, .trace or .patch
```

**responseType**: one of the following supported response types
```
JSON.self, UIImage.self, Codable.self, Data.self or String.self
```

**success**: a callback returning an object with the data type specified by **responseType** argument.

**failure**: a callback returning an error and data on failure. There are two cases of this callback being called: the first is that the http status code is different than 2xx and the second is that it fails on data conversion, e.g. it fails on deserialization.

## Error Handling

There are two groups of errors that you can handle, the first group includes those that can be handled before request execution (e.g. invalid url, params), with try/catch, and the second group includes those that can be handled after request execution (e.g. empty response from server,  server error, etc...), passed in **onFailure** closure.

### Errors before request execution

Available error cases to catch:

- **environmentNotSet**
- **invalidURL**

#### Example

```swift
static func getCategories(onSuccess: @escaping TNSuccessCallback<FoodCategories>, onFailure: @escaping TNFailureCallback) {
    do {
        try TNCall(route: APIFoodRouter.categories).start(onSuccess: onSuccess, onFailure: onFailure)
    } catch TNRequestError.environmentNotSet {
        debugPrint("environment not set")
    } catch TNRequestError.invalidURL {
        debugPrint("invalid url")
    } catch {
        debugPrint("any other error")
    }
}
```
### Errors after request execution

Available error cases in **onFailure** closure:

- **responseDataIsEmpty**: the server response body is empty. You can avoid this error by setting **TNCall.allowEmptyResponseBody** to **true**
- **responseInvalidImageData**: in case of image deserialization
- **cannotDeserialize(Error)**: e.g. your model structure doesn't match with the server's response. It returns the error thrown by deserializer (DecodingError.dataCorrupted)
- **networkError(Error)**: e.g. time out error, contains the error from URLSessionDataTask, in case you need it
- **notSuccess(Int)**: The server's response is not success, that is http status code is different to **2xx**. The status code is returned so you can do whatever you need with it
- **cancelled(Error)**: When you cancel a request by calling the **.cancel()** method you will get this error, along with the error from URLSessionDataTask.

In any case you can use the **error.localizedDescription** method to get a readable error message in onFailure callback.

#### Example

```swift
static func testFailureCall(onSuccess: @escaping TNSuccessCallback<Data>, onFailure: @escaping TNFailureCallback) {
    try! TNCall(route: APIFoodRouter.test).start(onSuccess: onSuccess, onFailure: { error, data in
        switch error {
            case .notSuccess(let statusCode):
                debugPrint("Status code " + String(statusCode))
                break
            case .networkError(let error):
                debugPrint("Network error: " + error)
                break
            case .cancelled(let error):
                debugPrint("Request cancelled with error: " + error)
                break
            default:
                debugPrint("Error: " + error.localizedDescription)
        }

        //Fallthrough to the passed onFailure block
        onFailure(error, data)
    })
}
```

## Queues
When you call the **.start(...)** method of **TNCall**, it's added to a default **TNQueue** (**TNQueue.shared**) under the hood. You can also initialize your own **TNQueue** and set your own params that meet your needs. Bellow you can see an example of how you can initialize your own queue.

```swift
let myQueue = TNQueue(failureMode: .continue) // You can set also .cancelAll
myQueue.maxConcurrentOperationCount = 3 // Set the concurrent requests executing to 3

try? TNCall(method: .get, url: "http://www.google.com", params: nil).start(queue: myQueue, onSuccess: { _ in
	// Success
}) { error, data in
	// Failure
}

```
Because **TNQueue** is a subclass of **OperationQueue**, you can use all the properties/methods of its parent, like for example **.cancelAllOperations()** which cancels all the requests in queue.


## Fixed Headers
You can set headers to be automatically included to every **TNCall** by setting your headers to the static var **fixedHeaders** (useful when you have to include authorization token in headers)

```swift
TNCall.fixedHeaders = ["Authorization": "[YOUR TOKEN]"]
```

## Cache Policy and Timeout Interval
You can set a cache policy and timeout interval that is suitable to your needs by using the convenience initializer of TNCall
```swift
try? TNCall(route: APIFoodRouter.categories, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 5).start(onSuccess: onSuccess, onFailure: onFailure)
```
> More info about cachePolicy you can find at Apple's documentation: https://developer.apple.com/documentation/foundation/nsurlrequest.cachepolicy

## UIImageView Extension
You can use the **setRemoteImage** method of UIImageView to download an image from a remote server

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
