//
//  FirstLineCenteredLabel.swift
//  EDCSwift
//
//  Created by Marlon Raskin on 2025-09-13.
//

import SwiftUI

/// An alignment identifier whose value represents the vertical center of the
/// first line of a text block.
///
/// Views can opt into this alignment by providing a custom alignment guide for
/// ``VerticalAlignment/firstLineCenter``. If a view does not provide a custom
/// value, the default falls back to the view's own vertical center, which keeps
/// mixed layouts sensible when some children do not participate.
///
/// This identifier is primarily intended for layouts where an icon (or any
/// leading view) should visually align to the first line of a multi-line text,
/// such as labels, lists, and forms.
///
public struct FirstLineCenterID: AlignmentID {
	public static func defaultValue(in context: ViewDimensions) -> CGFloat {
		context[VerticalAlignment.center]
	}
}

extension VerticalAlignment {
	/// A custom vertical alignment used to align views against the visual
	/// center of the first line of text.
	///
	/// Use this alignment in stacks when you want a leading icon (or any
	/// other view) to align with the first line of a multi-line `Text`:
	///
	/// ```swift
	/// HStack(alignment: .firstLineCenter) {
	///     Image(systemName: "info.circle")
	///         .alignmentGuide(.firstLineCenter) { d in
	///             d[.top] + d.height / 2
	///         }
	///     Text("A long message that might wrap onto multiple lines.")
	///         .alignmentGuide(.firstLineCenter) { d in
	///             // Provide the center of the first line if known,
	///             // otherwise fall back to the view's center.
	///             d[.top] + (d.height / 2)
	///         }
	/// }
	/// ```
	///
	public static let firstLineCenter = VerticalAlignment(FirstLineCenterID.self)
}


/// A SwiftUI label that aligns its leading icon to the visual center of the text’s first line.
///
/// FirstLineCenteredLabel is useful when your text can wrap onto multiple lines but you still
/// want the icon (or any leading view) to line up with the first line — a common pattern in
/// lists, forms, and message-style layouts.
///
/// The view measures the first-line height for the current environment font and applies a
/// custom vertical alignment guide (``VerticalAlignment/firstLineCenter``) so that the icon
/// remains visually centered on the first line even as the text wraps.
///
/// - Features:
///   - Works with any leading view type via a generic `Icon: View`.
///   - Respects the environment font and updates alignment as fonts change.
///   - Provides a convenience initializer for SF Symbols when `Icon == Image`.
///   - Can be configured to use intrinsic width via ``usesIntrinsicWidth()``.
///
/// - Example:
///   ```swift
///   FirstLineCenteredLabel("A long message that can wrap to multiple lines.") {
///       Image(systemName: "info.circle")
///   }
///   .font(.body) // alignment adapts to this font
///   ```
///
/// - Accessibility:
///   The icon participates in layout and styling but does not alter the text’s measured
///   first-line alignment. Screen readers will read the text normally. If the icon conveys
///   independent meaning, add an accessibility label to the icon view you supply.
///
@MainActor
public struct FirstLineCenteredLabel<Icon: View>: View {
	// MARK: Properties
	
	/// The text content.
	let text: String
	
	/// Spacing between the icon and text.
	let spacing: CGFloat?
	
	/// The leading icon view.
	let icon: Icon
	
	
	// MARK: SwiftUI Properties
	
	/// Cached measured height of a single line for the current font.
	@State private var firstLineHeight: CGFloat?
	
	/// The effective font pulled from the environment; used by both visible and measuring text.
	@Environment(\.font) var font
	
	@State private var useIntrinsicWidth = false
	
	
	// MARK: - Init
	
	/// Creates a label that aligns its icon to the visual center of the first line of its text.
	///
	/// The label measures the first-line height for the current environment font and uses a
	/// custom vertical alignment guide (``VerticalAlignment/firstLineCenter``) so that the icon
	/// visually centers on the first line, even when the text wraps to multiple lines.
	///
	/// - Parameters:
	///   - text: The label's text.
	///   - spacing: The horizontal spacing between the icon and text. The default is `nil`,
	///              which uses SwiftUI's stack default spacing.
	///   - icon: A builder that produces the leading icon view.
	///
	/// - Accessibility:
	///   The icon participates in layout and styling but does not alter the text’s measured
	///   first-line alignment. Screen readers will read the text as usual. Provide meaningful
	///   accessibility labels on the icon if it conveys independent meaning.
	///
	public init(
		_ text: String,
		spacing: CGFloat? = nil,
		@ViewBuilder icon: () -> Icon,
	) {
		self.text = text
		self.spacing = spacing
		self.icon = icon()
	}
	
	
	// MARK: - Body
	
	public var body: some View {
		HStack(alignment: .firstLineCenter, spacing: spacing) {
			let text = Text(text)
			let cachedFirstLineHeight = firstLineHeight
			
			icon
				.alignmentGuide(.firstLineCenter) { d in
					d[.top] + d.height / 2
				}
				.font(font)
			
			text
				.font(font)
				.fixedSize(horizontal: false, vertical: true)
				.alignmentGuide(.firstLineCenter) { d in
					let h = cachedFirstLineHeight ?? d.height
					return d[.top] + h / 2
				}
				// Measure the natural height of a single line **without impacting layout**:
				// A 1-line clone in an overlay with zero frame captures `geo.size.height` for
				// the current environment font. This avoids the `.hidden()` pitfall which
				// keeps layout space.
				.overlay(alignment: .topLeading) {
					text.font(font).lineLimit(1).fixedSize()
						.overlay {
							GeometryReader { proxy in
								Color.clear
									.onAppear { firstLineHeight = proxy.size.height }
									.onChange(of: proxy.size.height) { _, newValue in
										firstLineHeight = newValue
									}
							}
						}
						.opacity(0)
						.frame(width: 0, height: 0)
						.allowsHitTesting(false)
						.accessibilityHidden(true)
				}
				.frame(
					maxWidth: useIntrinsicWidth ? nil : .infinity,
					alignment: useIntrinsicWidth ? .leading : .leading
				)
		}
	}
}

extension FirstLineCenteredLabel {
	/// Requests that the label use its intrinsic width instead of expanding to
	/// fill the available horizontal space.
	///
	/// By default, the label stretches horizontally to `maxWidth: .infinity`
	/// so it behaves naturally inside flexible layouts like lists and forms.
	/// If you need the label to size itself only as wide as its content (for
	/// example, when placed in a flow layout or alongside other intrinsic-sized
	/// elements), call this modifier:
	///
	/// ```swift
	/// FirstLineCenteredLabel("Short note", systemName: "info.circle")
	///     .usesIntrinsicWidth()
	/// ```
	///
	/// - Returns: A copy of the label configured to use its intrinsic width.
	///
	public func usesIntrinsicWidth() -> Self {
		var copy = self
		copy._useIntrinsicWidth = .init(wrappedValue: true)
		return copy
	}
}


// MARK: - Convenience Init

extension FirstLineCenteredLabel where Icon == Image {
	/// Creates a first-line-centered label with an SF Symbol image.
	///
	/// - Parameters:
	///   - text: The label text.
	///   - systemName: The SF Symbol name for the leading image.
	///   - spacing: The horizontal spacing between the image and text. The default is `nil`,
	///              which uses SwiftUI's stack default spacing.
	///
	public init(
		_ text: String,
		systemName: String,
		spacing: CGFloat? = nil
	) {
		self.init(text, spacing: spacing) {
			Image(systemName: systemName)
		}
	}
}


// MARK: - Preview

#Preview {
	FirstLineCenteredLabelDemo()
}
