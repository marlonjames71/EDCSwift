//
//  File.swift
//  EDCSwift
//
//  Created by Marlon Raskin on 2025-01-03.
//

import UIKit

extension UIEdgeInsets {
	public init(top: Double) {
		self.init(top: top, left: 0, bottom: 0, right: 0)
	}
	
	public init(right: Double) {
		self.init(top: 0, left: 0, bottom: 0, right: right)
	}
	
	public init(bottom: Double) {
		self.init(top: 0, left: 0, bottom: bottom, right: 0)
	}
	
	public init(left: Double) {
		self.init(top: 0, left: left, bottom: 0, right: 0)
	}
	
	public init(horizontal: Double) {
		self.init(top: 0, left: horizontal, bottom: 0, right: horizontal)
	}
	
	public init(vertical: Double) {
		self.init(top: vertical, left: 0, bottom: vertical, right: 0)
	}
	
	public init(all: Double) {
		self.init(top: all, left: all, bottom: all, right: all)
	}
}

// MARK: - Instance Methods

extension UIEdgeInsets {
	public func top(_ value: CGFloat) -> Self {
		var insets = self
		insets.top = value
		return insets
	}
	
	public func left(_ value: CGFloat) -> Self {
		var insets = self
		insets.left = value
		return insets
	}
	
	public func bottom(_ value: CGFloat) -> Self {
		var insets = self
		insets.bottom = value
		return insets
	}
	
	public func right(_ value: CGFloat) -> Self {
		var insets = self
		insets.right = value
		return insets
	}
	
	public func all(_ value: CGFloat) -> Self {
		var insets = self
		insets.top = value
		insets.left = value
		insets.bottom = value
		insets.right = value
		return insets
	}
	
	public func vertical(_ value: CGFloat) -> Self {
		var insets = self
		insets.top = value
		insets.bottom = value
		return insets
	}
	
	public func horizontal(_ value: CGFloat) -> Self {
		var insets = self
		insets.left = value
		insets.right = value
		return insets
	}
}

// MARK: - EDGE INSETS BUILDER

extension UIEdgeInsets {
	public static var set: UIEdgeInsetBuilder { .init() }
}

public struct UIEdgeInsetBuilder {
	var top: CGFloat = 0
	var left: CGFloat = 0
	var bottom: CGFloat = 0
	var right: CGFloat = 0
	
	public func top(_ value: CGFloat) -> Self {
		var builder = self
		builder.top = value
		
		return builder
	}
	
	public func left(_ value: CGFloat) -> Self {
		var builder = self
		builder.left = value
		
		return builder
	}
	
	public func bottom(_ value: CGFloat) -> Self {
		var builder = self
		builder.bottom = value
		
		return builder
	}
	
	public func right(_ value: CGFloat) -> Self {
		var builder = self
		builder.right = value
		
		return builder
	}
	
	public func all(_ value: CGFloat) -> Self {
		var builder = self
		builder.top = value
		builder.left = value
		builder.bottom = value
		builder.right = value
		
		return builder
	}
	
	public func horizontal(_ value: CGFloat) -> Self {
		var builder = self
		builder.left = value
		builder.right = value
		
		return builder
	}
	
	public func vertical(_ value: CGFloat) -> Self {
		var builder = self
		builder.top = value
		builder.bottom = value
		
		return builder
	}
	
	public var insets: UIEdgeInsets {
		.init(
			top: top,
			left: left,
			bottom: bottom,
			right: right
		)
	}
}
