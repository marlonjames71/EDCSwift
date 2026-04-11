//
//  StackLayout.swift
//  EDCSwift
//
//  Created by Marlon Raskin on 2026-04-11.
//

import SwiftUI

struct UnifiedStackLayout: Layout {
	let orientation: Axis
	let distribution: StackDistribution
	let alignment: Alignment

	private func getSpacing(between subviews: Subviews, at index: Int) -> CGFloat {
		switch distribution {
		case .standard(let s), .centered(let s):
			if let fixed = s { return fixed }
		case .equalSpacing:
			return 0
		}
		guard index < subviews.count - 1 else { return 0 }
		return subviews[index].spacing.distance(to: subviews[index+1].spacing, along: orientation)
	}

	/// Returns true if a subview is flexible on the main axis — i.e. it expands
	/// when given more space (e.g. `Spacer`, `frame(maxWidth/Height: .infinity)`).
	///
	/// Comparing `.unspecified` (natural size) against `.infinity` (maximum accepted
	/// size) correctly identifies flexible views: non-flexible views always return their
	/// natural size regardless of the proposal, so these two are equal. Flexible views
	/// return more when given more, so natural < max. Using `.zero` instead of
	/// `.unspecified` produces false positives for views like `ScrollView(.horizontal)`
	/// whose height collapses to 0 at a zero proposal but is fixed at content height otherwise.
	private func isFlexible(_ subview: LayoutSubviews.Element) -> Bool {
		let naturalSize = subview.sizeThatFits(.unspecified)
		let maxSize = subview.sizeThatFits(.infinity)
		return orientation == .horizontal
			? maxSize.width > naturalSize.width
			: maxSize.height > naturalSize.height
	}

	func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
		// Constrain the cross axis so children using frame(maxWidth/Height: .infinity)
		// receive a concrete value to expand into, while the main axis stays unconstrained
		// so distribution logic is unaffected.
		let crossProposal: ProposedViewSize = orientation == .horizontal
			? ProposedViewSize(width: nil, height: proposal.height)
			: ProposedViewSize(width: proposal.width, height: nil)

		let subviewSizes = subviews.map { $0.sizeThatFits(crossProposal) }

		let totalChildWidth = subviewSizes.reduce(0) { $0 + (orientation == .horizontal ? $1.width : $1.height) }
		let maxCrossAxis = subviewSizes.reduce(0) { max($0, (orientation == .horizontal ? $1.height : $1.width)) }

		var totalSpacing: CGFloat = 0
		if subviews.count > 1 {
			for i in 0..<subviews.count - 1 {
				totalSpacing += getSpacing(between: subviews, at: i)
			}
		}

		let totalMainAxis = totalChildWidth + totalSpacing
		let width = orientation == .horizontal ? totalMainAxis : maxCrossAxis
		let height = orientation == .horizontal ? maxCrossAxis : totalMainAxis

		// If any child is flexible on the main axis (Spacer, frame(maxHeight: .infinity), etc.)
		// claim the full proposed main-axis size so the layout can distribute space to them.
		let hasFlexible = subviews.contains { isFlexible($0) }

		if distribution.layoutShouldExpand || hasFlexible {
			return CGSize(
				width: orientation == .horizontal ? (proposal.width ?? width) : width,
				height: orientation == .vertical ? (proposal.height ?? height) : height
			)
		} else {
			return CGSize(width: width, height: height)
		}
	}

	func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
		guard !subviews.isEmpty else { return }

		let crossProposal: ProposedViewSize = orientation == .horizontal
			? ProposedViewSize(width: nil, height: bounds.height)
			: ProposedViewSize(width: bounds.width, height: nil)

		let flexibleIndices = Set(subviews.indices.filter { isFlexible(subviews[$0]) })
		var subviewSizes = subviews.map { $0.sizeThatFits(crossProposal) }

		// --- FLEXIBLE SPACE DISTRIBUTION ---
		// Divide remaining main-axis space equally among flexible children.
		if !flexibleIndices.isEmpty {
			var totalSpacing: CGFloat = 0
			if subviews.count > 1 {
				for i in 0..<subviews.count - 1 {
					totalSpacing += getSpacing(between: subviews, at: i)
				}
			}

			let totalFixed = subviewSizes.enumerated().reduce(0.0) { sum, pair in
				flexibleIndices.contains(pair.offset) ? sum :
					sum + (orientation == .horizontal ? pair.element.width : pair.element.height)
			}

			let remaining = (orientation == .horizontal ? bounds.width : bounds.height) - totalFixed - totalSpacing
			let share = max(0, remaining / CGFloat(flexibleIndices.count))

			for i in flexibleIndices {
				let flexProposal: ProposedViewSize = orientation == .horizontal
					? ProposedViewSize(width: share, height: bounds.height)
					: ProposedViewSize(width: bounds.width, height: share)
				subviewSizes[i] = subviews[i].sizeThatFits(flexProposal)
			}
		}

		// --- PRE-CALCULATION ---
		var totalContentSize: CGFloat = 0
		for (index, size) in subviewSizes.enumerated() {
			totalContentSize += (orientation == .horizontal ? size.width : size.height)
			if index < subviews.count - 1 {
				totalContentSize += getSpacing(between: subviews, at: index)
			}
		}

		// --- START POSITION CALCULATION ---
		let centerPos = orientation == .horizontal ? bounds.midX : bounds.midY
		let startPos = centerPos - (totalContentSize / 2)
		var currentPos = startPos

		if case .standard = distribution {
			currentPos = orientation == .horizontal ? bounds.minX : bounds.minY
		}

		if case .equalSpacing = distribution {
			 currentPos = orientation == .horizontal ? bounds.minX : bounds.minY
		}

		// --- GAP CALCULATION (For equalSpacing) ---
		let totalChildSize = subviewSizes.reduce(0) { $0 + (orientation == .horizontal ? $1.width : $1.height) }
		let availableSpace = (orientation == .horizontal ? bounds.width : bounds.height) - totalChildSize
		let gap = (distribution == .equalSpacing && subviews.count > 1)
			? availableSpace / CGFloat(subviews.count - 1)
			: 0

		// --- PLACEMENT LOOP ---
		for (index, subview) in subviews.enumerated() {
			let size = subviewSizes[index]

			// Calculate Cross-Axis Position based on Alignment
			var xPosition: CGFloat = 0
			var yPosition: CGFloat = 0

			if orientation == .horizontal {
				xPosition = currentPos
				// Handle Vertical Alignment (Top/Center/Bottom)
				switch alignment.vertical {
				case .top:    yPosition = bounds.minY
				case .bottom: yPosition = bounds.maxY - size.height
				default:      yPosition = bounds.midY - size.height/2 // .center
				}
			} else {
				yPosition = currentPos
				// Handle Horizontal Alignment (Leading/Center/Trailing)
				switch alignment.horizontal {
				case .leading:  xPosition = bounds.minX
				case .trailing: xPosition = bounds.maxX - size.width
				default:        xPosition = bounds.midX - size.width/2 // .center
				}
			}

			let placementProposal: ProposedViewSize = orientation == .horizontal
				? ProposedViewSize(width: size.width, height: bounds.height)
				: ProposedViewSize(width: bounds.width, height: size.height)

			subview.place(at: CGPoint(x: xPosition, y: yPosition), anchor: .topLeading, proposal: placementProposal)

			// Advance Main Axis
			let stride = (orientation == .horizontal ? size.width : size.height)
			let spacing = (distribution == .equalSpacing) ? gap : getSpacing(between: subviews, at: index)
			currentPos += stride + spacing
		}
	}
}
