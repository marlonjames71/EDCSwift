//
//  View+.swift
//  EDCSwift
//
//  Created by Marlon Raskin on 2025-09-14.
//

import SwiftUI

extension View {
	func frame(square value: CGFloat, alignment: Alignment = .center) -> some View {
		self.frame(width: value, height: value, alignment: alignment)
	}
}
