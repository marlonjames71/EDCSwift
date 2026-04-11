//
//  SmartStack.swift
//  EDCSwift
//
//  Created by Marlon Raskin on 2026-04-11.
//

import SwiftUI

// MARK: - HSTACK

/// A horizontal stack that responds to the current `StackDistribution`.
///
/// Use `distribution(_:)` to switch between standard spacing, centered spacing,
/// or equal spacing behaviors without changing your view hierarchy.
///
public struct SmartHStack<Content: View>: View {
	@Environment(\.stackDistribution) var distribution
	let alignment: VerticalAlignment
	let content: () -> Content

	/// Creates a smart horizontal stack.
	///
	/// - Parameters:
	///   - alignment: Vertical alignment for the arranged subviews.
	///   - content: A view builder that creates the stack's content.
	///
	public init(
		alignment: VerticalAlignment = .center,
		@ViewBuilder content: @escaping () -> Content
	) {
		self.alignment = alignment
		self.content = content
	}

	public var body: some View {
		UnifiedStackLayout(
			orientation: .horizontal,
			distribution: distribution,
			alignment: Alignment(horizontal: .center, vertical: alignment) // Convert here
		) {
			content()
		}
		.frame(maxWidth: distribution.containerShouldExpand ? .infinity : nil, alignment: .center)
	}
}

// MARK: - VSTACK

/// A vertical stack that responds to the current `StackDistribution`.
///
/// Use `distribution(_:)` to switch between standard spacing, centered spacing,
/// or equal spacing behaviors without changing your view hierarchy.
///
public struct SmartVStack<Content: View>: View {
	@Environment(\.stackDistribution) var distribution
	let alignment: HorizontalAlignment
	let content: () -> Content

	/// Creates a smart vertical stack.
	///
	/// - Parameters:
	///   - alignment: Horizontal alignment for the arranged subviews.
	///   - content: A view builder that creates the stack's content.
	///
	public init(
		alignment: HorizontalAlignment = .center,
		@ViewBuilder content: @escaping () -> Content
	) {
		self.alignment = alignment
		self.content = content
	}

	public var body: some View {
		UnifiedStackLayout(
			orientation: .vertical,
			distribution: distribution,
			alignment: Alignment(horizontal: alignment, vertical: .center) // Convert here
		) {
			content()
		}
		.frame(maxHeight: distribution.containerShouldExpand ? .infinity : nil, alignment: .center)
	}
}

// MARK: - Preview Helpers

private func circles() -> some View {
	ForEach(1...6, id: \.self) { _ in
		Circle()
			.fill(.secondary)
			.frame(width: 36, height: 36)
	}
}

private func sectionText(title: String, description: String? = nil) -> some View {
	VStack(spacing: description != nil ? 12 : 0) {
		Text(title)
			.foregroundStyle(.secondary)
			.font(.title3)
			.fontWidth(.condensed)
			.fontWeight(.heavy)
			.frame(maxWidth: .infinity, alignment: .leading)

		if let description, !description.isEmpty {
			Text(description)
				.font(.footnote)
				.frame(maxWidth: .infinity, alignment: .leading)
		}
	}
	.padding(.horizontal, 12)
}

private func section<Content: View>(
	title: String,
	description: String? = nil,
	content: (() -> Content)? = nil
) -> some View {
	VStack(spacing: 24) {
		sectionText(title: title, description: description)

		if let content {
			content()
		}
	}
}

// MARK: - Previews

#Preview("Horizontal") {
	@Previewable @State var isExpanded = false

	NavigationStack {
		ScrollView {
			VStack(spacing: 50) {
				section(
					title: "Standard",
					description: "Acts like a normal stack provided by SwiftUI. Helpful if  the need to animate smoothly between a normal stack and one of the other distributions arises."
				) {
					SmartHStack {
						SmartHStack { circles() }
							.background(Color(uiColor: .tertiarySystemBackground))
							.padding()
							.background(Color(uiColor: .secondarySystemBackground))
							.distribution(.standard(spacing: 16))
					}
					.distribution(.centered(spacing: nil))
				}

				section(
					title: "Centered",
					description: "Centers all elements within the stack and spaces them apart with the provided value. Try changing the spacing value from 16 to 20. Also, the view itself will grow as much as allowed."
				) {
					VStack {
						HStack {
							Text("Spacing: **\(isExpanded ? 24 : 16)**")
								.monospaced()
								.animation(nil, value: isExpanded)

							Button("Change") {
								withAnimation(.smooth(duration: 0.3, extraBounce: 0.4)) { isExpanded.toggle() }
							}
							.buttonStyle(.borderedProminent)
							.controlSize(.mini)

							Spacer()
						}
						.padding(.horizontal, 12)

						SmartHStack { circles() }
							.background(Color(uiColor: .tertiarySystemBackground))
							.padding()
							.background(Color(uiColor: .secondarySystemBackground))
							.distribution(.centered(spacing: isExpanded ? 24 : 16))
					}
				}
				.monospacedDigit()

				section(
					title: "Equal Spacing",
					description: "Elements fill up all available space while providing equal spacing between each element. The view itself will grow as much as allowed."
				) {
					SmartHStack { circles() }
						.background(Color(uiColor: .tertiarySystemBackground))
						.padding()
						.background(Color(uiColor: .secondarySystemBackground))
						.distribution(.equalSpacing)
				}

				Spacer()
			}
			.padding(.top, 20)
		}
		.navigationTitle("Smart HStacks")
		.toolbarTitleDisplayMode(.inlineLarge)
	}
}

#Preview("Vertical") {
	@Previewable @State var isExpanded = false

	NavigationStack {
		ScrollView {
			VStack(spacing: 30) {
				SmartHStack(alignment: .top) {
					VStack(spacing: 12) {
						Image(systemName: "1.circle.fill")
							.font(.largeTitle)
							.foregroundStyle(.indigo)

						SmartVStack { circles() }
							.background(Color(uiColor: .tertiarySystemBackground))
							.padding()
							.background(Color(uiColor: .secondarySystemBackground))
							.distribution(.standard(spacing: 16))
					}

					VStack(spacing: 12) {
						Image(systemName: "2.circle.fill")
							.font(.largeTitle)
							.foregroundStyle(.orange)

						SmartVStack { circles() }
							.frame(height: 370)
							.background(Color(uiColor: .tertiarySystemBackground))
							.padding()
							.background(Color(uiColor: .secondarySystemBackground))
							.distribution(.centered(spacing: isExpanded ? 24 : 16))
					}

					VStack(spacing: 12) {
						Image(systemName: "3.circle.fill")
							.font(.largeTitle)
							.foregroundStyle(.cyan)

						SmartVStack { circles() }
							.frame(height: 350)
							.background(Color(uiColor: .tertiarySystemBackground))
							.padding()
							.background(Color(uiColor: .secondarySystemBackground))
							.distribution(.equalSpacing)
					}
				}
				.distribution(.centered(spacing: 40))

				HStack(alignment: .top) {
					Image(systemName: "1.circle.fill")
						.font(.largeTitle)
						.foregroundStyle(.indigo)

					sectionText(
						title: "Standard",
						description: "Acts like a normal stack provided by SwiftUI. Helpful if  the need to animate smoothly between a normal stack and one of the other distributions arises."
					)
				}

				HStack(alignment: .top) {
					Image(systemName: "2.circle.fill")
						.font(.largeTitle)
						.foregroundStyle(.orange)

					VStack {
						sectionText(
							title: "Centered",
							description: "Centers all elements within the stack and spaces them apart with the provided value. Try changing the spacing value from 16 to 20. Also, the view itself will grow as much as allowed."
						)
						.monospacedDigit()

						HStack {
							Text("Spacing: **\(isExpanded ? 24 : 16)**")
								.monospaced()
								.animation(nil, value: isExpanded)

							Button("Change") {
								withAnimation(.smooth(duration: 0.3, extraBounce: 0.4)) { isExpanded.toggle() }
							}
							.buttonStyle(.borderedProminent)
							.controlSize(.mini)

							Spacer()
						}
						.padding(.horizontal, 12)
					}
				}

				HStack(alignment: .top) {
					Image(systemName: "3.circle.fill")
						.font(.largeTitle)
						.foregroundStyle(.cyan)

					sectionText(
						title: "Equal Spacing",
						description: "Elements fill up all available space while providing equal spacing between each element. The view itself will grow as much as allowed."
					)
				}
			}
			.padding(.top, 20)
			.padding(.horizontal, 12)
		}
		.navigationTitle("Smart VStacks")
		.toolbarTitleDisplayMode(.inlineLarge)
	}
}
