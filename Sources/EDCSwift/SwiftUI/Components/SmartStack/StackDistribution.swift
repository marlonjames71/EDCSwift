//
//  StackDistribution.swift
//  EDCSwift
//
//  Created by Marlon Raskin on 2026-04-11.
//

import SwiftUI

/// Defines how a `SmartHStack` or `SmartVStack` distributes its subviews.
public enum StackDistribution: Equatable, Sendable {
	/// Uses the default SwiftUI stack behavior and spacing.
	/// - Parameter spacing: Optional fixed spacing between subviews.
	///
	case standard(spacing: CGFloat? = nil)

	/// Distributes subviews with equal gaps that fill available space.
	case equalSpacing

	/// Centers the entire group and optionally applies fixed spacing.
	/// - Parameter spacing: Optional fixed spacing between subviews.
	///
	case centered(spacing: CGFloat? = nil)

	var containerShouldExpand: Bool {
		switch self {
		case .standard: return false
		default: return true
		}
	}

	var layoutShouldExpand: Bool {
		switch self {
		case .standard: return false
		default: return true
		}
	}
}

// MARK: - Environment

extension EnvironmentValues {
	@Entry public var stackDistribution: StackDistribution = .standard(spacing: nil)
}

// MARK: - View Modifier

extension View {
	/// Sets the stack distribution for any nested `SmartHStack` and `SmartVStack`.
	/// - Parameter distribution: The distribution strategy to apply.
	///
	public func distribution(_ distribution: StackDistribution) -> some View {
		environment(\.stackDistribution, distribution)
	}
}
