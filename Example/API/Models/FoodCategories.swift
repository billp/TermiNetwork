//
//	FoodRootClass.swift
//
//	Create by Vasilis Panagiotopoulos on 15/2/2018
//	Copyright © 2018. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation

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
