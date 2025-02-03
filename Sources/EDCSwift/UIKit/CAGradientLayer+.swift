//
//  File.swift
//  EDCSwift
//
//  Created by Marlon Raskin on 2025-01-03.
//

import UIKit

extension UIView {
	/// Adds a gradient fill to the view.
	func addGradient(colors: [UIColor], axis: CAGradientLayer.GradientAxis) {
		let layer = CAGradientLayer.gradientLayer(axis: axis, in: self.bounds, colors: colors)
		self.layer.addSublayer(layer)
	}
}

extension CAGradientLayer {
	
	public enum GradientAxis {
		public typealias AxisPoints = (startPoint: CGPoint, endPoint: CGPoint)
		
		/// Starts at the left and ends at the right
		case horizontal
		
		/// Starts at the top and ends at the bottom
		case vertical
		
		/// Starts at the top-left corner and ends at the bottom-right corner
		case leadingDiagonal
		
		/// Starts at the top-right corner and ends at the bottom-left corner
		case trailingDiagonal
	}
}

extension CAGradientLayer.GradientAxis {
	
	public var points: AxisPoints {
		switch self {
		case .horizontal:
			(CGPoint(x: 0, y: 0.5), CGPoint(x: 1, y: 0.5))
		case .vertical:
			(CGPoint(x: 0.5, y: 0), CGPoint(x: 0.5, y: 1))
		case .leadingDiagonal:
			(CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 1))
		case .trailingDiagonal:
			(CGPoint(x: 1, y: 0), CGPoint(x: 0, y: 1))
		}
	}
}

extension CAGradientLayer {
	
	/// Creates a gradient layer
	public static func gradientLayer(
		axis: GradientAxis,
		in bounds: CGRect,
		colors: [UIColor]
	) -> Self {
		let layer = Self()
		layer.frame = bounds
		layer.colors = colors.map(\.cgColor)
		layer.startPoint = axis.points.startPoint
		layer.endPoint = axis.points.endPoint
		
		return layer
	}
}
