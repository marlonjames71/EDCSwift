//
//  PatternMatching.swift
//  EDCSwift
//
//  Created by Marlon Raskin on 2025-10-09.
//

import Foundation

extension Equatable {
	/// Returns a Boolean value indicating whether the instance is equal to any of the given options.
	///
	/// - Parameter options: A variadic list of values to compare against the instance.
	/// - Returns: `true` if the instance is equal to at least one of the provided options; otherwise, `false`.
	/// - Example:
	///   ```swift
	///   let value = 2
	///   let result = value.isOne(of: 1, 2, 3) // result is true
	///   ```
	public func isOne(of options: Self...) -> Bool {
		options.contains(self)
	}
}

