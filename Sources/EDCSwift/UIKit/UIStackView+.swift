//
//  File.swift
//  EDCSwift
//
//  Created by Marlon Raskin on 2025-01-03.
//

import UIKit

extension UIStackView {
	
	public var contentLayoutMargins: UIEdgeInsets {
		get { layoutMargins }
		set {
			layoutMargins = newValue
			isLayoutMarginsRelativeArrangement = true
		}
	}
}
