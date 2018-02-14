# SimpleNetworking


## Example

- Define your environments by creating a struct like this
```swift
struct Environment {
    static let localhost = SNEnvironment(scheme: .https, host: "localhost", port: 8080)
    static let dev = SNEnvironment(scheme: .https, host: "mydevserver.com", suffix: "v1")
    static let production = SNEnvironment(scheme: .https, host: "my-production-server.com", suffix: "v1")

    static func setup() {
        SNEnvironment.active = Environment.dev
    }
}

```
- Call `Environment.setup()` from `application(_:didFinishLaunchingWithOptions)`

```

let params = [
    "sort_by": "first_name",
    "mode": "ascending"
]

let headers = [
    "Content-type": "application/json"
]

try? SNCall(method: .get, headers: headers, path: path("users", "list"), params: params).start(onSuccess: { data in
    //Do something with data
}, onFailure: { error in
    //Do something with error
})
```
## Requirements

## Installation

SimpleNetworking is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SimpleNetworking', :git => 'https://github.com/billp/SimpleNetworking.git'
```

## Author

Bill Panagiotopouplos, billp.dev@gmail.com

## License

SimpleNetworking is available under the MIT license. See the LICENSE file for more info.
