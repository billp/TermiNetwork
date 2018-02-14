# SimpleNetworking


## Usage

1. Create a swift file called **Environments.swift** and define your environments by creating a struct like this. Then set your active environment inside the setup function

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

2. Call **`Environment.setup()`** from **`application(_:didFinishLaunchingWithOptions)`**

3. Use **SNCall** to create and start a request by providing method, custom headers, path and parameters, as shown bellow

```swift
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

The generated URL from the above request is `https://mydevserver.com/v1/users/list`. You can use any of the following request methods: **get, head, post, put, delete, connect, options, trace, patch**

## Installation

SimpleNetworking is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
use_frameworks!

target "YourTarget" do
        pod 'SimpleNetworking', :git => 'https://github.com/billp/SimpleNetworking.git'
end```

## Author

Bill Panagiotopouplos, billp.dev@gmail.com

## License

SimpleNetworking is available under the MIT license. See the LICENSE file for more info.
