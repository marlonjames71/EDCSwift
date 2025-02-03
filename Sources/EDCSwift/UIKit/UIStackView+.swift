//
//  File.swift
//  EDCSwift
//
//  Created by Marlon Raskin on 2025-01-03.
//

import UIKit

extension UIStackView {
	/// A wrapper around `layoutMargins` that automatically enables layout margins
	/// relative arrangement when modified.
	///
	/// You can use this property to get or set the layout margins for the stack view.
	/// Setting this property will update the underlying `layoutMargins` and set
	/// `isLayoutMarginsRelativeArrangement` to `true`, ensuring that the margins
	/// affect arranged subviews.
	public var contentLayoutMargins: UIEdgeInsets {
		get { layoutMargins }
		set {
			layoutMargins = newValue
			isLayoutMarginsRelativeArrangement = true
		}
	}
}

extension UIStackView {
	/// Modifies the stack view's padding using a closure.
	///
	/// The provided closure receives the current `contentLayoutMargins` as its argument,
	/// allowing you to apply one or more changes using method chaining. The closure should
	/// return the updated `UIEdgeInsets` which will then be set as the new content layout margins.
	///
	/// - Parameter modification: A closure that takes the current `UIEdgeInsets` and returns
	///   the modified `UIEdgeInsets`.
	///
	/// - Example:
	///   ```swift
	///   stack.setPadding { insets in
	///       insets.top(20).right(10)
	///   }
	///   ```
	///   This updates the top margin to 20 and the right margin to 10.
	public func setPadding(_ modification: (UIEdgeInsets) -> UIEdgeInsets) {
		contentLayoutMargins = modification(contentLayoutMargins)
	}
}
