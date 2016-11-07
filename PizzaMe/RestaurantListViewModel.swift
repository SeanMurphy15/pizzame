//
//  RestaurantListViewModel.swift
//  PizzaMe
//
//  Copyright © 2016 Charles Schwab & Co., Inc. All rights reserved.
//

import Foundation

struct RestaurantListViewModel {
	let restaurantCount:Int
	var restaurantList: Array<Restaurant>

	init(restaurantList: Array<Restaurant>, isAlphabetical: Bool) {
		self.restaurantList = restaurantList
		if isAlphabetical{
			self.restaurantList.sort { $0.name < $1.name }
		} else {
			self.restaurantList.sort { $0.distance < $1.distance }
		}
		restaurantCount = restaurantList.count
	}

	func restaurant(indexPath: IndexPath) -> Restaurant? {
		guard indexPath.row < restaurantList.count else {
			return nil
		}
		return restaurantList[indexPath.row]
	}
}
