//
//  File.swift
//  EDCSwift
//
//  Created by Marlon Raskin on 2025-01-03.
//

import UIKit

extension CACornerMask {
	
	static var topLeft: CACornerMask { .layerMinXMinYCorner }
	
	static var topRight: CACornerMask { .layerMaxXMinYCorner }
	
	static var bottomRight: CACornerMask { .layerMaxXMaxYCorner }
	
	static var bottomLeft: CACornerMask { .layerMinXMaxYCorner }
	
	static var all: CACornerMask { [.topLeft, .topRight, .bottomRight, .bottomLeft] }
	
	static var top: CACornerMask { [.topLeft, .topRight] }
	
	static var bottom: CACornerMask { [.bottomLeft, .bottomRight] }
	
	static var left: CACornerMask { [.topLeft, .bottomLeft] }
	
	static var right: CACornerMask { [.topRight, .bottomRight] }
	
	static var topLeftBottomRight: CACornerMask { [.topLeft, .bottomRight] }
	
	static var topRightBottomLeft: CACornerMask { [.topRight, .bottomLeft] }
}
