# SimpleNetworking

SimpleNetworking is a networking library written with Swift 4.0 that supports multi-environment configuration, routing and automatic deserialization (with Codable).

## Usage

1. Create a swift file called **Environments.swift** that comforms to SNEnvironmentProtocol and define your environments by creating an enum as shown bellow. 

```swift
import SimpleNetworking

enum Environment: SNEnvironmentProtocol {
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

2. Set your active environment in **`application(_:didFinishLaunchingWithOptions)`** or everywhere else you want, in your application's initialization code.

```
SNEnvironment.env = Environment.production
```

3. Create your models represented with Codable. (Only Codable serialization is supported at the moment)

Example models: FoodCategories, FoodCategory

```swift
struct FoodCategories: Codable {
    	let categories: [FoodCategory]

	enum CodingKeys: String, CodingKey {
		case categories = "categories"
	}
	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		categories = try values.decode([FoodCategory].self, forKey: .categories)
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
	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		idCategory = try values.decode(String.self, forKey: .idCategory)
		strCategory = try values.decode(String.self, forKey: .strCategory)
		strCategoryDescription = try values.decode(String.self, forKey: .strCategoryDescription)
		strCategoryThumb = try values.decode(String.self, forKey: .strCategoryThumb)
	}
}

```

4. Create your router class that comforms to SNRouteProtocol. There is no limit for a number router classes that you can create :)

```swift
import SimpleNetworking

enum APIFoodRouter: SNRouteProtocol {
    // Define your routes
    case categories
    
    // Set method, path, params, headers for each route
    internal func construct() -> SNRouteReturnType {
        switch self {
        case .categories:
            return (
                method: .get,
                path: path("categories.php"),
                params: nil,
                headers: nil
            )
        }
    }
    
    // Create static helper functions for each route
    static func getCategories(onSuccess: @escaping SNSuccessCallback<FoodRootClass>, onFailure: @escaping SNFailureCallback) {
        try? SNCall(route: APIFoodRouter.categories).start(onSuccess: onSuccess, onFailure: onFailure)
    }
}
```
In your helper funcs section you need to define your model class along with **SNSuccessCallback** that determines the type of the response data which is being returned. Deserialization takes place automatically.

5. Finally use your helper functions anywhere in your project
```swift
APIFoodRouter.getCategories(onSuccess: { categories in
    self.categories = categories.categories!
    self.tableView.reloadData()
    self.tableView.isHidden = false
}) { error in
    debugPrint(error)
}
```

categories returned from onSuccess are of type FoodCategories

### Use SNCall independently

You can use the SNCall class to create a URLRequest and use it with another library such as Alamofire by providing method, custom headers, path and parameters, as shown bellow

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

## Contribution

Feel free to contribute to the project by creating a pull request and/or by reporting any issue(s) you find

## Author

Bill Panagiotopouplos, billp.dev@gmail.com

## License

SimpleNetworking is available under the MIT license. See the LICENSE file for more info.
