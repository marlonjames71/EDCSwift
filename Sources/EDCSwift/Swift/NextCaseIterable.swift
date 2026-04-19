//
//  NextCaseIterable.swift
//  EDCSwift
//
//  Created by Marlon Raskin on 2026-04-19.
//

import Foundation

// MARK: - NextCaseIterable

/// A protocol for enums that can cycle through their cases in order.
///
/// Conforming types gain:
/// - `nextCase`: returns the case following the current one in the order of `allCases`,
///   wrapping back to the first case when at the end.
/// - `advance()`: mutates the instance to its `nextCase`.
///
/// Both `nextCase` and `advance()` wrap around to the first case when the current
/// case is the last in `allCases`.
///
/// Enums that adopt `NextCaseIterable` must also conform to `Equatable` so the
/// current case can be located within `allCases`.
/// Conformance to `CaseIterable` is inherited automatically; its `allCases`
/// collection defines the ordering of cases.
///
/// ## Example
/// ```swift
/// enum TrafficLight: NextCaseIterable, Equatable {
///     case red, green, yellow
/// }
///
/// var current = TrafficLight.red
/// let next = current.nextCase        // .green
///
/// let last = TrafficLight.yellow
/// let wrapped = last.nextCase        // .red
///
/// current.advance()                  // current = .green
/// current.advance()                  // current = .yellow
/// current.advance()                  // current = .red
/// ```
public protocol NextCaseIterable: CaseIterable {
	/// Returns the next case in the enum's `allCases` collection.
	///
	/// If the current instance is the last case in the `allCases` collection,
	/// this property returns the first case, effectively cycling through the cases.
	var nextCase: Self { get }

	/// Sets the next case in the enum's `allCases` collection.
	///
	/// > If the current instance is the last case in the `allCases` collection,
	/// this function sets the first case, effectively cycling through the cases.
	mutating func advance()
}

extension NextCaseIterable where Self: Equatable {
	// MARK: Properties with Bodies

	public var nextCase: Self {
		let allCases = Self.allCases
		guard let currentIndex = allCases.firstIndex(of: self) else {
			// This scenario should ideally not occur if `self` is a valid case
			// of a CaseIterable enum. Returning `self` as a fallback.
			return self
		}

		let nextIndex = allCases.index(after: currentIndex)
		if nextIndex == allCases.endIndex {
			// `allCases.first` is guaranteed to exist if the enum has at least one case,
			// which is a requirement for non-empty CaseIterable enums.
			return allCases.first!
		} else {
			return allCases[nextIndex]
		}
	}

	// MARK: Functions

	public mutating func advance() {
		self = nextCase
	}
}
