//
//  MasterViewController.swift
//  PizzaMe
//
//  Copyright © 2016 Charles Schwab & Co., Inc. All rights reserved.
//

import UIKit
import QuartzCore

class MasterViewController: UITableViewController {

	var detailViewController: DetailTableViewController? = nil
	var viewModel:RestaurantListViewModel?
	var customHeaderView : CustomHeaderView
	let locationManager = LocationManager.sharedInstance
	var isAlphabetical = false

	@IBOutlet var pizzaSpinner:UIImageView!

	override func viewDidLoad() {
		super.viewDidLoad()
		if let split = self.splitViewController {
			let controllers = split.viewControllers
			self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailTableViewController
		}

		configureTableView()
	}

	override func viewWillAppear(_ animated: Bool) {
		self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
		super.viewWillAppear(animated)
		self.pizzaSpinner.isHidden = true
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	required init?(coder aDecoder: NSCoder) {
		customHeaderView = CustomHeaderView.instanceFromNib()
		super.init(coder: aDecoder)
	}


	// MARK: - Segues

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showDetail" {
			if let indexPath = self.tableView.indexPathForSelectedRow {
				let selection = viewModel?.restaurant(indexPath: indexPath)
				let controller = (segue.destination as! UINavigationController).topViewController as! DetailTableViewController
				controller.detailItem = selection
				controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
				controller.navigationItem.leftItemsSupplementBackButton = true
			}
		}
	}

	// MARK: - Table View

	func configureTableView(){

		self.tableView.tableFooterView = UIView()
		self.customHeaderView.isHidden = true
		self.tableView.rowHeight = UITableViewAutomaticDimension
		self.tableView.estimatedRowHeight = 100
		self.tableView.sectionHeaderHeight = 60
		self.tableView.estimatedSectionHeaderHeight = UITableViewAutomaticDimension

	}

	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		customHeaderView.delegate = self
		return customHeaderView
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel?.restaurantCount ?? 0
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantCell", for: indexPath)

		if let restaurantCell = cell as? RestaurantTableViewCell {
			if let restaurant = viewModel?.restaurant(indexPath: indexPath) {
				restaurantCell.configure(viewModel: RestaurantCellViewModel(restaurant: restaurant))
			}
		}
		return cell
	}

	@IBAction func updateMyLocation(sender: AnyObject) {
		toggleSpinningPizza()
		locationManager.delegate = self
		locationManager.updateLocation()
	}

	func toggleSpinningPizza() {
		pizzaSpinner.isHidden = !pizzaSpinner.isHidden
		if pizzaSpinner.isHidden {
			pizzaSpinner.layer.removeAllAnimations()
		} else {
			let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
			rotationAnimation.toValue = Float(.pi * 2.0)
			rotationAnimation.duration = 1.0
			rotationAnimation.isCumulative = true
			rotationAnimation.repeatCount = 100
			pizzaSpinner.layer.add(rotationAnimation, forKey: "rotationAnimation")
		}
	}
}

extension MasterViewController : SegmentedControlDelegate {

	func segmentedControlValueUpdated(selectedIndex: Int) {
		switch selectedIndex {
		case 0:
			isAlphabetical = false
			locationManager.updateLocation()
			tableView.reloadData()
		case 1:
			isAlphabetical = true
			locationManager.updateLocation()
			tableView.reloadData()
		default:
			break
		}
	}
}

extension MasterViewController : LocationManagerDelegate {
	func didUpdate(zipCode: String) {
		SearchService().resultsByZip(zipCode: zipCode, completion: { (response, error) in
			self.toggleSpinningPizza()
			if error != nil {
				let alertController = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Unable to find any pizza near you.", comment: ""), preferredStyle: .alert)
				let defaultAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { (action) in
				}
				alertController.addAction(defaultAction)
				DispatchQueue.main.async {
					self.present(alertController, animated: true, completion: {
					})
				}
			}
			else if let response = response {
				self.viewModel = RestaurantListViewModel(restaurantList: response.restaurantList, isAlphabetical: self.isAlphabetical)
				DispatchQueue.main.async {
					self.tableView.reloadData()
					self.tableView.tableHeaderView = UIView()
					self.customHeaderView.isHidden = false
				}
			}
		})
	}

	func didFail(error: NSError) {
		toggleSpinningPizza()
		let alertController = UIAlertController(title: NSLocalizedString("Location Error", comment: ""), message: NSLocalizedString("An error occurred while getting your location.", comment: ""), preferredStyle: .alert)
		let defaultAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { (action) in
		}
		alertController.addAction(defaultAction)
		DispatchQueue.main.async {
			self.present(alertController, animated: true, completion: {
			})
		}
	}
}

