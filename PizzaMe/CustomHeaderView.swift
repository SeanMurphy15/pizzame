//
//  CustomHeaderView.swift
//  PizzaMe
//
//  Created by Sean Murphy on 11/3/16.
//  Copyright © 2016 Spinneweber, Robert. All rights reserved.
//

import UIKit

protocol SegmentedControlDelegate{
	func segmentedControlValueUpdated(selectedIndex: Int)
}

class CustomHeaderView: UIView {

	var delegate : SegmentedControlDelegate?

	@IBOutlet weak var segmentedControl: UISegmentedControl!

	class func instanceFromNib() -> CustomHeaderView {
		return UINib(nibName: "CustomHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CustomHeaderView
	}
	override func awakeFromNib() {
		super.awakeFromNib()
		configure()
	}

	func configure(){
		segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
	}

	func segmentedControlValueChanged(segmentedControl: UISegmentedControl){
		switch segmentedControl.selectedSegmentIndex {
		case 0:
			delegate?.segmentedControlValueUpdated(selectedIndex: 0)
		case 1:
			delegate?.segmentedControlValueUpdated(selectedIndex: 1)
		default:
			break
		}
	}
}
