//
//  View+Padding.swift
//  EDCSwift
//
//  Created by Marlon Raskin on 2025-10-09.
//

import SwiftUI

// MARK: - EdgePadding

/// An ergonomic way to specify padding for a SwiftUI view.
///
/// Provides cases for setting padding on all edges, horizontal edges,
/// vertical edges, or specific individual edges.
///
public enum EdgePadding {

	/// Padding to apply on the top edge.
	case top(CGFloat)

	/// Padding to apply on the bottom edge.
	case bottom(CGFloat)

	/// Padding to apply on the leading edge.
	case leading(CGFloat)

	/// Padding to apply on the trailing edge.
	case trailing(CGFloat)

	/// Padding to apply on both leading and trailing edges.
	case horizontal(CGFloat)

	/// Padding to apply on both top and bottom edges.
	case vertical(CGFloat)

	/// Padding to apply on all edges.
	case all(CGFloat)
}

// MARK: - EdgePadding

/// Aggregates multiple `EdgePadding` values into resolved edge paddings.
///
/// Uses a precedence order for resolving conflicting paddings:
/// `.all` < `.horizontal`/`.vertical` < individual edges.
/// This allows more specific values to override more general ones.
///
public struct EdgePaddings {
	public var top: CGFloat = 0

	public var bottom: CGFloat = 0

	public var leading: CGFloat = 0

	public var trailing: CGFloat = 0

	/// Creates an `EdgePaddings` instance from an array of `EdgePadding` values.
	///
	/// The initializer applies paddings in three passes:
	/// 1. `.all` values are applied first to all edges.
	/// 2. `.horizontal` and `.vertical` values override the relevant edges.
	/// 3. Individual edge paddings (`.top`, `.bottom`, `.leading`, `.trailing`) override all previous values.
	///
	/// This approach allows ergonomic patterns like `[.all(16), .top(20)]`.
	///
	/// - Parameter paddings: An array of `EdgePadding` values to aggregate.
	///
	public init(_ paddings: [EdgePadding]) {
		// First pass: apply .all padding — (will be overriden by more specific
		// edge paddings later is supplied).
		for padding in paddings {
			if case let .all(value) = padding {
				top = value
				bottom = value
				leading = value
				trailing = value
			}
		}

		// Second pass: apply group paddings (horizontal and vertical)
		for padding in paddings {
			switch padding {
			case let .horizontal(value):
				leading = value
				trailing = value

			case let .vertical(value):
				top = value
				bottom = value

			default:
				continue
			}
		}

		// Third pass: Apple specific edge paddings (override groups).
		for padding in paddings {
			switch padding {
			case let .top(value):
				top = value

			case let .bottom(value):
				bottom = value

			case let .leading(value):
				leading = value

			case let .trailing(value):
				trailing = value

			default:
				continue
			}
		}
	}
}

extension View {
	/// Ergonomically applies padding to the view using one or more `EdgePadding` values.
	///
	/// Example:
	/// ```
	/// view.edgePadding(.all(16), .top(20))
	/// ```
	/// This applies a base padding of 16 points on all edges, but overrides
	/// the top edge with 20 points.
	///
	/// - Parameter paddings: A variadic list of `EdgePadding` values.
	/// - Returns: A view with the specified paddings applied.
	///
	public func edgePadding(_ paddings: EdgePadding...) -> some View {
		edgePadding(EdgePaddings(paddings))
	}

	/// Applies the resolved edge paddings to the view as `EdgeInsets`.
	///
	/// - Parameter paddings: An `EdgePaddings` instance representing the resolved paddings.
	/// - Returns: A view with the paddings applied via `padding(EdgeInsets)`.
	///
	public func edgePadding(_ paddings: EdgePaddings) -> some View {
		padding(
			EdgeInsets(
				top: paddings.top,
				leading: paddings.leading,
				bottom: paddings.bottom,
				trailing: paddings.trailing
			)
		)
	}
}
