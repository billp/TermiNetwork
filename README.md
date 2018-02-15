# SimpleNetworking


## Usage

1. Create a swift file called **Environments.swift** and define your environments by creating an enum like this. 

```swift
enum Environment {
    case localhost
    case dev
    case production
    
    func configure() -> SNEnvironment {
        switch self {
        case .localhost:
            return SNEnvironment(scheme: .https, host: "localhost", port: 8080)
        case .dev:
            return SNEnvironment(scheme: .https, host: "mydevserver.com", suffix: path("v1"))
        case .production:
            return SNEnvironment(scheme: .http, host: "www.themealdb.com", suffix: path("api", "json", "v1", "1"))
        }
    }
}
```

2. Set your active environment in **`application(_:didFinishLaunchingWithOptions)`** or everywhere you want, in your application's initialization code.

```
SNEnvironment.env = Environment.production
```

4. Create your models represented with Codable. (Only Codable serialization is supported at the moment)

Example model: FoodCategory

```swift
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
	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		idCategory = try values.decode(String.self, forKey: .idCategory)
		strCategory = try values.decode(String.self, forKey: .strCategory)
		strCategoryDescription = try values.decode(String.self, forKey: .strCategoryDescription)
		strCategoryThumb = try values.decode(String.self, forKey: .strCategoryThumb)
	}
}

```

5. 


### Use SNCall independently

You can use the SNCall class to create a NSRequest and use it with another library such as Alamofire by providing method, custom headers, path and parameters, as shown bellow

```swift    
let params = [
    "sort_by": "first_name",
    "mode": "ascending"
]

let headers = [
    "Content-type": "application/json"
]

let request = try? SNCall(method: .get, headers: headers, path: path("users", "list"), params: params).asRequest()
```


### Supported Request Methods

You can use any of the following request methods: **get, head, post, put, delete, connect, options, trace, patch**

## Installation

SimpleNetworking is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
use_frameworks!

target "YourTarget" do
        pod 'SimpleNetworking', :git => 'https://github.com/billp/SimpleNetworking.git'
end
```

## Author

Bill Panagiotopouplos, billp.dev@gmail.com

## License

SimpleNetworking is available under the MIT license. See the LICENSE file for more info.
