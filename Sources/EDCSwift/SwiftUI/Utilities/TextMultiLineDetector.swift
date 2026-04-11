//
//  TextMultiLineDetector.swift
//  EDCSwift
//
//  Created by Marlon Raskin on 2026-04-10.
//

import SwiftUI

// MARK: - PreferenceKey

/// Preference key that carries whether text spans multiple lines.
private struct TextMultiLinePreferenceKey: PreferenceKey {
	/// Default value (assumes single line).
	static let defaultValue: Bool = false

	/// Reduce multiple preference values to a single value.
	/// Takes the first non-default value, or defaults to false.
	///
	static func reduce(value: inout Bool, nextValue: () -> Bool) {
		let next = nextValue()
		if !value {
			value = next
		}
	}
}

// MARK: - View Modifier

/// A view modifier that detects whether a `Text` view spans multiple lines
/// by comparing the first line height to the actual rendered height.
///
/// This modifier measures the text using the same technique as ``FirstLineCenteredLabel``:
/// it creates a hidden single-line cline to measure the first line height, then compares
/// it to the actual text height. The result is published via ``TextMultiLinePreferenceKey``.
///
/// Performance optimizations:
/// - Only updates the preference when the `isMultiLine` boolean value changes
/// - Caches first line height measurement
/// - Re-measures when font changes from environment
///
@MainActor
private struct TextMultiLineDetectorModifier: ViewModifier {
	// MARK: State

	/// Measured height of a single line for the current font.
	@State private var firstLineHeight: CGFloat?

	/// Actual rendered height of the text.
	@State private var actualHeight: CGFloat?

	/// Cached multi-line state to avoid unnecessary preference updates,
	@State private var isMultiLine: Bool = false

	/// The effective font pulled from the environment.
	@Environment(\.font) var font

	// MARK: Body

	func body(content: Content) -> some View {
		content
			.fixedSize(horizontal: false, vertical: true)
			.background(
				GeometryReader { geometry in
					Color.clear
						.onAppear {
							actualHeight = geometry.size.height
							updateMultiLineState()
						}
						.onChange(of: geometry.size.height) { _, newHeight in
							actualHeight = newHeight
							updateMultiLineState()
						}
				}
			)
			.overlay {
				// Measure first line height using a hidden single-line clone
				// This pattern is from FirstLineCenteredLabel
				content
					.font(font)
					.lineLimit(1)
					.fixedSize()
					.overlay(
						GeometryReader { geometry in
							Color.clear
								.onAppear {
									firstLineHeight = geometry.size.height
									updateMultiLineState()
								}
								.onChange(of: geometry.size.height) { _, newHeight in
									firstLineHeight = newHeight
									updateMultiLineState()
								}
						}
					)
					.opacity(0)
					.frame(width: 0, height: 0)
					.allowsHitTesting(false)
					.accessibilityHidden(true)
			}
			.onChange(of: font) { _, _ in
				// Reset measurements when font changes
				firstLineHeight = nil
				actualHeight = nil
			}
			.preference(key: TextMultiLinePreferenceKey.self, value: isMultiLine)
	}

	// MARK: Helpers

	/// Updates the multi-line state by comparing heights, and only updates
	/// the preference if the boolean value actually changes.
	///
	private func updateMultiLineState() {
		guard
			let firstLineHeight,
			let actualHeight
		else {
			return
		}

		// Compare with tolerance for floating point precision
		// Text is multi-line if actual height exceeds line height by more than 1 point
		let newIsMultiLine = actualHeight > firstLineHeight + 1

		// Only update state and preference if the value actually changed
		if newIsMultiLine != isMultiLine {
			isMultiLine = newIsMultiLine
		}
	}
}

// MARK: - Text Extension

@MainActor
extension Text {
	/// Detects whether this text view spans multiple lines.
	///
	/// The result is published via `TextMultiLinePreferenceKey` and can be read
	/// by parent views using `.onTextMultiLineChange(_:)`.
	///
	/// This modifier measures the text by comparing the first line height to the
	/// actual rendered height. It only updates the preference when the multi-line
	/// state actually changes, avoiding unnecessary re-renders.
	///
	/// - Returns: The text view with multi-line detection enabled.
	///
	/// ## Example
	/// ```swift
	/// HStack(alignment: isMultiple ? .top : .center) {
	/// 	Image(systemName: "star")
	/// 	Text("Some text that might wrap")
	/// 		.detectsMultiLine()(
	/// }
	/// .onTextMultiLineChange {
	/// 	// update alignment state
	/// }
	/// ```
	///
	public func detectsMultiLine() -> some View {
		modifier(TextMultiLineDetectorModifier())
	}
}

// MARK: - View Extension

extension View {
	/// Reads the multi-line state from child views that use `.detectsMultiLine()`.
	///
	/// This  modifier observes `TextMultiLinePreferenceKey` and calls the closure
	/// only when the multi-line state changes, not on every layout pass.
	///
	/// - Parameter onChange: Closure called when the multi-line state changes.
	/// 	The parameter is `true` if the text spans multiple lines, `false`  otherwise.
	/// - Returns: The view with multi-line state observation.
	///
	/// ## Example
	/// ```swift
	/// VStack {
	///	Text("Some Text")
	///		.detectsMultiLine()
	/// }
	/// .onTextMultiLineChange { isMultiLine in
	///	print("Text is multi-line: \(isMultiLine)")
	/// }
	/// ```
	///
	public func onTextMultiLineChange(_ onChange: @escaping (Bool) -> Void) -> some View {
		onPreferenceChange(TextMultiLinePreferenceKey.self, perform: onChange)
	}
}
