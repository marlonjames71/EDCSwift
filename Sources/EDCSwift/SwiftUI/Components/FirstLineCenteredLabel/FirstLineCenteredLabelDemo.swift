//
//  FirstLineCenteredLabelDemo.swift
//  EDCSwift
//
//  Created by Marlon Raskin on 2025-09-14.
//

import SwiftUI

struct FirstLineCenteredLabelDemo: View {
	var body: some View {
		VStack(alignment: .leading, spacing: 20) {
			FirstLineCenteredLabel("Here is some text!", systemName: "text.page")
			
			FirstLineCenteredLabel("Servers are down currently. Running diagnostic now and will report back soon.") {
				Circle().fill(.red.gradient).frame(square: 6)
			}
			
			FirstLineCenteredLabel("The server issue has been resolved.") {
				Circle().fill(.green.gradient).frame(square: 6)
			}
			
			FirstLineCenteredLabel(
	"""
	You've gotta dance like there's nobody watching, Love like you'll never be hurt, Sing like there's nobody listening, and live like it's heaven on earth.
	 
	- William W. Purkey
	""",
	systemName: "quote.opening"
			)
			.padding()
			.background(.yellow.gradient.quaternary)
			.clipShape(.rect(cornerRadius: 20))
			
			.overlay {
				RoundedRectangle(cornerRadius: 20).stroke(.yellow.gradient, lineWidth: 1.5)
			}
			
			VStack(alignment: .leading, spacing: 4) {
				FirstLineCenteredLabel("Tasks", systemName: "checklist")
					.foregroundStyle(.blue)
					.font(Font.headline.bold())
				
				Rectangle()
					.frame(height: 0.5)
					.foregroundStyle(.blue.secondary)
					.padding(.vertical, 8)
				
				FirstLineCenteredLabel("This is some task that should get done.") {
					Image(systemName: "circle")
						.foregroundStyle(.blue)
				}
				
				FirstLineCenteredLabel("First child task") {
					Image(systemName: "circle")
						.foregroundStyle(.blue)
				}
				.padding(.horizontal, 18)
				
				FirstLineCenteredLabel("Second child task") {
					Image(systemName: "checkmark.circle.fill")
						.foregroundStyle(.blue)
				}
				.padding(.horizontal, 18)
				
				FirstLineCenteredLabel("Final task before the project is complete!") {
					Image(systemName: "checkmark.circle.fill")
						.foregroundStyle(.blue)
				}
			}
			.padding()
			.background(.blue.quaternary)
			.clipShape(RoundedRectangle(cornerRadius: 20))
			.overlay {
				RoundedRectangle(cornerRadius: 20).stroke(.blue.gradient.secondary, lineWidth: 1.5)
			}
			
			Spacer()
		}
		.frame(maxWidth: .infinity)
		.padding(.horizontal)
	}
}
