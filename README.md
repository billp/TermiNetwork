<p></p>
<p align="center">
  <img src="https://raw.githubusercontent.com/billp/TermiNetwork/master/TermiNetworkLogo.svg" alt="" data-canonical-src="" width="500rem" />
</p>
who
<p align="center"><b> A zero-dependency networking solution for building modern and secure iOS, watchOS, macOS and tvOS applications.</b>
  <br /><br />
  <img src="https://github.com/billp/TermiNetwork/actions/workflows/main.yml/badge.svg" />
  <img src="https://img.shields.io/cocoapods/v/TermiNetwork.svg?style=flat" />
  <img src="https://img.shields.io/badge/Carthage-compatible-green" />
  <img src="https://img.shields.io/badge/Language-Swift 5.3-blue" />
  <img src="https://img.shields.io/github/license/billp/TermiNetwork" />
  <img src="https://img.shields.io/cocoapods/p/TermiNetwork" />
  <a href="https://codecov.io/gh/billp/TermiNetwork">
    <img src="https://codecov.io/gh/billp/TermiNetwork/branch/master/graph/badge.svg?token=QI9KOV99AG" />
  </a>
  <img src="https://billp.github.io/TermiNetwork/badge.svg" />
</p>
<p align="center">
🚀 <i><b>TermiNetwork</b> has been tested in a production environment with a heavy load of asynchronous requests and tens of thousands of unique clients per day</i>.
<br /><br />
<img alt="" data-canonical-src="" alt="TermiNetworkDiagram" src="https://raw.githubusercontent.com/billp/TermiNetwork/master/TermiNetworkDiagram.svg" />
<br />
<i>This is a high level diagram of <b>TermiNetwork</b> showing how its componets are connected to each other.</I>
<br /><br />

## Features
- [x] Multi-environment setup <br />
- [x] Model deserialization with <b>Codables</b><br />
- [x] Async await support<br />
- [x] Decodes response to the given type: <b>Codable</b>, <b>Transformer</b>, <b>UIImage</b>, <b>Data</b> or <b>String</b><br />
- [x] <b>UIKit</b>/<b>SwiftUI</b> extensions for downloading remote images<br />
- [x] Request grouping with Repositories<br />
- [x] Detects network status with Reachability<br />
- [x] Transformers: convert models from one type to another easily<br />
- [x] Error Handling<br />
- [x] Interceptors<br />
- [x] Request mocking<br />
- [x] Certificate Pinning<br />
- [x] Flexible configuration<br />
- [x] Middleware support<br />
- [x] File/Data Upload/Download support<br />
- [x] Pretty printed debug information

### Table of contents
- [Installation](#installation)
- [Demo Application](#demo_app)
- [Usage](#usage)
  - [Simple usage of <b>Request</b>](#simple_usage)
  - [Advanced usage of <b>Request</b> with <b>Configuration</b> and custom <b>Queue</b>](#advanced_usage)
  - [Complete project setup with <b>Environments</b> and <b>Repositories</b> (Recommended)](#complete_setup)
	  - [Environment setup](#setup_environments)
	  - [Repository setup](#setup_repositories)
	  - [Make a request](#construct_request)
- [Queue Hooks](#queue_hooks)
- [Error Handling](#error_handling)
- [Cancelling a Request](#request_cancelling)
- [Reachability](#reachability)
- [Transformers](#transformers)
- [Mock responses](#mock_responses)
- [Interceptors](#interceptors)
- [Image Helpers](#image_helpers)
	- [SwiftUI Image Helper](#swift_ui_image_helper)
	- [UIImageView, NSImageView, WKInterfaceImage Extensions](#image_extensions)
- [Middleware](#middleware)
- [Debug Logging](#debug_logging)

<a name="installation"></a>

## Installation
You can install **TermiNetwork** with one of the following ways...
### CocoaPods

Add the following line to your **Podfile** and run **pod install** in your terminal:
```ruby
pod 'TermiNetwork', '~> 3.2.0'
```

### Carthage

Add the following line to your **Carthage** and run **carthage update** in your terminal:
```ruby
github "billp/TermiNetwork" ~> 3.2.0
```

### Swift Package Manager

Go to **File** > **Swift Packages** > **Add Package Dependency** and add the following URL:
```
https://github.com/billp/TermiNetwork
```

<a name="demo_app"></a>

## Demo Application
To see all the features of TermiNetwork in action, download the source code and run the **TermiNetworkExamples** scheme.

<a name="usage"></a>

## Usage

<a name="simple_usage"></a>

### Simple usage (Request)

Let's say you have the following Codable model:

```swift
struct Todo: Codable {
   let id: Int
   let title: String
}
```

The following example creates a request that adds a new Todo:

```swift
let params = ["title": "Go shopping."]
let headers = ["x-auth": "abcdef1234"]

Request(method: .get,
	url: "https://myweb.com/api/todos",
	headers: headers,
	params: params)
    .success(responseType: Todo.self) { todos in
	print(todos)
    }
    .failure { error in
	print(error.localizedDescription)
    }
```

or with **async await**:

```swift
let request = Request(method: .get, 
                      url: "https://myweb.com/api/todos", 
                      headers: headers, 
                      params: params)

do {
    let todos: [Todo] = try await request.async()
    print(todos)
} catch let error { 
    print(error.localizedDescription)
}
```

#### Parameters Explanation

##### method
One of the following supported HTTP methods:
```
.get, .head, .post, .put, .delete, .connect, .options, .trace or .patch
```

##### responseType
One of the following supported response types
```
Codable.self (implementations), UIImage.self, Data.self or String.self
```

##### onSuccess
A callback that returns an object of the given type. (specified in responseType parameter)

##### onFailure
A callback that returns a **Error** and the response **Data** (if any).

<a name="advanced_usage"></a>

### Advanced usage of Request with Configuration and custom Queue

The following example uses a custom **Queue** with **maxConcurrentOperationCount** and a configuration object. To see the full list of available configuration properties, take a look at <a href="https://billp.github.io/TermiNetwork/Classes/Configuration.html#/Public%20properties" target="_blank">Configuration properties</a> in documentation.

```swift
let myQueue = Queue(failureMode: .continue)
myQueue.maxConcurrentOperationCount = 2

let configuration = Configuration(
    cachePolicy: .useProtocolCachePolicy,
    timeoutInterval: 30,
    requestBodyType: .JSON
)

let params = ["title": "Go shopping."]
let headers = ["x-auth": "abcdef1234"]

Request(method: .post,
        url: "https://myweb.com/todos",
        headers: headers,
        params: params,
        configuration: configuration)
    .queue(queue)
    .success(responseType: String.self) { response in
        print(response)
    }
    .failure { error in
        print(error.localizedDescription)
    }
```

or with **async await**:

```swift
do {
    let response = try Request(
    	method: .post,
	url: "https://myweb.com/todos",
	headers: headers,
	params: params,
	configuration: configuration
    )
    .queue(queue)
    .async(as: String.self)
} catch let error {
    print(error.localizedDescription)
}
```


The request above uses a custom queue **myQueue** with a failure mode of **.continue** (default), which means that the queue continues its execution if a request fails.

<a name="complete_setup"></a>

## Complete setup with <b>Environments</b> and <b>Repositories</b>
The complete and recommended setup of TermiNetwork consists of defining **Environments** and **Repositories**.  

<a name="setup_environments"></a>

#### Environment setup
Create a swift **enum** that implements the **EnvironmentProtocol** and define your environments.

##### Example
```swift
enum MyAppEnvironments: EnvironmentProtocol {
    case development
    case qa

    func configure() -> Environment {
        switch self {
        case .development:
            return Environment(scheme: .https,
                               host: "localhost",
                               suffix: .path(["v1"]),
                               port: 3000)
        case .qa:
            return Environment(scheme: .http,
                               host: "myqaserver.com",
                               suffix: .path(["v1"]))
        }
    }
}
```
*Optionally you can  pass a **configuration** object to make all Repositories and Endpoints to inherit the given configuration settings.*

To set your global environment use Environment.set method
```swift
Environment.set(MyAppEnvironments.development)
```

<a name="setup_repositories"></a>

#### Repository setup
Create a swift **enum** that implements the **EndpointProtocol** and define your endpoints.

The following example creates a TodosRepository with all the required endpoints as cases.

##### Example
```swift
enum TodosRepository: EndpointProtocol {
    // Define your endpoints
    case list
    case show(id: Int)
    case add(title: String)
    case remove(id: Int)
    case setCompleted(id: Int, completed: Bool)

    static let configuration = Configuration(requestBodyType: .JSON,
                                             headers: ["x-auth": "abcdef1234"])


    // Set method, path, params, headers for each endpoint
    func configure() -> EndpointConfiguration {

        switch self {
        case .list:
            return .init(method: .get,
                         path: .path(["todos"]), // GET /todos
                         configuration: Self.configuration)
        case .show(let id):
            return .init(method: .get,
                         path: .path(["todo", String(id)]), // GET /todos/[id]
                         configuration: Self.configuration)
        case .add(let title):
            return .init(method: .post,
                         path: .path(["todos"]), // POST /todos
                         params: ["title": title],
                         configuration: Self.configuration)
        case .remove(let id):
            return .init(method: .delete,
                         path: .path(["todo", String(id)]), // DELETE /todo/[id]
                         configuration: configuration)
        case .setCompleted(let id, let completed):
            return .init(method: .patch,
                         path: .path(["todo", String(id)]), // PATCH /todo/[id]
                         params: ["completed": completed],
                         configuration: configuration)
        }
    }
}

```
You can optionally pass a **configuration** object to each case if you want provide different configuration for each endpoint.

<a name="construct_request"></a>

#### Make a request
To create the request you have to initialize a **Client** instance and specialize it with your defined Repository, in our case **TodosRepository**:
```swift
Client<TodosRepository>().request(for: .add(title: "Go shopping!"))
    .success(responseType: Todo.self) { todo in
        // do something with todo
    }
    .failure { error in
        // do something with error
    }
```

or with **async await**

```swift
do {
    let toto: Todo = Client<TodosRepository>()
	.request(for: .add(title: "Go shopping!"))
	.async()
} catch let error {
    print(error.localizedDescription)
}
```

<a name="queue_hooks"></a>

## Queue Hooks
Hooks are closures that  run before and/or after a request execution in a queue. The following hooks are available:

```swift
Queue.shared.beforeAllRequestsCallback = {
    // e.g. show progress loader
}

Queue.shared.afterAllRequestsCallback = { completedWithError in
    // e.g. hide progress loader
}

Queue.shared.beforeEachRequestCallback = { request in
    // do something with request
}

Queue.shared.afterEachRequestCallback = { request, data, urlResponse, error
    // do something with request, data, urlResponse, error
}
```

 For more information take a look at <a href="https://billp.github.io/TermiNetwork/Classes/Queue.html" target="_blank">Queue</a> in documentation.

<a name="error_handling"></a>

## Error Handling

TermiNetwork provides its own error types (TNError) for all the possible error cases. These errors are typically returned in onFailure callbacks of **start** methods.

To see all the available errors, please visit the <a href="https://billp.github.io/TermiNetwork/Enums/TNError.html" target="_blank">TNError</a> in documentation.


#### Example

```swift
Client<TodosRepository>().request(for: .add(title: "Go shopping!"))
      .success(responseType: Todo.self) { todo in
         // do something with todo
      }
      .failure: { error in
          switch error {
          case .notSuccess(let statusCode):
               debugPrint("Status code " + String(statusCode))
               break
          case .networkError(let error):
               debugPrint("Network error: " + error.localizedDescription)
               break
          case .cancelled:
               debugPrint("Request cancelled")
               break
          default:
               debugPrint("Error: " + error.localizedDescription)
       }
```

or with **async await**
```swift
do {
    let todo: Todo = Client<TodosRepository>()
	.request(for: .add(title: "Go shopping!"))
	.async()
} catch let error {
    switch error as? TNError {
    case .notSuccess(let statusCode, let data):
         let errorModel = try? data.deserializeJSONData() as MyErrorModel
	 debugPrint("Status code " + String(statusCode) + ". API Error: " + errorModel?.errorMessage)
	 break
    case .networkError(let error):
	 debugPrint("Network error: " + error.localizedDescription)
	 break
    case .cancelled:
	 debugPrint("Request cancelled")
	 break
    default:
	 debugPrint("Error: " + error.localizedDescription)
 }
```
<a name="request_cancelling"></a>
## Cancelling a request
You can cancel a request that is executing by calling the .cancel() method.
#### Example
	
```swift
let params = ["title": "Go shopping."]
let headers = ["x-auth": "abcdef1234"]

let request = Request(method: .get, 
	      url: "https://myweb.com/api/todos", 
	      headers: headers, 
	      params: params)

	
request.success(responseType: Todo.self) { todos in
    print(todos)
}
.failure { error in
    print(error.localizedDescription)
}
	
request.cancel()
```

or with **async await**:

```swift

let task = Task {
    let request = Request(method: .get, 
	url: "https://myweb.com/api/todos", 
	headers: headers, 
	params: params)
    do {
        let todos: [Todo] = try await request.async()
        print(todos)
    } catch let error { 
        print(error.localizedDescription)
    }
}

task.cancel()
```

<a name="reachability"></a>
## Reachability
With Reachability you can monitor the network state of the device, like whether it is connected through wifi or cellular network.
#### Example

```swift
let reachability = Reachability()
try? reachability.monitorState { state in
    switch state {
    case .wifi:
        // Connected through wifi
    case .cellular:
        // Connected through cellular network
    case .unavailable:
        // No connection
    }
}
```

<a name="transformers"></a>
## Transformers

Transformers enables you to convert your Rest models to Domain models by defining your custom **transform** functions. To do so, you have to create a class that inherits the **Transformer** class and specializing it by providing the FromType and ToType generics.

The following example transforms an array of **RSCity** (rest) to an array of **City** (domain) by overriding the transform function.

#### Example

```swift
final class CitiesTransformer: Transformer<[RSCity], [City]> {
    override func transform(_ object: [RSCity]) throws -> [City] {
        object.map { rsCity in
            City(id: UUID(),
                 cityID: rsCity.id,
                 name: rsCity.name,
                 description: rsCity.description,
                 countryName: rsCity.countryName,
                 thumb: rsCity.thumb,
                 image: rsCity.image)
        }
    }
}
```

Finally, pass the **CitiesTransformer** in the Request's start method:
#### Example
```swift
Client<CitiesRepository>()
    .request(for: .cities)
    .success(transformer: CitiesTransformer.self) { cities in
        self.cities = cities
    }
    .failure { error in
        switch error {
        case .cancelled:
            break
        default:
            self.errorMessage = error.localizedDescription
        }
    }
```

or with **async await**
```swift
do {
    let cities = await Client<CitiesRepository>()
        .request(for: .cities)
        .async(using: CitiesTransformer.self)
} catch let error {
    switch error as? TNError {
    case .cancelled:
        break
    default:
        self.errorMessage = error.localizedDescription
    }
}
```

<a name="mock_responses"></a>
## Mock responses
**Mock responses** is a powerful feature of TermiNetwork that enables you to provide a local resource file as Request's response. This is useful, for example, when the API service is not yet available and you need to implement the app's functionality without losing any time. (Prerequisite for this is to have an API contract)

#### Steps to enable mock responses

1. Create a Bundle resource and put your files there. (File > New -> File... > Settings Bundle)
2. Specify the Bundle path in Configuration
	#### Example
	```swift
	let configuration = Configuration()
	if let path = Bundle.main.path(forResource: "MockData", ofType: "bundle") {
	    configuration.mockDataBundle = Bundle(path: path)
	}
	```
3. Enable Mock responses in Configuration
	#### Example
 	```swift
	configuration.mockDataEnabled = true
	```
4. Define the mockFilePath path in your endpoints.
	 #### Example
 	```swift
	enum CitiesRepository: EndpointProtocol {
        case cities

        func configure() -> EndpointConfiguration {
        switch self {
        case .cities:
            return EndpointConfiguration(method: .get,
                                         path: .path(["cities"]),
                                         mockFilePath: .path(["Cities", "cities.json"]))
	        }
	    }
	}
	```
	The example above loads the **Cities/cities.json** from **MockData.bundle** and returns its data as Request's response.

For a complete example, open the demo application and take a look at **City Explorer - Offline Mode**.

<a name="interceptors"></a>
## Interceptors
Interceptors offers you a way to change or augment the usual processing cycle of a Request.  For instance, you can refresh an expired access token (unauthorized status code 401) and then retry the original request. To do so, you just have to implement the **InterceptorProtocol**.

The following Interceptor implementation tries to refresh the access token with a retry limit (5).

#### Example
```swift
final class UnauthorizedInterceptor: InterceptorProtocol {
    let retryDelay: TimeInterval = 0.1
    let retryLimit = 5

    func requestFinished(responseData data: Data?,
                         error: TNError?,
                         request: Request,
                         proceed: @escaping (InterceptionAction) -> Void) {
        switch error {
        case .notSuccess(let statusCode):
            if statusCode == 401, request.retryCount < retryLimit {
                // Login and get a new token.
                Request(method: .post,
                        url: "https://www.myserviceapi.com/login",
                        params: ["username": "johndoe",
                                 "password": "p@44w0rd"])
                    .success(responseType: LoginResponse.self) { response in
                        let authorizationValue = String(format: "Bearer %@", response.token)

                        // Update the global header in configuration which is inherited by all requests.
                        Environment.current.configuration?.headers["Authorization"] = authorizationValue

                        // Update current request's header.
                        request.headers["Authorization"] = authorizationValue

                        // Finally retry the original request.
                        proceed(.retry(delay: retryDelay))
                    }
            } else {
	 	// Continue if the retry limit is reached
	    	proceed(.continue)
            }
        default:
            proceed(.continue)
        }
    }
}

```

Finally, you have to pass the **UnauthorizedInterceptor** to the interceptors property in Configuration:

#### Example
```swift
let configuration = Configuration()
configuration.interceptors = [UnauthorizedInterceptor.self]
```

<a name="image_helpers"></a>

## SwiftUI/UIKit Image Helpers
TermiNetwork provides two different helpers for setting remote images.
<a name="swift_ui_image_helper"></a>
### SwiftUI Image Helper
#### Examples
1.  **Example with URL**

	```swift
	var body: some View {
	    TermiNetwork.Image(withURL: "https://example.com/path/to/image.png",
		               defaultImage: UIImage(named: "DefaultThumbImage"))
	}
	```
2.  **Example with Request**

	```swift
	var body: some View {
	    TermiNetwork.Image(withRequest: Client<CitiesRepository>().request(for: .image(city: city)),
	                       defaultImage: UIImage(named: "DefaultThumbImage"))
	}
	```

<a name="image_extensions"></a>
### UIImageView, NSImageView, WKInterfaceImage Extensions

1. **Example with URL**

	```swift
	let imageView = UIImageView() // or NSImageView (macOS), or WKInterfaceImage (watchOS)
	imageView.tn_setRemoteImage(url: sampleImageURL,
	                            defaultImage: UIImage(named: "DefaultThumbImage"),
	                            preprocessImage: { image in
	    // Optionally pre-process image and return the new image.
	    return image
	}, onFinish: { image, error in
	    // Optionally handle response
	})
	```
2. **Example with Request**

	```swift
	let imageView = UIImageView() // or NSImageView (macOS), or WKInterfaceImage (watchOS)
	imageView.tn_setRemoteImage(request: Client<CitiesRepository>().request(for: .thumb(withID: "3125")),
	                            defaultImage: UIImage(named: "DefaultThumbImage"),
	                            preprocessImage: { image in
	    // Optionally pre-process image and return the new image.
	    return image
	}, onFinish: { image, error in
	    // Optionally handle response
	})
	```

<a name="middleware"></a>

## Middleware
Middleware enables you to modify headers, params and response before they reach the success/failure callbacks. You can create your own middleware by implementing the **RequestMiddlewareProtocol** and passing it to a **Configuration** object.

Take a look at *./Examples/Communication/Middleware/CryptoMiddleware.swift*  for an example that adds an additional encryption layer to the application.

<a name="debug_logging"></a>

## Debug Logging

You can enable the debug logging by setting the **verbose** property to **true** in your **Configuration**.
```swift
let configuration = Configuration()
configuration.verbose = true
```
... and you will see a beautiful pretty-printed debug output in debug window

<img width="750px" src="https://user-images.githubusercontent.com/1566052/102597522-75be5200-4123-11eb-9e6e-5740e42a20a5.png">

## Tests

To run the tests open the Xcode Project > TermiNetwork scheme, select Product -> Test or simply press ⌘U on keyboard.

## Contributors

Alex Athanasiadis, alexanderathan@gmail.com

## License

TermiNetwork is available under the MIT license. See the LICENSE file for more info.
