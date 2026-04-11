//
//  AdaptiveLabel.swift
//  EDCSwift
//
//  Created by Marlon Raskin on 2026-04-11.
//

import SwiftUI

/// A `Label`-like view that displays a leading icon and a text label, automatically
/// adapting its vertical alignment based on whether the text wraps to multiple lines.
///
/// When the text is single-line, the icon centers vertically with the text. When the
/// text wraps to multiple lines, the icon aligns to the top of the text block. This
/// provides optimal visual alignment in both scenarios.
///
/// The view reads `.font` from the environment so callers can style it with `.font(...)`
/// just like standard SwiftUI controls.
///
/// ### How it works
/// The view uses `TextMultiLineDetector` to detect whether the text spans multiple lines.
/// Based on this detection, it dynamically adjusts the `HStack` alignment between `.center`
/// (for single-line) and `.top` (for multi-line).
///
@MainActor
public struct AdaptiveLabel<Icon>: View where Icon : View {
	// MARK: Properties

	/// The text to render in the label.
	let text: String

	/// Spacing between the icon and text.
	let spacing: CGFloat?

	/// The leading icon view.
	let icon: Icon

	// MARK: SwiftUI Properties

	@State private var textIsMultiLine = false

	@Environment(\.font) var font

	@Environment(\.isEnabled) var isEnabled

	private var useIntrinsicWidth = false

	// MARK: Init

	/// Creates a label that adapts its icon alignment based on whether the text wraps.
	///
	/// the label automatically detects multi-line text and adjusts alignment accordingly:
	/// - Single-line text: icon centers with text
	/// - Multi-line text: icon aligns to top of the text block
	///
	/// - Parameters:
	///   - text: The label's text.
	///   - spacing: The horizontal spacing between the icon and text. The default is `nil`, which uses SwiftUI's stack default spacing.
	///   - icon: A builder that produces the leading icon view.
	///
	public init(
		_ text: String,
		spacing: CGFloat? = nil,
		@ViewBuilder icon: () -> Icon
	) {
		self.text = text
		self.spacing = spacing
		self.icon = icon()
	}

	// MARK: Body

	public var body: some View {
		HStack(alignment: verticalAlignment, spacing: spacing) {
			icon
				.font(font)

			Text(text)
				.detectsMultiLine()
				.font(font)
				.fixedSize(horizontal: false, vertical: true)
				.frame(
					maxWidth: useIntrinsicWidth ? nil : .infinity,
					alignment: useIntrinsicWidth ? .center : .leading
				)
		}
		.onTextMultiLineChange { isMultiLine in
			self.textIsMultiLine = isMultiLine
		}
	}

	// MARK: Helpers

	/// Determines the vertical alignment based on the text spanning multiple lines.
	private var verticalAlignment: VerticalAlignment {
		textIsMultiLine ? .top : .center
	}
}

// MARK: - Convenience Init

extension AdaptiveLabel where Icon == Image {
	/// convenience init using an SF Symbol's system image.
	///
	/// - Parameters:
	///  - text: The label text.
	///  - systemName: The SF Symbol's name.
	///  - spacing: Space between the icon and text.
	///
	public  init(
		_ text: String,
		systemName: String,
		spacing: CGFloat? = nil
	) {
		self.init(text, spacing: spacing) {
			Image(systemName: systemName)
		}
	}
}

// MARK: - Modifiers

extension AdaptiveLabel {
	/// Requests that the label uses its intrinsic width instead of expanding to
	/// fill the available horizontal space.
	///
	/// By default, the label stretches horizontally to `maxWidth: .infinity`
	/// so it behaves naturally inside flexible layouts like lists and forms.
	/// If you need the label to size itself only as wide as its content (for
	/// example, alongside other intrinsic-sized elements), call this modifier:
	///
	/// ```swift
	/// AdaptiveLabel("Short note", systemName: "info.circle")
	/// 	.usesIntrinsicWidth()
	/// ```
	public func useIntrinsicWidth(_ usesIntrinsicWidth: Bool = true) -> Self {
		var copy = self
		copy.useIntrinsicWidth = usesIntrinsicWidth
		return copy
	}
}
