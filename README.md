# TermiNetwork

TermiNetwork is a networking library written with Swift 4.0 that supports multi-environment configuration, routing and automatic deserialization (currently **Codable** and **UIImage** deserialization is supported).

# Features
- [x] Multi-environment configuration (by conforming **TNEnvironmentProtocol**)
- [x] Routing (by conforming **TNRouteProtocol**)
- [x] Error handling support
- [x] Automatic deserialization with **Codable** and **UIImage** (by passing the type in **TNSuccessCallback**)

## Installation

TermiNetwork is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following lines to your Podfile:

```ruby
platform :ios, '9.0'
use_frameworks!

target 'YourTarget' do
    pod 'TermiNetwork', '~> 0.1'
end
```

## Usage

1. Create a swift file called **Environments.swift** that conforms to **TNEnvironmentProtocol** and define your environments by creating an enum as shown bellow.

```swift
import TermiNetwork

enum Environment: TNEnvironmentProtocol {
    case localhost
    case dev
    case production

    func configure() -> TNEnvironment {
        switch self {
            case .localhost:
                return TNEnvironment(scheme: .https, host: "localhost", port: 8080)
            case .dev:
                return TNEnvironment(scheme: .https, host: "mydevserver.com", suffix: path("v1"))
            case .production:
                return TNEnvironment(scheme: .http, host: "www.themealdb.com", suffix: path("api", "json", "v1", "1"))
        }
    }
}
```

2. Set your active environment in **`application(_:didFinishLaunchingWithOptions)`** or everywhere else you want, in your application's initialization code.

```
TNEnvironment.set(Environment.production)
```

3. Create your models represented with **Codable**.

Example models: **FoodCategories**, **FoodCategory**

```swift
struct FoodCategories: Codable {

	let categories: [FoodCategory]

    	enum CodingKeys: String, CodingKey {
		case categories
	}
}

struct FoodCategory : Codable {
	let idCategory: String
	let strCategory: String
	let strCategoryDescription: String
	let strCategoryThumb: String

	enum CodingKeys: CodingKey {
		case idCategory
		case strCategory
		case strCategoryDescription
		case strCategoryThumb
	}
}
```

4. Create your router class that conforms to **TNRouteProtocol**. There is no limit for a number router classes that you can create :)

```swift
enum APIFoodRouter: TNRouteProtocol {
    // Define your routes
    case categories
    case category(id: Int)
    case createCategory(title: String)
    
    // Set method, path, params, headers for each route
    internal func construct() -> TNRouteReturnType {
        switch self {
        case .categories:
            return (
                method: .get,
                path: path("categories.php"), // Generates: http(s)://.../categories.php
                params: nil,
                headers: nil
            )
        case .category(let id):
            return (
                method: .get,
                path: path("category", String(id)), // Generates: http(s)://.../category/1236
                params: nil,
                headers: nil
            )
        case .createCategory(let title):
            return (
                method: .post,
                path: path("categories", "create"), // Generates: http(s)://.../categories/create
                params: ["title": title],
                headers: nil
            )
        }
    }
    
    // Create static helper functions for each route
    static func getCategories(onSuccess: @escaping TNSuccessCallback<FoodCategories>, onFailure: @escaping TNFailureCallback) {
        do {
            try TNCall(route: self.categories).start(onSuccess: onSuccess, onFailure: onFailure)
        } catch TNRequestError.environmentNotSet {
            debugPrint("environment not set")
        } catch TNRequestError.invalidURL {
            debugPrint("invalid url")
        } catch {
            debugPrint("any other error")
        }
    }
}
```
> In your helper methods section you need to define your model class along with **TNSuccessCallback** that determines the type of the response data which is being returned. Deserialization takes place automatically.

5. Finally use your helper functions anywhere in your project
```swift
APIFoodRouter.getCategories(onSuccess: { categories in
    debugPrint(categories.categories.map({ $0.strCategory }))
}) { error in
    debugPrint(error)
}
```

categories returned from **onSuccess** are of type **FoodCategories**

> If you run the project after following all these steps you will get an error because **http://** is not allowed due to security. You need to add "NSAppTransportSecurity" (Dictionary) > "NSAllowsArbitraryLoads" (Boolean) > YES. But this is just for the demo, please don't do it to your own projects :)

### Image Deserialization

Image deserialization is as easy as deserializing with Codable, just pass **UIImage** in **TNSuccessCallback** and you will get the actual **UIImage** object ready to use. If the response is not an image, **TNFailureCallback** gets called with the appropriate error. Define your helper as shown bellow:

```swift
struct APICustomHelpers {
    static func getImage(url: String, onSuccess: @escaping TNSuccessCallback<UIImage>, onFailure: @escaping TNFailureCallback) {
        try? TNCall(method: .get, url: url, params: nil).start(onSuccess: onSuccess, onFailure: onFailure)
    }
}
```

And finally call the helper wherever you need:

```swift
APICustomHelpers.getImage(url: "https://picsum.photos/240/240", onSuccess: { image in
    thumbImageView.image = image
}) { error in
    debugPrint(error)
}
```

### Built-in Router Helpers 

If you are finding yourself writing helpers that don't do anything complex (like handling http error codes) and your Router class begins to grow for no reason, **TNRouteProtocol** comes with 3 helper methods that you can use directly from your Router class to ease your life. 

1. For deserializing model

```swift
try? APIFoodRouter.makeCall(route: APIFoodRouter.categories, responseType: FoodCategories.self, onSuccess: { categories in
    self.categories = categories.categories
    self.tableView.reloadData()
    self.tableView.isHidden = false
}) { error, data in
    debugPrint(error)
}
```

2. For deserializing image

```swift
try? APIFoodRouter.makeCall(route: APIFoodRouter.categoryImage(imageID: 12345), responseType: UIImage.self, onSuccess: { image in
    //do something with image
}) { error, data in
    debugPrint(error)
}
```

3. For any other case
```swift
try? APIFoodRouter.makeCall(route: APIFoodRouter.getPlainText, onSuccess: { data in
    // Do something with data
}) { error, data in
    debugPrint(error)
}
```

### Use of **TNCall** Independently

You can use the **TNCall** class to create a **URLRequest** and use it with another library such as Alamofire by providing method, custom headers, path and parameters, as shown bellow

```swift
let params = [
    "sort_by": "first_name",
    "mode": "ascending"
]

let headers = [
    "Content-type": "application/json"
]

let request: URLRequest? = try? TNCall(method: .get, headers: headers, path: path("users", "list"), params: params).asRequest()
```

### Request Cancellation
You can cancel a request which is executing by storing a reference of **TNCall** to a variable and then by calling the **.cancel()** method like this

```swift
//Keep a reference of TNCall
let call = TNCall(method: .get, url: url, params: nil)
try call.start(onSuccess: onSuccess, onFailure: onFailure)

//Cancel anytime you want
call.cancel()
```

### Supported Request Methods

You can use any of the following request methods: **get, head, post, put, delete, connect, options, trace, patch**


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
                debugPrint("Network error: " + error.localizedDescription)
                break
            case .cancelled(let error):
                debugPrint("Request cancelled with error: " + error.localizedDescription)
                break
            default: 
	    	debugPrint("Error: " + error.localizedDescription)
        }

        //execute the passed onFailure block (for completion)
        onFailure(error, data)
    })
}
```

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

